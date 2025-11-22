const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const serviceAccount = require('./m-health-4cab9-firebase-adminsdk-fbsvc-53b8049964.json');

const app = express();
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin (The Master Key)
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

app.post('/bridge-auth', async (req, res) => {
  const { supabaseUserId, email } = req.body;

  try {
    // TRICK: You can force the Firebase UID to match the Supabase UID
    // or map it to an existing Firebase User ID you already have data for.
    const firebaseUid = supabaseUserId; 

    // Mint a custom Firebase token
    const customToken = await admin.auth().createCustomToken(firebaseUid, {
      email: email,
      premiumAccount: true // You can even add custom claims here!
    });

    console.log(`Minted token for user: ${email}`);
    res.json({ firebaseToken: customToken });

  } catch (error) {
    console.error('Error minting token:', error);
    res.status(500).send('Auth Bridge Failed');
  }
});

app.listen(3000, () => console.log('Authentication Bridge running on port 3000'));