
import jwt from 'jsonwebtoken';
import { getAuth } from '../config/firebase.js';
import { logger } from '../utils/logger.js';

export const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      
      return res.status(401).json({
        error: 'Access denied',
        message: 'No token provided'
      });
    }

    // Verify JWT token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Get user from Firebase Auth
    const auth = getAuth();
    const userRecord = await auth.getUser(decoded.uid);
    
    if (!userRecord) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Invalid token'
      });
    }

    // Add user info to request
    req.user = {
      uid: userRecord.uid,
      email: userRecord.email,
      name: userRecord.displayName || userRecord.email,
      role: userRecord.customClaims?.role || 'counsellor',
      isActive: !userRecord.disabled
    };

    next();
  } catch (error) {
    logger.error('Authentication error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Token expired'
      });
    }

    return res.status(500).json({
      error: 'Authentication failed',
      message: 'Internal server error'
    });
  }
};

export const requireRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Authentication required'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Access denied',
        message: 'Insufficient permissions'
      });
    }

    next();
  };
};

export const requireActiveUser = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      error: 'Access denied',
      message: 'Authentication required'
    });
  }

  if (!req.user.isActive) {
    return res.status(403).json({
      error: 'Account disabled',
      message: 'Your account has been disabled'
    });
  }

  next();
};

export const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const auth = getAuth();
      const userRecord = await auth.getUser(decoded.uid);
      
      if (userRecord) {
        req.user = {
          uid: userRecord.uid,
          email: userRecord.email,
          name: userRecord.displayName || userRecord.email,
          role: userRecord.customClaims?.role || 'counsellor',
          isActive: !userRecord.disabled
        };
      }
    }

    next();
  } catch (error) {
    // If token is invalid, continue without user info
    next();
  }
};
