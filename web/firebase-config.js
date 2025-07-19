// Import the functions you need from the SDKs you need
import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCNSfTPPQT4qlNCQCKVi-ouyjf_SOsP1uc",
  authDomain: "fypt1-335a1.firebaseapp.com",
  projectId: "fypt1-335a1",
  storageBucket: "fypt1-335a1.firebasestorage.app",
  messagingSenderId: "693679137449",
  appId: "1:693679137449:web:36e80b61a0ac0a70f1bfb8"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);

export default app;
