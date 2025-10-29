import express from 'express';
import { getFirestore } from '../config/firebase.js';
import { validate, validateQuery } from '../middleware/validation.js';
import { authenticateToken, requireActiveUser, optionalAuth } from '../middleware/auth.js';
import { asyncHandler } from '../middleware/errorHandler.js';
import { successResponse, errorResponse, notFoundResponse, paginatedResponse } from '../utils/response.js';
import { questionSchema, updateQuestionSchema, answerSchema, qaQuerySchema } from '../models/QA.js';
import { calculatePagination, sortArray, filterArray } from '../utils/helpers.js';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Get all questions with filtering and pagination
router.get('/', optionalAuth, validateQuery(qaQuerySchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const {
      category,
      status,
      priority,
      answeredBy,
      dateFrom,
      dateTo,
      search,
      page,
      limit,
      sortBy,
      sortOrder
    } = req.query;

    let query = db.collection('qna');

    // Apply filters
    if (category) query = query.where('category', '==', category);
    if (status) query = query.where('status', '==', status);
    if (priority) query = query.where('priority', '==', priority);
    if (answeredBy) query = query.where('answeredBy', '==', answeredBy);
    if (dateFrom) query = query.where('createdAt', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('createdAt', '<=', new Date(dateTo));

    const snapshot = await query.get();
    let questions = [];

    snapshot.forEach(doc => {
      questions.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // Apply search filter
    if (search) {
      questions = questions.filter(question => 
        question.question.toLowerCase().includes(search.toLowerCase()) ||
        (question.response && question.response.toLowerCase().includes(search.toLowerCase()))
      );
    }

    // Apply client-side filtering and sorting
    questions = filterArray(questions, req.query);
    questions = sortArray(questions, sortBy, sortOrder);

    // Calculate pagination
    const total = questions.length;
    const pagination = calculatePagination(page, limit, total);
    const paginatedQuestions = questions.slice(
      pagination.offset,
      pagination.offset + pagination.limit
    );

    logger.info('Questions retrieved', { 
      userId: req.user?.uid || 'anonymous', 
      count: paginatedQuestions.length,
      total 
    });

    paginatedResponse(res, paginatedQuestions, pagination, 'Questions retrieved successfully');

  } catch (error) {
    logger.error('Get questions error:', error);
    errorResponse(res, 'Failed to retrieve questions', 500);
  }
}));

// Get question by ID
router.get('/:id', optionalAuth, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const questionDoc = await db.collection('qna').doc(req.params.id).get();

    if (!questionDoc.exists) {
      return notFoundResponse(res, 'Question not found');
    }

    const question = {
      id: questionDoc.id,
      ...questionDoc.data()
    };

    // Increment view count
    await db.collection('qna').doc(req.params.id).update({
      views: (question.views || 0) + 1
    });

    question.views = (question.views || 0) + 1;

    successResponse(res, question, 'Question retrieved successfully');

  } catch (error) {
    logger.error('Get question error:', error);
    errorResponse(res, 'Failed to retrieve question', 500);
  }
}));

// Create new question
router.post('/', optionalAuth, validate(questionSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const questionData = {
      ...req.body,
      studentId: req.user?.uid || null,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const docRef = await db.collection('qna').add(questionData);

    logger.info('Question created', { 
      questionId: docRef.id, 
      userId: req.user?.uid || 'anonymous' 
    });

    successResponse(res, {
      id: docRef.id,
      ...questionData
    }, 'Question created successfully', 201);

  } catch (error) {
    logger.error('Create question error:', error);
    errorResponse(res, 'Failed to create question', 500);
  }
}));

// Update question
router.put('/:id', authenticateToken, requireActiveUser, validate(updateQuestionSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const questionDoc = await db.collection('qna').doc(req.params.id).get();

    if (!questionDoc.exists) {
      return notFoundResponse(res, 'Question not found');
    }

    const question = questionDoc.data();

    // Check if user has permission to update this question
    if (req.user.role !== 'admin' && question.studentId !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    const updateData = {
      ...req.body,
      updatedAt: new Date()
    };

    await db.collection('qna').doc(req.params.id).update(updateData);

    // Get updated question
    const updatedDoc = await db.collection('qna').doc(req.params.id).get();
    const updatedQuestion = {
      id: updatedDoc.id,
      ...updatedDoc.data()
    };

    logger.info('Question updated', { 
      questionId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, updatedQuestion, 'Question updated successfully');

  } catch (error) {
    logger.error('Update question error:', error);
    errorResponse(res, 'Failed to update question', 500);
  }
}));

// Delete question
router.delete('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const questionDoc = await db.collection('qna').doc(req.params.id).get();

    if (!questionDoc.exists) {
      return notFoundResponse(res, 'Question not found');
    }

    const question = questionDoc.data();

    // Check if user has permission to delete this question
    if (req.user.role !== 'admin' && question.studentId !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    await db.collection('qna').doc(req.params.id).delete();

    logger.info('Question deleted', { 
      questionId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, null, 'Question deleted successfully');

  } catch (error) {
    logger.error('Delete question error:', error);
    errorResponse(res, 'Failed to delete question', 500);
  }
}));

