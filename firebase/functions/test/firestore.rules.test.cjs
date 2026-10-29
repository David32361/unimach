const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const { test } = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  collection, doc, getDoc, getDocs, limit, orderBy, query, serverTimestamp,
  setDoc, startAfter, updateDoc, where, writeBatch,
} = require('firebase/firestore');

test('profile rules require three tastes and three anime genres', async () => {
  const environment = await initializeTestEnvironment({
    projectId: 'demo-unimatch',
    firestore: {
      rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8'),
    },
  });

  try {
    const database = environment.authenticatedContext('alice', {
      email: 'alice@example.com',
      email_verified: true,
    }).firestore();
    const privateProfile = doc(database, 'users/alice');
    const publicProfile = doc(database, 'publicProfiles/alice');
    const common = {
      uid: 'alice',
      name: 'Alice',
      age: 21,
      gender: 'Mujer',
      university: 'Universidad Autónoma del Estado de Hidalgo',
      career: 'Ingeniería en Sistemas Computacionales',
      description: 'Estudiante',
      avatarId: 0,
      interests: [],
      animeGenres: [],
      accountStatus: 'active',
      createdAt: serverTimestamp(),
    };

    await assertSucceeds(setDoc(privateProfile, {
      ...common,
      email: 'alice@example.com',
      lastActivity: serverTimestamp(),
      profileComplete: true,
    }));
    await assertSucceeds(setDoc(publicProfile, {
      ...common,
      updatedAt: serverTimestamp(),
    }));

    const twoTastes = {
      interests: ['anime', 'music_rock'],
      animeGenres: ['anime_action', 'anime_comedy', 'anime_romance'],
    };
    await assertFails(updateDoc(privateProfile, twoTastes));

    const twoGenres = {
      interests: ['anime', 'music_rock', 'books_fantasy'],
      animeGenres: ['anime_action', 'anime_comedy'],
    };
    await assertFails(updateDoc(publicProfile, twoGenres));

    const valid = {
      interests: ['anime', 'music_rock', 'books_fantasy'],
      animeGenres: ['anime_action', 'anime_comedy', 'anime_romance'],
    };
    await assertSucceeds(updateDoc(privateProfile, valid));
    await assertSucceeds(updateDoc(publicProfile, valid));

    await assertFails(updateDoc(privateProfile, {
      interests: ['anime', 'anime', 'music_rock'],
      animeGenres: valid.animeGenres,
    }));
    await assertFails(updateDoc(publicProfile, {
      interests: valid.interests,
      animeGenres: ['anime_action', 'anime_action', 'anime_comedy'],
    }));

    await assertSucceeds(updateDoc(privateProfile, {
      interests: ['movies_action', 'music_rock', 'books_fantasy'],
      animeGenres: [],
    }));

    const legacyDatabase = environment.authenticatedContext('bob', {
      email: 'bob@example.com',
      email_verified: true,
    }).firestore();
    const legacyCommon = { ...common };
    delete legacyCommon.animeGenres;
    const legacyProfile = doc(legacyDatabase, 'users/bob');
    await assertSucceeds(setDoc(legacyProfile, {
      ...legacyCommon,
      uid: 'bob',
      email: 'bob@example.com',
      lastActivity: serverTimestamp(),
      profileComplete: true,
    }));
    await assertSucceeds(updateDoc(legacyProfile, {
      interests: ['movies_action', 'music_rock', 'books_fantasy'],
    }));
    await assertSucceeds(setDoc(doc(legacyDatabase, 'publicProfiles/bob'), {
      ...legacyCommon,
      uid: 'bob',
      updatedAt: serverTimestamp(),
    }));

    const profiles = collection(database, 'publicProfiles');
    const activeProfiles = query(
      profiles,
      where('accountStatus', '==', 'active'),
      orderBy('createdAt', 'desc'),
      limit(1),
    );
    const firstPage = await assertSucceeds(getDocs(activeProfiles));
    const nextPage = await assertSucceeds(getDocs(query(
      profiles,
      where('accountStatus', '==', 'active'),
      orderBy('createdAt', 'desc'),
      startAfter(firstPage.docs[0]),
      limit(1),
    )));
    if (firstPage.size !== 1 || nextPage.size !== 1 ||
        firstPage.docs[0].id === nextPage.docs[0].id) {
      throw new Error('Discovery pagination did not return distinct profiles.');
    }
  } finally {
    await environment.cleanup();
  }
});

