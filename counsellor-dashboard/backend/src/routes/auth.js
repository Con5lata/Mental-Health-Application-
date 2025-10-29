import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { getAuth, getFirestore } from '../config/firebase.js';
import { validate } from '../middleware/validation.js';
import { authenticateToken, requireActiveUser } from '../middleware/auth.js';
import { asyncHandler } from '../middleware/errorHandler.js';
import { successResponse, errorResponse, unauthorizedResponse } from '../utils/response.js';
import { loginSchema, registerSchema, updateUserSchema } from '../models/User.js';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Register new user
router.post('/register', validate(registerSchema), asyncHandler(async (req, res) => {
  const { email, password, name, title, department, phone } = req.body;

  try {
    const auth = getAuth();
    const db = getFirestore();

    // Check if user already exists
    try {
      await auth.getUserByEmail(email);
      return errorResponse(res, 'User already exists with this email', 409);
    } catch (error) {
      if (error.code !== 'auth/user-not-found') {
        throw error;
      }
    }

    // Create user in Firebase Auth
    const userRecord = await auth.createUser({
      email,
      password,
      displayName: name,
      disabled: false
    });

    // Set custom claims for role
    await auth.setCustomUserClaims(userRecord.uid, {
      role: 'counsellor'
    });

    // Create user document in Firestore
    const userData = {
      id: userRecord.uid,
      email,
      name,
      role: 'counsellor',
      title: title || '',
      department: department || '',
      phone: phone || '',
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
      preferences: {
        notifications: {
          newAppointments: true,
          urgentQuestions: true,
          flaggedJournals: true,
          systemUpdates: false,
          emailSummary: true
        },
        privacy: {
          profileVisibility: true,
          activityStatus: false,
          dataCollection: true
        }
      }
    };

    await db.collection('users').doc(userRecord.uid).set(userData);

    // Generate JWT token
    const token = jwt.sign(
      { uid: userRecord.uid, email, role: 'counsellor' },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    logger.info('User registered successfully', { userId: userRecord.uid, email });

    successResponse(res, {
      user: {
        id: userRecord.uid,
        email,
        name,
        role: 'counsellor',
        title,
        department,
        phone
      },
      token
    }, 'User registered successfully', 201);

  } catch (error) {
    logger.error('Registration error:', error);
    errorResponse(res, 'Registration failed', 500);
  }
}));

// Login user
router.post('/login', validate(loginSchema), asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  try {
    const auth = getAuth();
    const db = getFirestore();

    // Get user from Firebase Auth
    const userRecord = await auth.getUserByEmail(email);

    if (userRecord.disabled) {
      return errorResponse(res, 'Account is disabled', 403);
    }

    // Get user data from Firestore
    const userDoc = await db.collection('users').doc(userRecord.uid).get();
    
    if (!userDoc.exists) {
      return errorResponse(res, 'User data not found', 404);
    }

    const userData = userDoc.data();

    if (!userData.isActive) {
      return errorResponse(res, 'Account is inactive', 403);
    }

    // Update last login
    await db.collection('users').doc(userRecord.uid).update({
      lastLogin: new Date(),
      updatedAt: new Date()
    });

    // Generate JWT token
    const token = jwt.sign(
      { 
        uid: userRecord.uid, 
        email: userRecord.email, 
        role: userData.role 
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    logger.info('User logged in successfully', { userId: userRecord.uid, email });

    successResponse(res, {
      user: {
        id: userRecord.uid,
        email: userRecord.email,
        name: userData.name,
        role: userData.role,
        title: userData.title,
        department: userData.department,
        phone: userData.phone,
        preferences: userData.preferences
      },
      token
    }, 'Login successful');

  } catch (error) {
    logger.error('Login error:', error);
    
    if (error.code === 'auth/user-not-found') {
      return unauthorizedResponse(res, 'Invalid email or password');
    }
    
    if (error.code === 'auth/wrong-password') {
      return unauthorizedResponse(res, 'Invalid email or password');
    }

    errorResponse(res, 'Login failed', 500);
  }
}));

// Get current user profile
router.get('/me', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.user.uid).get();

    if (!userDoc.exists) {
      return errorResponse(res, 'User not found', 404);
    }

    const userData = userDoc.data();
    
    successResponse(res, {
      id: userData.id,
      email: userData.email,
      name: userData.name,
      role: userData.role,
      title: userData.title,
      department: userData.department,
      phone: userData.phone,
      profileImage: userData.profileImage,
      isActive: userData.isActive,
      lastLogin: userData.lastLogin,
      createdAt: userData.createdAt,
      updatedAt: userData.updatedAt,
      preferences: userData.preferences
    }, 'User profile retrieved successfully');

  } catch (error) {
    logger.error('Get profile error:', error);
    errorResponse(res, 'Failed to retrieve profile', 500);
  }
}));

// Update user profile
router.put('/me', authenticateToken, requireActiveUser, validate(updateUserSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const updateData = {
      ...req.body,
      updatedAt: new Date()
    };

    await db.collection('users').doc(req.user.uid).update(updateData);

    // Get updated user data
    const userDoc = await db.collection('users').doc(req.user.uid).get();
    const userData = userDoc.data();

    logger.info('User profile updated', { userId: req.user.uid });

    successResponse(res, {
      id: userData.id,
      email: userData.email,
      name: userData.name,
      role: userData.role,
      title: userData.title,
      department: userData.department,
      phone: userData.phone,
      profileImage: userData.profileImage,
      preferences: userData.preferences
    }, 'Profile updated successfully');

  } catch (error) {
    logger.error('Update profile error:', error);
    errorResponse(res, 'Failed to update profile', 500);
  }
}));

// Change password
router.put('/change-password', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return errorResponse(res, 'Current password and new password are required', 400);
  }

  if (newPassword.length < 6) {
    return errorResponse(res, 'New password must be at least 6 characters long', 400);
  }

  try {
    const auth = getAuth();
    
    // Update password in Firebase Auth
    await auth.updateUser(req.user.uid, {
      password: newPassword
    });

    logger.info('Password changed successfully', { userId: req.user.uid });

    successResponse(res, null, 'Password changed successfully');

  } catch (error) {
    logger.error('Change password error:', error);
    errorResponse(res, 'Failed to change password', 500);
  }
}));

// Logout (client-side token removal)
router.post('/logout', authenticateToken, asyncHandler(async (req, res) => {
  logger.info('User logged out', { userId: req.user.uid });
  successResponse(res, null, 'Logout successful');
}));

// Refresh token
router.post('/refresh', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.user.uid).get();

    if (!userDoc.exists || !userDoc.data().isActive) {
      return errorResponse(res, 'User not found or inactive', 404);
    }

    const userData = userDoc.data();

    // Generate new JWT token
    const token = jwt.sign(
      { 
        uid: req.user.uid, 
        email: req.user.email, 
        role: userData.role 
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );

    successResponse(res, { token }, 'Token refreshed successfully');

  } catch (error) {
    logger.error('Refresh token error:', error);
    errorResponse(res, 'Failed to refresh token', 500);
  }
}));

export default router;
