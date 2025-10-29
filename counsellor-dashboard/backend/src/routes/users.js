import express from 'express';
import { getFirestore } from '../config/firebase.js';
import { validate, validateQuery } from '../middleware/validation.js';
import { authenticateToken, requireActiveUser, requireRole } from '../middleware/auth.js';
import { asyncHandler } from '../middleware/errorHandler.js';
import { successResponse, errorResponse, notFoundResponse, paginatedResponse } from '../utils/response.js';
import { updateUserSchema } from '../models/User.js';
import { calculatePagination, sortArray, filterArray } from '../utils/helpers.js';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Get all users (admin only)
router.get('/', authenticateToken, requireActiveUser, requireRole(['admin']), validateQuery(Joi.object({
  role: Joi.string().valid('counsellor', 'admin', 'student').optional(),
  isActive: Joi.boolean().optional(),
  search: Joi.string().max(100).optional(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10),
  sortBy: Joi.string().valid('name', 'email', 'createdAt', 'lastLogin').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
})), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const { role, isActive, search, page, limit, sortBy, sortOrder } = req.query;

    let query = db.collection('users');

    // Apply filters
    if (role) query = query.where('role', '==', role);
    if (isActive !== undefined) query = query.where('isActive', '==', isActive);

    const snapshot = await query.get();
    let users = [];

    snapshot.forEach(doc => {
      users.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // Apply search filter
    if (search) {
      users = users.filter(user => 
        user.name.toLowerCase().includes(search.toLowerCase()) ||
        user.email.toLowerCase().includes(search.toLowerCase()) ||
        (user.title && user.title.toLowerCase().includes(search.toLowerCase())) ||
        (user.department && user.department.toLowerCase().includes(search.toLowerCase()))
      );
    }

    // Apply client-side filtering and sorting
    users = filterArray(users, req.query);
    users = sortArray(users, sortBy, sortOrder);

    // Calculate pagination
    const total = users.length;
    const pagination = calculatePagination(page, limit, total);
    const paginatedUsers = users.slice(
      pagination.offset,
      pagination.offset + pagination.limit
    );

    // Remove sensitive information
    const sanitizedUsers = paginatedUsers.map(user => ({
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      title: user.title,
      department: user.department,
      phone: user.phone,
      profileImage: user.profileImage,
      isActive: user.isActive,
      lastLogin: user.lastLogin,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt
    }));

    logger.info('Users retrieved', { 
      userId: req.user.uid, 
      count: sanitizedUsers.length,
      total 
    });

    paginatedResponse(res, sanitizedUsers, pagination, 'Users retrieved successfully');

  } catch (error) {
    logger.error('Get users error:', error);
    errorResponse(res, 'Failed to retrieve users', 500);
  }
}));

// Get user by ID
router.get('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.params.id).get();

    if (!userDoc.exists) {
      return notFoundResponse(res, 'User not found');
    }

    const user = userDoc.data();

    // Check if user has permission to view this user's data
    if (req.user.role !== 'admin' && req.user.uid !== req.params.id) {
      return errorResponse(res, 'Access denied', 403);
    }

    // Remove sensitive information for non-admin users
    const sanitizedUser = {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      title: user.title,
      department: user.department,
      phone: user.phone,
      profileImage: user.profileImage,
      isActive: user.isActive,
      lastLogin: user.lastLogin,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      preferences: user.preferences
    };

    successResponse(res, sanitizedUser, 'User retrieved successfully');

  } catch (error) {
    logger.error('Get user error:', error);
    errorResponse(res, 'Failed to retrieve user', 500);
  }
}));

// Update user (admin only or own profile)
router.put('/:id', authenticateToken, requireActiveUser, validate(updateUserSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.params.id).get();

    if (!userDoc.exists) {
      return notFoundResponse(res, 'User not found');
    }

    // Check if user has permission to update this user
    if (req.user.role !== 'admin' && req.user.uid !== req.params.id) {
      return errorResponse(res, 'Access denied', 403);
    }

    const updateData = {
      ...req.body,
      updatedAt: new Date()
    };

    await db.collection('users').doc(req.params.id).update(updateData);

    // Get updated user data
    const updatedDoc = await db.collection('users').doc(req.params.id).get();
    const updatedUser = updatedDoc.data();

    logger.info('User updated', { 
      userId: req.params.id, 
      updatedBy: req.user.uid 
    });

    successResponse(res, {
      id: updatedUser.id,
      email: updatedUser.email,
      name: updatedUser.name,
      role: updatedUser.role,
      title: updatedUser.title,
      department: updatedUser.department,
      phone: updatedUser.phone,
      profileImage: updatedUser.profileImage,
      preferences: updatedUser.preferences
    }, 'User updated successfully');

  } catch (error) {
    logger.error('Update user error:', error);
    errorResponse(res, 'Failed to update user', 500);
  }
}));