// Answer question
router.post('/:id/answer', authenticateToken, requireActiveUser, validate(answerSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const questionDoc = await db.collection('qna').doc(req.params.id).get();

    if (!questionDoc.exists) {
      return notFoundResponse(res, 'Question not found');
    }

    const { response, isPublic, counsellorNotes } = req.body;

    const updateData = {
      response,
      status: 'answered',
      answeredBy: req.user.uid,
      answeredAt: new Date(),
      isPublic: isPublic !== false, // Default to true
      counsellorNotes: counsellorNotes || '',
      updatedAt: new Date()
    };

    await db.collection('qna').doc(req.params.id).update(updateData);

    logger.info('Question answered', { 
      questionId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, { status: 'answered' }, 'Question answered successfully');

  } catch (error) {
    logger.error('Answer question error:', error);
    errorResponse(res, 'Failed to answer question', 500);
  }
}));

// Flag question
router.patch('/:id/flag', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  const { flagReason } = req.body;

  try {
    const db = getFirestore();
    const questionDoc = await db.collection('qna').doc(req.params.id).get();

    if (!questionDoc.exists) {
      return notFoundResponse(res, 'Question not found');
    }

    const updateData = {
      status: 'flagged',
      flagReason: flagReason || 'Flagged for review',
      updatedAt: new Date()
    };

    await db.collection('qna').doc(req.params.id).update(updateData);

    logger.info('Question flagged', { 
      questionId: req.params.id, 
      userId: req.user.uid,
      flagReason 
    });

    successResponse(res, { status: 'flagged' }, 'Question flagged successfully');

  } catch (error) {
    logger.error('Flag question error:', error);
    errorResponse(res, 'Failed to flag question', 500);
  }
}));

// Vote on question
router.post('/:id/vote', optionalAuth, asyncHandler(async (req, res) => {
  const { voteType } = req.body; // 'upvote' or 'downvote'

  if (!voteType || !['upvote', 'downvote'].includes(voteType)) {
    return errorResponse(res, 'Invalid vote type', 400);
  }

  try {
    const db = getFirestore();
    const questionDoc = await db.collection('qna').doc(req.params.id).get();

    if (!questionDoc.exists) {
      return notFoundResponse(res, 'Question not found');
    }

    const question = questionDoc.data();
    const currentUpvotes = question.upvotes || 0;
    const currentDownvotes = question.downvotes || 0;

    let updateData = {};

    if (voteType === 'upvote') {
      updateData.upvotes = currentUpvotes + 1;
    } else {
      updateData.downvotes = currentDownvotes + 1;
    }

    updateData.updatedAt = new Date();

    await db.collection('qna').doc(req.params.id).update(updateData);

    logger.info('Question voted', { 
      questionId: req.params.id, 
      voteType,
      userId: req.user?.uid || 'anonymous' 
    });

    successResponse(res, { 
      upvotes: updateData.upvotes || currentUpvotes,
      downvotes: updateData.downvotes || currentDownvotes
    }, 'Vote recorded successfully');

  } catch (error) {
    logger.error('Vote question error:', error);
    errorResponse(res, 'Failed to vote on question', 500);
  }
}));

// Get Q&A statistics
router.get('/stats/overview', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const { dateFrom, dateTo } = req.query;

    let query = db.collection('qna');

    if (dateFrom) query = query.where('createdAt', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('createdAt', '<=', new Date(dateTo));

    const snapshot = await query.get();
    const questions = [];

    snapshot.forEach(doc => {
      questions.push(doc.data());
    });

    // Calculate statistics
    const stats = {
      total: questions.length,
      pending: questions.filter(q => q.status === 'pending').length,
      answered: questions.filter(q => q.status === 'answered').length,
      flagged: questions.filter(q => q.status === 'flagged').length,
      byCategory: {
        'academic-stress': questions.filter(q => q.category === 'academic-stress').length,
        'social-emotional': questions.filter(q => q.category === 'social-emotional').length,
        'wellness': questions.filter(q => q.category === 'wellness').length,
        'career-guidance': questions.filter(q => q.category === 'career-guidance').length,
        'relationships': questions.filter(q => q.category === 'relationships').length,
        'mental-health': questions.filter(q => q.category === 'mental-health').length,
        'general': questions.filter(q => q.category === 'general').length
      },
      byPriority: {
        low: questions.filter(q => q.priority === 'low').length,
        medium: questions.filter(q => q.priority === 'medium').length,
        high: questions.filter(q => q.priority === 'high').length,
        urgent: questions.filter(q => q.priority === 'urgent').length
      },
      totalViews: questions.reduce((sum, q) => sum + (q.views || 0), 0),
      totalUpvotes: questions.reduce((sum, q) => sum + (q.upvotes || 0), 0),
      thisWeek: questions.filter(q => {
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        return new Date(q.createdAt) >= weekAgo;
      }).length
    };

    successResponse(res, stats, 'Q&A statistics retrieved successfully');

  } catch (error) {
    logger.error('Get Q&A stats error:', error);
    errorResponse(res, 'Failed to retrieve Q&A statistics', 500);
  }
}));

export default router;