test('unverified identities cannot access profiles or send interactions', async () => {
  const environment = await initializeTestEnvironment({
    projectId: 'demo-unimatch-verification',
    firestore: {
      rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8'),
    },
  });
  try {
    await environment.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'users/alice'), {
        uid: 'alice', accountStatus: 'active', email: 'alice@example.com',
      });
      await setDoc(doc(context.firestore(), 'users/bob'), {
        uid: 'bob', accountStatus: 'active',
      });
    });
    const unverified = environment.authenticatedContext('alice', {
      email: 'alice@example.com', email_verified: false,
    }).firestore();
    await assertFails(getDoc(doc(unverified, 'users/alice')));
    await assertFails(updateDoc(doc(unverified, 'users/alice'), {
      emailVerified: true,
    }));
    await assertFails(setDoc(doc(unverified, 'likes/alice_bob'), {
      senderId: 'alice', receiverId: 'bob', createdAt: serverTimestamp(),
    }));
    await assertFails(getDocs(query(collection(unverified, 'publicProfiles'),
      where('accountStatus', '==', 'active'), limit(20))));
    const verified = environment.authenticatedContext('alice', {
      email: 'alice@example.com', email_verified: true,
    }).firestore();
    await assertSucceeds(getDoc(doc(verified, 'users/alice')));
  } finally {
    await environment.cleanup();
  }
});

test('only mutual likes can atomically create a match and its conversation', async () => {
  const environment = await initializeTestEnvironment({
    projectId: 'demo-unimatch-matches',
    firestore: {rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8')},
  });
  try {
    await environment.withSecurityRulesDisabled(async (context) => {
      for (const uid of ['alice', 'bob', 'mallory']) {
        await setDoc(doc(context.firestore(), `users/${uid}`), {accountStatus: 'active'});
      }
    });
    const alice = environment.authenticatedContext('alice', {email_verified: true}).firestore();
    const bob = environment.authenticatedContext('bob', {email_verified: true}).firestore();
    // A client transaction reads the absent conversation before any writes.
    await assertSucceeds(getDoc(doc(bob, 'conversations/alice_bob')));
    const outsider = environment.authenticatedContext('mallory', {email_verified: true}).firestore();
    await assertFails(getDoc(doc(outsider, 'conversations/alice_bob')));
    const match = {
      matchId: 'alice_bob', user1: 'alice', user2: 'bob',
      userIds: ['alice', 'bob'], status: 'active', createdAt: serverTimestamp(),
    };
    const conversation = {
      conversationId: 'alice_bob', matchId: 'alice_bob', participants: ['alice', 'bob'],
      lastMessage: '', lastSenderId: '', lastMessageAt: serverTimestamp(),
      createdAt: serverTimestamp(),
    };
    await assertSucceeds(setDoc(doc(alice, 'likes/alice_bob'), {
      senderId: 'alice', receiverId: 'bob', createdAt: serverTimestamp(),
    }));
    await assertFails(setDoc(doc(alice, 'matches/alice_bob'), match));
    const batch = writeBatch(bob);
    batch.set(doc(bob, 'likes/bob_alice'), {
      senderId: 'bob', receiverId: 'alice', createdAt: serverTimestamp(),
    });
    batch.set(doc(bob, 'matches/alice_bob'), match);
    batch.set(doc(bob, 'conversations/alice_bob'), conversation);
    await assertSucceeds(batch.commit());
    await assertSucceeds(getDoc(doc(alice, 'conversations/alice_bob')));
    await assertFails(updateDoc(doc(alice, 'conversations/alice_bob'), {
      participants: ['alice', 'mallory'],
    }));
    const mallory = environment.authenticatedContext('mallory', {email_verified: true}).firestore();
    await assertFails(getDoc(doc(mallory, 'conversations/alice_bob')));
  } finally {
    await environment.cleanup();
  }
});

test('sanction notices are private and clients cannot forge permanent deletion jobs', async () => {
  const environment = await initializeTestEnvironment({
    projectId: 'demo-unimatch-notices',
    firestore: {rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8')},
  });
  try {
    await environment.withSecurityRulesDisabled(async context => {
      await setDoc(doc(context.firestore(), 'users/alice'), {accountStatus:'active'});
    });
    const admin = environment.authenticatedContext('admin', {email_verified:true, admin:true}).firestore();
    const alice = environment.authenticatedContext('alice', {email_verified:true}).firestore();
    const other = environment.authenticatedContext('other', {email_verified:true}).firestore();
    const notice = {
      status:'banned', reason:'Incumplimiento de normas', message:'Aviso de cuenta y apelación',
      supportEmail:'unimatch7@gmail.com', issuedAt:serverTimestamp(),
    };
    await assertFails(setDoc(doc(admin, 'accountNotices/alice'), notice));
    const batch = writeBatch(admin);
    batch.update(doc(admin, 'users/alice'), {accountStatus:'banned'});
    batch.set(doc(admin, 'accountNotices/alice'), notice);
    await assertSucceeds(batch.commit());
    await assertSucceeds(getDoc(doc(alice, 'accountNotices/alice')));
    await assertFails(getDoc(doc(other, 'accountNotices/alice')));
    await assertFails(getDocs(collection(alice, 'accountNotices')));
    await assertFails(setDoc(doc(alice, 'accountNotices/alice'), {...notice, status:'active'}));
    await assertFails(setDoc(doc(alice, 'accountDeletionJobs/alice'), {status:'pending'}));
    await assertFails(setDoc(doc(admin, 'accountDeletionJobs/alice'), {status:'pending'}));
    await assertFails(updateDoc(doc(admin, 'users/alice'), {accountStatus:'deleted'}));
  } finally { await environment.cleanup(); }
});
