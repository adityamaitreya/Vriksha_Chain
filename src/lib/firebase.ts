import { initializeApp, getApps, FirebaseApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider, browserLocalPersistence, setPersistence } from 'firebase/auth';
import { getDatabase, Database } from 'firebase/database';

let app: FirebaseApp;

const firebaseConfig = {
    apiKey: "AIzaSyAB6lo7ZKQpSAf-CS9jY1HxG-OACZo21-4",
    authDomain: "vriksha-chain.firebaseapp.com",
    databaseURL: "https://vriksha-chain-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "vriksha-chain",
    storageBucket: "vriksha-chain.firebasestorage.app",
    messagingSenderId: "263466607025",
    appId: "1:263466607025:web:31d3334ac56f7d13fb1d90",
    measurementId: "G-17EFVB0LLX"
  };
  

if (!getApps().length) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApps()[0]!;
}

const auth = getAuth(app);
setPersistence(auth, browserLocalPersistence).catch(() => {
  /* ignore persistence errors; defaults will apply */
});

const googleProvider = new GoogleAuthProvider();
const database = getDatabase(app);

export { app, auth, googleProvider, database };


