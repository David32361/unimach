const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const { test } = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  collection, doc, getDocs, limit, orderBy, query, serverTimestamp,
  setDoc, startAfter, updateDoc, where,
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
