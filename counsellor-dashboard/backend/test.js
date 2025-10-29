import dotenv from 'dotenv';
dotenv.config();

console.log('Environment variables loaded:');
console.log('FIREBASE_PROJECT_ID:', process.env.FIREBASE_PROJECT_ID);
console.log('FIREBASE_PRIVATE_KEY:', process.env.FIREBASE_PRIVATE_KEY ? 'Present' : 'Missing');

try {
  import('./src/config/firebase.js').then(() => {
    console.log('Firebase config loaded successfully');
  }).catch(err => {
    console.error('Firebase config error:', err.message);
  });
} catch (err) {
  console.error('Import error:', err.message);
}