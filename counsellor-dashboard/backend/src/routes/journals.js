import express from 'express';
import { getFirestore } from '../config/firebase.js';
import { validate, validateQuery } from '../middleware/validation.js';
import { authenticateToken, requireActiveUser, requireRole } from '../middleware/auth.js';
import { asyncHandler } from '../middleware/errorHandler.js';
import { successResponse, errorResponse, notFoundResponse, paginatedResponse } from '../utils/response.js';
import { journalSchema, updateJournalSchema, journalQuerySchema } from '../models/Journal.js';
import { calculatePagination, sortArray, filterArray } from '../utils/helpers.js';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Get all journal entries with filtering and pagination
router.get('/', authenticateToken, requireActiveUser, validateQuery(journalQuerySchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const {
      studentId,
      status,
      priority,
      mood,
      isFlagged,
      dateFrom,
      dateTo,
      search,
      page,
      limit,
      sortBy,
      sortOrder
    } = req.query;

    let query = db.collection('journals');

    // Apply filters
    if (studentId) query = query.where('studentId', '==', studentId);
    if (status) query = query.where('status', '==', status);
    if (priority) query = query.where('priority', '==', priority);
    if (mood) query = query.where('mood', '==', mood);
    if (isFlagged !== undefined) query = query.where('isFlagged', '==', isFlagged === 'true');
    if (dateFrom) query = query.where('createdAt', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('createdAt', '<=', new Date(dateTo));

    const snapshot = await query.get();
    let journals = [];

    snapshot.forEach(doc => {
      journals.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // Apply search filter
    if (search) {
      journals = journals.filter(journal => 
        journal.title.toLowerCase().includes(search.toLowerCase()) ||
        journal.content.toLowerCase().includes(search.toLowerCase())
      );
    }

    // Apply client-side filtering and sorting
    journals = filterArray(journals, req.query);
    journals = sortArray(journals, sortBy, sortOrder);

    // Calculate pagination
    const total = journals.length;
    const pagination = calculatePagination(page, limit, total);
    const paginatedJournals = journals.slice(
      pagination.offset,
      pagination.offset + pagination.limit
    );

    logger.info('Journal entries retrieved', { 
      userId: req.user.uid, 
      count: paginatedJournals.length,
      total 
    });

    paginatedResponse(res, paginatedJournals, pagination, 'Journal entries retrieved successfully');

  } catch (error) {
    logger.error('Get journal entries error:', error);
    errorResponse(res, 'Failed to retrieve journal entries', 500);
  }
}));

// Get journal entry by ID
router.get('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const journalDoc = await db.collection('journals').doc(req.params.id).get();

    if (!journalDoc.exists) {
      return notFoundResponse(res, 'Journal entry not found');
    }

    const journal = {
      id: journalDoc.id,
      ...journalDoc.data()
    };

    successResponse(res, journal, 'Journal entry retrieved successfully');

  } catch (error) {
    logger.error('Get journal entry error:', error);
    errorResponse(res, 'Failed to retrieve journal entry', 500);
  }
}));

// Create new journal entry
router.post('/', authenticateToken, requireActiveUser, validate(journalSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const journalData = {
      ...req.body,
      createdBy: req.user.uid,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const docRef = await db.collection('journals').add(journalData);

    logger.info('Journal entry created', { 
      journalId: docRef.id, 
      userId: req.user.uid 
    });

    successResponse(res, {
      id: docRef.id,
      ...journalData
    }, 'Journal entry created successfully', 201);

  } catch (error) {
    logger.error('Create journal entry error:', error);
    errorResponse(res, 'Failed to create journal entry', 500);
  }
}));

// Update journal entry
router.put('/:id', authenticateToken, requireActiveUser, validate(updateJournalSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const journalDoc = await db.collection('journals').doc(req.params.id).get();

    if (!journalDoc.exists) {
      return notFoundResponse(res, 'Journal entry not found');
    }

    const journal = journalDoc.data();

    // Check if user has permission to update this journal entry
    if (req.user.role !== 'admin' && journal.createdBy !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    const updateData = {
      ...req.body,
      updatedAt: new Date()
    };

    await db.collection('journals').doc(req.params.id).update(updateData);

    // Get updated journal entry
    const updatedDoc = await db.collection('journals').doc(req.params.id).get();
    const updatedJournal = {
      id: updatedDoc.id,
      ...updatedDoc.data()
    };

    logger.info('Journal entry updated', { 
      journalId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, updatedJournal, 'Journal entry updated successfully');

  } catch (error) {
    logger.error('Update journal entry error:', error);
    errorResponse(res, 'Failed to update journal entry', 500);
  }
}));