// Deactivate user (admin only)
router.patch('/:id/deactivate', authenticateToken, requireActiveUser, requireRole(['admin']), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.params.id).get();

    if (!userDoc.exists) {
      return notFoundResponse(res, 'User not found');
    }

    // Prevent deactivating own account
    if (req.user.uid === req.params.id) {
      return errorResponse(res, 'Cannot deactivate your own account', 400);
    }

    await db.collection('users').doc(req.params.id).update({
      isActive: false,
      updatedAt: new Date()
    });

    logger.info('User deactivated', { 
      userId: req.params.id, 
      deactivatedBy: req.user.uid 
    });

    successResponse(res, { isActive: false }, 'User deactivated successfully');

  } catch (error) {
    logger.error('Deactivate user error:', error);
    errorResponse(res, 'Failed to deactivate user', 500);
  }
}));

// Activate user (admin only)
router.patch('/:id/activate', authenticateToken, requireActiveUser, requireRole(['admin']), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.params.id).get();

    if (!userDoc.exists) {
      return notFoundResponse(res, 'User not found');
    }

    await db.collection('users').doc(req.params.id).update({
      isActive: true,
      updatedAt: new Date()
    });

    logger.info('User activated', { 
      userId: req.params.id, 
      activatedBy: req.user.uid 
    });

    successResponse(res, { isActive: true }, 'User activated successfully');

  } catch (error) {
    logger.error('Activate user error:', error);
    errorResponse(res, 'Failed to activate user', 500);
  }
}));

// Delete user (admin only)
router.delete('/:id', authenticateToken, requireActiveUser, requireRole(['admin']), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(req.params.id).get();

    if (!userDoc.exists) {
      return notFoundResponse(res, 'User not found');
    }

    // Prevent deleting own account
    if (req.user.uid === req.params.id) {
      return errorResponse(res, 'Cannot delete your own account', 400);
    }

    await db.collection('users').doc(req.params.id).delete();

    logger.info('User deleted', { 
      userId: req.params.id, 
      deletedBy: req.user.uid 
    });

    successResponse(res, null, 'User deleted successfully');

  } catch (error) {
    logger.error('Delete user error:', error);
    errorResponse(res, 'Failed to delete user', 500);
  }
}));

// Get user statistics
router.get('/stats/overview', authenticateToken, requireActiveUser, requireRole(['admin']), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const { dateFrom, dateTo } = req.query;

    let query = db.collection('users');

    if (dateFrom) query = query.where('createdAt', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('createdAt', '<=', new Date(dateTo));

    const snapshot = await query.get();
    const users = [];

    snapshot.forEach(doc => {
      users.push(doc.data());
    });

    // Calculate statistics
    const stats = {
      total: users.length,
      active: users.filter(u => u.isActive).length,
      inactive: users.filter(u => !u.isActive).length,
      byRole: {
        counsellor: users.filter(u => u.role === 'counsellor').length,
        admin: users.filter(u => u.role === 'admin').length,
        student: users.filter(u => u.role === 'student').length
      },
      newThisMonth: users.filter(u => {
        const monthAgo = new Date();
        monthAgo.setMonth(monthAgo.getMonth() - 1);
        return new Date(u.createdAt) >= monthAgo;
      }).length,
      withRecentActivity: users.filter(u => {
        if (!u.lastLogin) return false;
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        return new Date(u.lastLogin) >= weekAgo;
      }).length
    };

    successResponse(res, stats, 'User statistics retrieved successfully');

  } catch (error) {
    logger.error('Get user stats error:', error);
    errorResponse(res, 'Failed to retrieve user statistics', 500);
  }
}));

export default router;
