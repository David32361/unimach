import {setGlobalOptions} from 'firebase-functions';
import {
  onDocumentCreated,
  onDocumentUpdated,
} from 'firebase-functions/v2/firestore';
import {initializeApp} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';
import {getMessaging} from 'firebase-admin/messaging';

initializeApp();
setGlobalOptions({region: 'us-central1'});

export {deleteOwnAccount, manageAccount, purgeDeletedAccount} from './account_management';

const db = getFirestore();

async function sendToUser(
  userId: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  const devices = await db.collection('users').doc(userId).collection('devices').get();
  const tokens = devices.docs
    .map((document) => document.data().token)
    .filter((token): token is string => typeof token === 'string' && token.length > 0);

  if (tokens.length === 0) {
    return;
  }

  const result = await getMessaging().sendEachForMulticast({
    tokens,
    notification: {title, body},
    data,
    android: {
      priority: 'high',
    },
  });

  const invalidTokens = new Set<string>();
  result.responses.forEach((response, index) => {
    const code = response.error?.code;
    if (
      code === 'messaging/invalid-registration-token' ||
      code === 'messaging/registration-token-not-registered'
    ) {
      invalidTokens.add(tokens[index]);
    }
  });

  if (invalidTokens.size > 0) {
    const batch = db.batch();
    devices.docs.forEach((document) => {
      if (invalidTokens.has(document.data().token)) {
        batch.delete(document.ref);
      }
    });
    await batch.commit();
  }
}

export const notifyNewMatch = onDocumentCreated('matches/{matchId}', async (event) => {
  const match = event.data?.data();
  const userIds = match?.userIds;
  if (!Array.isArray(userIds) || userIds.length !== 2) {
    return;
  }

  await Promise.all(
    userIds.map((userId) =>
      sendToUser(
        userId,
        'Tienes un nuevo Match',
        'Abre UniMatch para conocer a tu nuevo match.',
        {type: 'match', matchId: event.params.matchId},
      ),
    ),
  );
});

export const notifyNewMessage = onDocumentCreated(
  'conversations/{conversationId}/messages/{messageId}',
  async (event) => {
    const message = event.data?.data();
    const senderId = message?.senderId;
    const text = message?.text;
    if (typeof senderId !== 'string' || typeof text !== 'string') {
      return;
    }

    const conversation = await db
      .collection('conversations')
      .doc(event.params.conversationId)
      .get();
    const participants = conversation.data()?.participants;
    if (!Array.isArray(participants)) {
      return;
    }

    const recipientId = participants.find((userId) => userId !== senderId);
    if (typeof recipientId !== 'string') {
      return;
    }

    const senderProfile = await db.collection('publicProfiles').doc(senderId).get();
    const senderName = senderProfile.data()?.name;
    await sendToUser(
      recipientId,
      typeof senderName === 'string' ? senderName : 'Nuevo mensaje',
      text.length > 120 ? `${text.substring(0, 117)}...` : text,
      {
        type: 'message',
        conversationId: event.params.conversationId,
        senderId,
      },
    );
  },
);

export const notifyAdminAction = onDocumentCreated(
  'adminActions/{actionId}',
  async (event) => {
    const action = event.data?.data();
    if (
      action?.action !== 'accountStatusChanged' ||
      typeof action.userId !== 'string' ||
      typeof action.newStatus !== 'string'
    ) {
      return;
    }

    const messages: Record<string, string> = {
      active: 'Tu cuenta fue reactivada.',
      suspended: 'Tu cuenta fue suspendida temporalmente.',
      banned: 'Tu cuenta fue baneada.',
      deleted: 'Tu cuenta fue eliminada.',
    };
    const body = messages[action.newStatus];
    if (body == null) {
      return;
    }

    await sendToUser(action.userId, 'Actualizacion de tu cuenta', body, {
      type: 'admin_action',
      status: action.newStatus,
    });
  },
);

export const syncAuthAccountStatus = onDocumentUpdated(
  'users/{userId}',
  async (event) => {
    const before = event.data?.before.data().accountStatus;
    const after = event.data?.after.data().accountStatus;
    if (typeof after !== 'string' || before === after) {
      return;
    }

    // Firestore triggers may arrive out of order. Never re-enable an account
    // based on an older "active" event after it was deleted or banned.
    const latest = await db.collection('users').doc(event.params.userId).get();
    const disabled = !latest.exists || latest.data()?.accountStatus !== 'active';
    try {
      await getAuth().updateUser(event.params.userId, {disabled});
      if (disabled) {
        await getAuth().revokeRefreshTokens(event.params.userId);
      }
    } catch (error) {
      if ((error as {code?: string}).code !== 'auth/user-not-found') throw error;
    }
  },
);