// Delete journal entry
router.delete('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const journalDoc = await db.collection('journals').doc(req.params.id).get();

    if (!journalDoc.exists) {
      return notFoundResponse(res, 'Journal entry not found');
    }

    const journal = journalDoc.data();

    // Check if user has permission to delete this journal entry
    if (req.user.role !== 'admin' && journal.createdBy !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    await db.collection('journals').doc(req.params.id).delete();

    logger.info('Journal entry deleted', { 
      journalId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, null, 'Journal entry deleted successfully');

  } catch (error) {
    logger.error('Delete journal entry error:', error);
    errorResponse(res, 'Failed to delete journal entry', 500);
  }
}));

// Get journal statistics
router.get('/stats/overview', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const { dateFrom, dateTo } = req.query;

    let query = db.collection('journals');

    if (dateFrom) query = query.where('createdAt', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('createdAt', '<=', new Date(dateTo));

    const snapshot = await query.get();
    const journals = [];

    snapshot.forEach(doc => {
      journals.push(doc.data());
    });

    // Calculate statistics
    const stats = {
      total: journals.length,
      flagged: journals.filter(journal => journal.isFlagged).length,
      reviewed: journals.filter(journal => journal.status === 'reviewed').length,
      pending: journals.filter(journal => journal.status === 'pending').length,
      byMood: {
        'very-positive': journals.filter(journal => journal.mood === 'very-positive').length,
        'positive': journals.filter(journal => journal.mood === 'positive').length,
        'neutral': journals.filter(journal => journal.mood === 'neutral').length,
        'negative': journals.filter(journal => journal.mood === 'negative').length,
        'very-negative': journals.filter(journal => journal.mood === 'very-negative').length
      },
      byPriority: {
        low: journals.filter(journal => journal.priority === 'low').length,
        medium: journals.filter(journal => journal.priority === 'medium').length,
        high: journals.filter(journal => journal.priority === 'high').length,
        urgent: journals.filter(journal => journal.priority === 'urgent').length
      },
      thisWeek: journals.filter(journal => {
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        return new Date(journal.createdAt) >= weekAgo;
      }).length
    };

    successResponse(res, stats, 'Journal statistics retrieved successfully');

  } catch (error) {
    logger.error('Get journal stats error:', error);
    errorResponse(res, 'Failed to retrieve journal statistics', 500);
  }
}));

// Flag journal entry
router.patch('/:id/flag', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  const { flagReason, priority } = req.body;

  try {
    const db = getFirestore();
    const journalDoc = await db.collection('journals').doc(req.params.id).get();

    if (!journalDoc.exists) {
      return notFoundResponse(res, 'Journal entry not found');
    }

    const updateData = {
      isFlagged: true,
      flagReason: flagReason || 'Flagged for review',
      priority: priority || 'medium',
      status: 'flagged',
      updatedAt: new Date()
    };

    await db.collection('journals').doc(req.params.id).update(updateData);

    logger.info('Journal entry flagged', { 
      journalId: req.params.id, 
      userId: req.user.uid,
      flagReason 
    });

    successResponse(res, { isFlagged: true, flagReason }, 'Journal entry flagged successfully');

  } catch (error) {
    logger.error('Flag journal entry error:', error);
    errorResponse(res, 'Failed to flag journal entry', 500);
  }
}));

// Review journal entry
router.patch('/:id/review', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  const { counsellorNotes, status } = req.body;

  try {
    const db = getFirestore();
    const journalDoc = await db.collection('journals').doc(req.params.id).get();

    if (!journalDoc.exists) {
      return notFoundResponse(res, 'Journal entry not found');
    }

    const updateData = {
      status: status || 'reviewed',
      counsellorNotes: counsellorNotes || '',
      reviewedBy: req.user.uid,
      reviewedAt: new Date(),
      isFlagged: false,
      updatedAt: new Date()
    };

    await db.collection('journals').doc(req.params.id).update(updateData);

    logger.info('Journal entry reviewed', { 
      journalId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, { status: updateData.status }, 'Journal entry reviewed successfully');

  } catch (error) {
    logger.error('Review journal entry error:', error);
    errorResponse(res, 'Failed to review journal entry', 500);
  }
}));

export default router;
