import {getAuth, Auth} from 'firebase-admin/auth';
import {Firestore, FieldValue, Timestamp, Query, getFirestore} from 'firebase-admin/firestore';
import {HttpsError, onCall, CallableRequest} from 'firebase-functions/v2/https';
import {onDocumentCreated} from 'firebase-functions/v2/firestore';

export const SUPPORT_EMAIL = 'unimatch7@gmail.com';
const RETENTION_MS = 30 * 24 * 60 * 60 * 1000;
type Status = 'active' | 'suspended' | 'banned' | 'deleted';

export function validateStatus(value: unknown): Status {
  if (typeof value !== 'string' || !['active', 'suspended', 'banned', 'deleted'].includes(value)) {
    throw new HttpsError('invalid-argument', 'Estado de cuenta no válido.');
  }
  return value as Status;
}

export function validateReason(value: unknown): string {
  if (typeof value !== 'string' || value.trim().length < 5 || value.trim().length > 300) {
    throw new HttpsError('invalid-argument', 'Indica un motivo de entre 5 y 300 caracteres.');
  }
  return value.trim();
}

export function requireRecentAuth(auth: CallableRequest['auth'], now = Date.now()): string {
  if (!auth) throw new HttpsError('unauthenticated', 'Inicia sesión de nuevo.');
  const authTime = Number(auth.token.auth_time) * 1000;
  if (!Number.isFinite(authTime) || authTime > now + 60_000 || now - authTime > 5 * 60_000) {
    throw new HttpsError('failed-precondition', 'Confirma tu identidad iniciando sesión de nuevo.');
  }
  return auth.uid;
}

export function noticeText(status: Status, reason: string): string {
  const title = {
    active: 'Tu cuenta fue reactivada.',
    suspended: 'Tu cuenta fue suspendida. No puedes usar UniMatch mientras siga suspendida.',
    banned: 'Tu cuenta fue baneada y no puede usar UniMatch.',
    deleted: 'Se solicitó la eliminación definitiva de tu cuenta y sus datos.',
  }[status];
  const next = status === 'deleted'
    ? 'Puedes pedir una revisión de la decisión. Los datos borrados definitivamente no pueden recuperarse.'
    : status === 'active'
      ? 'Puedes volver a iniciar sesión.'
      : 'Puedes apelar desde el correo asociado a tu cuenta, indicando el motivo y la fecha de la sanción.';
  return `${title}\nMotivo: ${reason}\n${next}\nQuejas, sugerencias y apelaciones: ${SUPPORT_EMAIL}. No envíes contraseñas.`;
}

function isMissingUser(error: unknown): boolean {
  return (error as {code?: string})?.code === 'auth/user-not-found';
}

export class AccountManagementService {
  constructor(private readonly db: Firestore, private readonly auth: Auth) {}

  async changeStatus(actorUid: string, uid: string, status: Status, reason: string,
    initiatedBy: 'user' | 'admin'): Promise<{status: string}> {
    const target = await this.auth.getUser(uid);
    if (target.customClaims?.admin === true) {
      throw new HttpsError('failed-precondition', 'Las cuentas administrativas requieren gestión fuera de esta herramienta.');
    }
    if (initiatedBy === 'admin') {
      const actor = await this.auth.getUser(actorUid);
      if (actor.disabled || actor.customClaims?.admin !== true) {
        throw new HttpsError('permission-denied', 'Se requiere una cuenta administrativa activa.');
      }
      if (actorUid === uid) throw new HttpsError('failed-precondition', 'No puedes aplicar esta acción a tu propia cuenta.');
    } else if (actorUid !== uid || status !== 'deleted') {
      throw new HttpsError('permission-denied', 'Solo puedes solicitar la eliminación de tu propia cuenta.');
    }

    const job = this.db.collection('accountDeletionJobs').doc(uid);
    const audit = this.db.collection('adminActions').doc();
    const expiresAt = Timestamp.fromMillis(Date.now() + RETENTION_MS);
    // Firestore access closes first. A rejected transition must never re-enable
    // an Auth identity whose deletion job is already running.
    await this.db.runTransaction(async transaction => {
      const profileRef = this.db.collection('users').doc(uid);
      const publicRef = this.db.collection('publicProfiles').doc(uid);
      const [profile, publicProfile, deletion] = await Promise.all([
        transaction.get(profileRef), transaction.get(publicRef), transaction.get(job),
      ]);
      if (deletion.exists && status !== 'deleted') {
        throw new HttpsError('failed-precondition', 'La cuenta está en proceso de eliminación y no puede reactivarse.');
      }
      const previousStatus = profile.data()?.accountStatus ?? 'active';
      if (profile.exists) transaction.update(profileRef, {accountStatus: status});
      if (publicProfile.exists) transaction.update(publicRef, {
        accountStatus: status, updatedAt: FieldValue.serverTimestamp(),
      });
      transaction.set(this.db.collection('accountNotices').doc(uid), {
        status, reason, message: noticeText(status, reason), supportEmail: SUPPORT_EMAIL,
        issuedAt: FieldValue.serverTimestamp(),
        ...(['active', 'deleted'].includes(status) ? {expiresAt} : {}),
      });
      if (status === 'deleted' && !deletion.exists) {
        transaction.create(job, {
          status: 'pending', requestedBy: actorUid, initiatedBy,
          createdAt: FieldValue.serverTimestamp(),
          // Retention starts only after cleanup succeeds. An unfinished job must
          // never expire before data has actually been removed.
        });
      }
      if (initiatedBy === 'admin' && (previousStatus !== status || (status === 'deleted' && !deletion.exists))) {
        transaction.create(audit, {
          adminId: actorUid, userId: uid, action: 'accountStatusChanged',
          previousStatus, newStatus: status, reason,
          createdAt: FieldValue.serverTimestamp(), expiresAt,
        });
      }
    });
    const latest = await this.db.collection('users').doc(uid).get();
    const latestStatus = latest.data()?.accountStatus;
    const mustDisable = status === 'deleted' || !latest.exists || latestStatus !== 'active';
    await this.auth.updateUser(uid, {disabled: mustDisable}).catch(error => {
      if (status !== 'deleted' || !isMissingUser(error)) throw error;
    });
    if (mustDisable) {
      await this.auth.revokeRefreshTokens(uid).catch(error => {
        if (status !== 'deleted' || !isMissingUser(error)) throw error;
      });
    }
    return {status: status === 'deleted' ? 'deletion-requested' : status};
  }

