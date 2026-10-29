const {test, beforeEach, after} = require('node:test');
const assert = require('node:assert/strict');
const {initializeApp, deleteApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {
  AccountManagementService, requireRecentAuth, validateReason, validateStatus,
  noticeText, SUPPORT_EMAIL,
} = require('../lib/account_management');

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  throw new Error('These tests require the Firestore emulator; production is never used.');
}
const projectId = 'demo-unimatch-account-management';
const app = initializeApp({projectId}, 'account-management-tests');
const db = getFirestore(app);
beforeEach(async () => {
  const response = await fetch(`http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${projectId}/databases/(default)/documents`, {method: 'DELETE'});
  assert.equal(response.ok, true);
});
after(async () => { await db.terminate(); await deleteApp(app); });

class TestAuth {
  constructor() {
    this.users = new Map([
      ['alice', {uid: 'alice', disabled: false}],
      ['bob', {uid: 'bob', disabled: false}],
      ['admin', {uid: 'admin', disabled: false, customClaims: {admin: true}}],
    ]);
    this.failDeleteOnce = false;
  }
  async getUser(uid) {
    if (!this.users.has(uid)) throw Object.assign(new Error('Missing user'), {code:'auth/user-not-found'});
    return this.users.get(uid);
  }
  async updateUser(uid, patch) { Object.assign(await this.getUser(uid), patch); }
  async revokeRefreshTokens(uid) { await this.getUser(uid); }
  async deleteUser(uid) {
    if (this.failDeleteOnce) { this.failDeleteOnce = false; throw new Error('temporary auth failure'); }
    await this.getUser(uid); this.users.delete(uid);
  }
}

async function seed() {
  for (const uid of ['alice', 'bob']) {
    await db.doc(`users/${uid}`).set({uid, accountStatus: 'active', email:`${uid}@example.com`});
    await db.doc(`publicProfiles/${uid}`).set({uid, accountStatus: 'active'});
  }
  await db.doc('users/alice/devices/phone').set({token:'test-device'});
  await db.doc('users/alice/sessions/session').set({durationSeconds: 10});
  await db.doc('users/alice/passes/bob').set({targetUserId:'bob'});
  await db.doc('likes/alice_bob').set({senderId:'alice', receiverId:'bob'});
  await db.doc('likes/bob_alice').set({senderId:'bob', receiverId:'alice'});
  await db.doc('likes/bob_other').set({senderId:'bob', receiverId:'other'});
  await db.doc('blocks/bob_alice').set({blockerId:'bob', blockedUserId:'alice'});
  await db.doc('matches/alice_bob').set({userIds:['alice','bob']});
  await db.doc('conversations/alice_bob').set({participants:['alice','bob']});
  await db.doc('conversations/alice_bob/messages/one').set({senderId:'alice', text:'test'});
  await db.doc('conversations/alice_bob/messages/two').set({senderId:'bob', text:'test'});
  await db.doc('conversations/bob_other').set({participants:['bob','other']});
  await db.doc('conversations/bob_other/messages/keep').set({text:'keep'});
  await db.doc('reports/by_alice').set({reporterId:'alice', reportedUserId:'bob'});
  await db.doc('reports/about_alice').set({reporterId:'bob', reportedUserId:'alice'});
}

test('deletion requires recent authentication and explicit valid input', () => {
  const now = Date.now();
  assert.throws(() => requireRecentAuth(null), /Inicia sesión/);
  assert.throws(() => requireRecentAuth({uid:'alice', token:{auth_time:now/1000-301}}, now), /Confirma tu identidad/);
  assert.equal(requireRecentAuth({uid:'alice', token:{auth_time:now/1000}}, now), 'alice');
  assert.throws(() => validateStatus('owner'), /Estado/);
  assert.throws(() => validateReason(''), /motivo/);
});

test('a user cannot delete somebody else or an administrator', async () => {
  const service = new AccountManagementService(db, new TestAuth());
  await assert.rejects(service.changeStatus('bob', 'alice', 'deleted', 'test reason', 'user'), /propia cuenta/);
  await assert.rejects(service.changeStatus('admin', 'admin', 'deleted', 'test reason', 'user'), /administrativas/);
  await assert.rejects(service.changeStatus('bob', 'alice', 'banned', 'test reason', 'admin'), /administrativa activa/);
});

test('owner deletion removes auth and related data but preserves unrelated accounts', async () => {
  await seed();
  const auth = new TestAuth();
  const service = new AccountManagementService(db, auth);
  assert.equal((await service.changeStatus('alice','alice','deleted','Solicitud del titular','user')).status, 'deletion-requested');
  assert.equal(auth.users.get('alice').disabled, true);
  assert.equal((await db.doc('users/alice').get()).data().accountStatus, 'deleted');
  await service.finishDeletion('alice');
  for (const path of ['users/alice','publicProfiles/alice','users/alice/devices/phone',
    'users/alice/sessions/session','likes/alice_bob','likes/bob_alice',
    'blocks/bob_alice','matches/alice_bob','conversations/alice_bob',
    'conversations/alice_bob/messages/two','reports/by_alice','reports/about_alice']) {
    assert.equal((await db.doc(path).get()).exists, false, path);
  }
  assert.equal(auth.users.has('alice'), false);
  assert.equal((await db.doc('users/bob').get()).exists, true);
  assert.equal((await db.doc('likes/bob_other').get()).exists, true);
  assert.equal((await db.doc('conversations/bob_other/messages/keep').get()).exists, true);
  assert.equal((await db.doc('accountDeletionJobs/alice').get()).data().status, 'completed');
  await service.finishDeletion('alice');
});

test('failed cleanup remains pending and can finish on a retry', async () => {
  await seed();
  const auth = new TestAuth();
  const service = new AccountManagementService(db, auth);
  await service.changeStatus('admin','alice','deleted','Decisión administrativa','admin');
  auth.failDeleteOnce = true;
  await assert.rejects(service.finishDeletion('alice'), /temporary/);
  assert.equal((await db.doc('accountDeletionJobs/alice').get()).data().status, 'pending');
  assert.equal(auth.users.get('alice').disabled, true);
  await service.finishDeletion('alice');
  assert.equal((await db.doc('accountDeletionJobs/alice').get()).data().status, 'completed');
});

test('a deletion in progress cannot be reactivated, including its Auth identity', async () => {
  await seed();
  const auth = new TestAuth();
  const service = new AccountManagementService(db, auth);
  await service.changeStatus('admin','alice','deleted','Decisión administrativa','admin');
  await assert.rejects(service.changeStatus('admin','alice','active','Reactivar cuenta','admin'), /proceso de eliminación/);
  assert.equal(auth.users.get('alice').disabled, true);
});

test('a sanction includes the actual reason and appeal contact, with no email-delivery claim', async () => {
  await seed();
  const service = new AccountManagementService(db, new TestAuth());
  await service.changeStatus('admin','alice','banned','Incumplimiento de las normas','admin');
  const notice = (await db.doc('accountNotices/alice').get()).data();
  assert.equal(notice.supportEmail, SUPPORT_EMAIL);
  assert.match(notice.message, /Incumplimiento de las normas/);
  assert.match(notice.message, /unimatch7@gmail.com/);
  assert.match(notice.message, /apelar/);
  assert.equal(notice.emailSent, undefined);
  assert.match(noticeText('deleted','Solicitud del titular'), /no pueden recuperarse/);
});