  private async deleteQuery(query: Query): Promise<void> {
    while (true) {
      const page = await query.limit(100).get();
      if (page.empty) return;
      for (let index = 0; index < page.docs.length; index += 5) {
        await Promise.all(page.docs.slice(index, index + 5).map(doc => this.db.recursiveDelete(doc.ref)));
      }
    }
  }

  async finishDeletion(uid: string): Promise<void> {
    const job = this.db.collection('accountDeletionJobs').doc(uid);
    const current = await job.get();
    if (!current.exists || current.data()?.status === 'completed') return;
    await job.update({status: 'running', attempts: FieldValue.increment(1)});
    try {
      await this.auth.updateUser(uid, {disabled: true}).catch(error => {
        if (!isMissingUser(error)) throw error;
      });
      const queries = [
        this.db.collection('likes').where('senderId', '==', uid),
        this.db.collection('likes').where('receiverId', '==', uid),
        this.db.collection('blocks').where('blockerId', '==', uid),
        this.db.collection('blocks').where('blockedUserId', '==', uid),
        this.db.collection('matches').where('userIds', 'array-contains', uid),
        this.db.collection('conversations').where('participants', 'array-contains', uid),
        this.db.collection('reports').where('reporterId', '==', uid),
        this.db.collection('reports').where('reportedUserId', '==', uid),
      ];
      for (const query of queries) await this.deleteQuery(query);
      await this.db.recursiveDelete(this.db.collection('publicProfiles').doc(uid));
      await this.db.recursiveDelete(this.db.collection('users').doc(uid));
      await this.auth.deleteUser(uid).catch(error => {
        if (!isMissingUser(error)) throw error;
      });
      await job.update({
        status: 'completed', completedAt: FieldValue.serverTimestamp(),
        expiresAt: Timestamp.fromMillis(Date.now() + RETENTION_MS),
        lastError: FieldValue.delete(),
      });
    } catch (error) {
      // Retry the same job without marking a failed purge as completed.
      await this.db.runTransaction(async transaction => {
        const latest = await transaction.get(job);
        if (latest.exists && latest.data()?.status !== 'completed') {
          transaction.update(job, {status: 'pending', lastError: 'cleanup-failed'});
        }
      });
      throw error;
    }
  }
}

const options = {region: 'us-central1', maxInstances: 2, timeoutSeconds: 120};

export const deleteOwnAccount = onCall(options, async request => {
  const uid = requireRecentAuth(request.auth);
  if (request.data?.confirmation !== 'ELIMINAR') {
    throw new HttpsError('invalid-argument', 'Escribe ELIMINAR para confirmar.');
  }
  return new AccountManagementService(getFirestore(), getAuth()).changeStatus(
    uid, uid, 'deleted', 'Eliminación solicitada por el titular de la cuenta.', 'user',
  );
});

export const manageAccount = onCall(options, async request => {
  const status = validateStatus(request.data?.status);
  const actor = status === 'deleted' ? requireRecentAuth(request.auth) : request.auth?.uid;
  if (!actor) throw new HttpsError('unauthenticated', 'Inicia sesión de nuevo.');
  if (request.auth?.token.admin !== true) {
    throw new HttpsError('permission-denied', 'Se requiere una cuenta administrativa.');
  }
  const uid = request.data?.userId;
  if (typeof uid !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(uid)) {
    throw new HttpsError('invalid-argument', 'Identificador de cuenta no válido.');
  }
  return new AccountManagementService(getFirestore(), getAuth()).changeStatus(
    actor, uid, status, validateReason(request.data?.reason), 'admin',
  );
});

export const purgeDeletedAccount = onDocumentCreated({
  document: 'accountDeletionJobs/{userId}', region: 'us-central1',
  retry: true, timeoutSeconds: 540, memory: '512MiB', maxInstances: 2,
}, async event => {
  if (!event.data) return;
  await new AccountManagementService(getFirestore(), getAuth()).finishDeletion(event.params.userId);
});
