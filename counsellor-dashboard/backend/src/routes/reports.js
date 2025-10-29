import express from 'express';
import { getFirestore } from '../config/firebase.js';
import { validate, validateQuery } from '../middleware/validation.js';
import { authenticateToken, requireActiveUser, requireRole } from '../middleware/auth.js';
import { asyncHandler } from '../middleware/errorHandler.js';
import { successResponse, errorResponse, notFoundResponse, paginatedResponse } from '../utils/response.js';
import { generateReportSchema, reportQuerySchema } from '../models/Report.js';
import { calculatePagination, sortArray, filterArray } from '../utils/helpers.js';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Get all reports with filtering and pagination
router.get('/', authenticateToken, requireActiveUser, validateQuery(reportQuerySchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const {
      type,
      generatedBy,
      isPublic,
      dateFrom,
      dateTo,
      page,
      limit,
      sortBy,
      sortOrder
    } = req.query;

    let query = db.collection('reports');

    // Apply filters
    if (type) query = query.where('type', '==', type);
    if (generatedBy) query = query.where('generatedBy', '==', generatedBy);
    if (isPublic !== undefined) query = query.where('isPublic', '==', isPublic === 'true');
    if (dateFrom) query = query.where('generatedAt', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('generatedAt', '<=', new Date(dateTo));

    // If user is not admin, only show their reports or public reports
    if (req.user.role !== 'admin') {
      query = query.where('isPublic', '==', true);
    }

    const snapshot = await query.get();
    let reports = [];

    snapshot.forEach(doc => {
      reports.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // Apply client-side filtering and sorting
    reports = filterArray(reports, req.query);
    reports = sortArray(reports, sortBy, sortOrder);

    // Calculate pagination
    const total = reports.length;
    const pagination = calculatePagination(page, limit, total);
    const paginatedReports = reports.slice(
      pagination.offset,
      pagination.offset + pagination.limit
    );

    logger.info('Reports retrieved', { 
      userId: req.user.uid, 
      count: paginatedReports.length,
      total 
    });

    paginatedResponse(res, paginatedReports, pagination, 'Reports retrieved successfully');

  } catch (error) {
    logger.error('Get reports error:', error);
    errorResponse(res, 'Failed to retrieve reports', 500);
  }
}));

// Get report by ID
router.get('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const reportDoc = await db.collection('reports').doc(req.params.id).get();

    if (!reportDoc.exists) {
      return notFoundResponse(res, 'Report not found');
    }

    const report = {
      id: reportDoc.id,
      ...reportDoc.data()
    };

    // Check if user has permission to view this report
    if (req.user.role !== 'admin' && !report.isPublic && report.generatedBy !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    successResponse(res, report, 'Report retrieved successfully');

  } catch (error) {
    logger.error('Get report error:', error);
    errorResponse(res, 'Failed to retrieve report', 500);
  }
}));

// Generate new report
router.post('/generate', authenticateToken, requireActiveUser, validate(generateReportSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const { title, type, dateRange, filters, format, includeCharts, isPublic } = req.body;

    // Generate report data based on type
    const reportData = await generateReportData(db, type, dateRange, filters, req.user.uid);

    // Create report document
    const reportDoc = {
      title,
      type,
      dateRange,
      filters: filters || {},
      data: reportData,
      generatedAt: new Date(),
      generatedBy: req.user.uid,
      isPublic: isPublic || false,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const docRef = await db.collection('reports').add(reportDoc);

    logger.info('Report generated', { 
      reportId: docRef.id, 
      type,
      userId: req.user.uid 
    });

    successResponse(res, {
      id: docRef.id,
      ...reportDoc
    }, 'Report generated successfully', 201);

  } catch (error) {
    logger.error('Generate report error:', error);
    errorResponse(res, 'Failed to generate report', 500);
  }
}));

// Delete report
router.delete('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const reportDoc = await db.collection('reports').doc(req.params.id).get();

    if (!reportDoc.exists) {
      return notFoundResponse(res, 'Report not found');
    }

    const report = reportDoc.data();

    // Check if user has permission to delete this report
    if (req.user.role !== 'admin' && report.generatedBy !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    await db.collection('reports').doc(req.params.id).delete();

    logger.info('Report deleted', { 
      reportId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, null, 'Report deleted successfully');

  } catch (error) {
    logger.error('Delete report error:', error);
    errorResponse(res, 'Failed to delete report', 500);
  }
}));

// Get dashboard statistics
router.get('/stats/dashboard', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const { dateFrom, dateTo } = req.query;

    // Set default date range to last 30 days if not provided
    const endDate = dateTo ? new Date(dateTo) : new Date();
    const startDate = dateFrom ? new Date(dateFrom) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    // Get appointments data
    let appointmentsQuery = db.collection('appointments');
    if (req.user.role !== 'admin') {
      appointmentsQuery = appointmentsQuery.where('counsellorId', '==', req.user.uid);
    }
    appointmentsQuery = appointmentsQuery.where('createdAt', '>=', startDate).where('createdAt', '<=', endDate);

    const appointmentsSnapshot = await appointmentsQuery.get();
    const appointments = [];
    appointmentsSnapshot.forEach(doc => appointments.push(doc.data()));

    // Get journals data
    const journalsQuery = db.collection('journals')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', endDate);
    const journalsSnapshot = await journalsQuery.get();
    const journals = [];
    journalsSnapshot.forEach(doc => journals.push(doc.data()));

    // Get Q&A data
    const qaQuery = db.collection('qna')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', endDate);
    const qaSnapshot = await qaQuery.get();
    const questions = [];
    qaSnapshot.forEach(doc => questions.push(doc.data()));

    // Get resources data
    const resourcesQuery = db.collection('resources')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', endDate);
    const resourcesSnapshot = await resourcesQuery.get();
    const resources = [];
    resourcesSnapshot.forEach(doc => resources.push(doc.data()));

    // Calculate dashboard statistics
    const stats = {
      overview: {
        pendingAppointments: appointments.filter(apt => apt.status === 'pending').length,
        newQuestions: questions.filter(q => q.status === 'pending').length,
        flaggedJournals: journals.filter(j => j.isFlagged).length,
        activeStudents: [...new Set(appointments.map(apt => apt.studentId))].length
      },
      appointments: {
        total: appointments.length,
        pending: appointments.filter(apt => apt.status === 'pending').length,
        approved: appointments.filter(apt => apt.status === 'approved').length,
        completed: appointments.filter(apt => apt.status === 'completed').length,
        cancelled: appointments.filter(apt => apt.status === 'cancelled').length,
        byPriority: {
          low: appointments.filter(apt => apt.priority === 'low').length,
          medium: appointments.filter(apt => apt.priority === 'medium').length,
          high: appointments.filter(apt => apt.priority === 'high').length,
          urgent: appointments.filter(apt => apt.priority === 'urgent').length
        }
      },
      journals: {
        total: journals.length,
        flagged: journals.filter(j => j.isFlagged).length,
        reviewed: journals.filter(j => j.status === 'reviewed').length,
        byMood: {
          'very-positive': journals.filter(j => j.mood === 'very-positive').length,
          'positive': journals.filter(j => j.mood === 'positive').length,
          'neutral': journals.filter(j => j.mood === 'neutral').length,
          'negative': journals.filter(j => j.mood === 'negative').length,
          'very-negative': journals.filter(j => j.mood === 'very-negative').length
        }
      },
      qa: {
        total: questions.length,
        pending: questions.filter(q => q.status === 'pending').length,
        answered: questions.filter(q => q.status === 'answered').length,
        byCategory: {
          'academic-stress': questions.filter(q => q.category === 'academic-stress').length,
          'social-emotional': questions.filter(q => q.category === 'social-emotional').length,
          'wellness': questions.filter(q => q.category === 'wellness').length,
          'career-guidance': questions.filter(q => q.category === 'career-guidance').length,
          'relationships': questions.filter(q => q.category === 'relationships').length,
          'mental-health': questions.filter(q => q.category === 'mental-health').length,
          'general': questions.filter(q => q.category === 'general').length
        }
      },
      resources: {
        total: resources.length,
        downloads: resources.reduce((sum, r) => sum + (r.downloads || 0), 0),
        views: resources.reduce((sum, r) => sum + (r.views || 0), 0),
        byCategory: {
          articles: resources.filter(r => r.category === 'articles').length,
          videos: resources.filter(r => r.category === 'videos').length,
          tips: resources.filter(r => r.category === 'tips').length,
          guides: resources.filter(r => r.category === 'guides').length,
          worksheets: resources.filter(r => r.category === 'worksheets').length,
          meditation: resources.filter(r => r.category === 'meditation').length,
          exercises: resources.filter(r => r.category === 'exercises').length
        }
      },
      trends: {
        appointments: generateTrendData(appointments, 'createdAt'),
        journals: generateTrendData(journals, 'createdAt'),
        questions: generateTrendData(questions, 'createdAt'),
        resources: generateTrendData(resources, 'createdAt')
      }
    };

    successResponse(res, stats, 'Dashboard statistics retrieved successfully');

  } catch (error) {
    logger.error('Get dashboard stats error:', error);
    errorResponse(res, 'Failed to retrieve dashboard statistics', 500);
  }
}));

// Helper function to generate report data
async function generateReportData(db, type, dateRange, filters, userId) {
  const startDate = new Date(dateRange.start);
  const endDate = new Date(dateRange.end);

  let data = {};

  switch (type) {
    case 'appointment':
      data = await generateAppointmentReport(db, startDate, endDate, filters, userId);
      break;
    case 'journal':
      data = await generateJournalReport(db, startDate, endDate, filters, userId);
      break;
    case 'qa':
      data = await generateQAReport(db, startDate, endDate, filters, userId);
      break;
    case 'comprehensive':
      data = await generateComprehensiveReport(db, startDate, endDate, filters, userId);
      break;
    default:
      data = await generateComprehensiveReport(db, startDate, endDate, filters, userId);
  }

  return data;
}

// Helper function to generate appointment report data
async function generateAppointmentReport(db, startDate, endDate, filters, userId) {
  let query = db.collection('appointments')
    .where('createdAt', '>=', startDate)
    .where('createdAt', '<=', endDate);

  if (filters.counsellorId) {
    query = query.where('counsellorId', '==', filters.counsellorId);
  }

  const snapshot = await query.get();
  const appointments = [];
  snapshot.forEach(doc => appointments.push(doc.data()));

  return {
    appointments: {
      total: appointments.length,
      pending: appointments.filter(apt => apt.status === 'pending').length,
      approved: appointments.filter(apt => apt.status === 'approved').length,
      completed: appointments.filter(apt => apt.status === 'completed').length,
      cancelled: appointments.filter(apt => apt.status === 'cancelled').length,
      byPriority: {
        low: appointments.filter(apt => apt.priority === 'low').length,
        medium: appointments.filter(apt => apt.priority === 'medium').length,
        high: appointments.filter(apt => apt.priority === 'high').length,
        urgent: appointments.filter(apt => apt.priority === 'urgent').length
      },
      trends: generateTrendData(appointments, 'createdAt')
    }
  };
}

// Helper function to generate journal report data
async function generateJournalReport(db, startDate, endDate, filters, userId) {
  let query = db.collection('journals')
    .where('createdAt', '>=', startDate)
    .where('createdAt', '<=', endDate);

  if (filters.studentId) {
    query = query.where('studentId', '==', filters.studentId);
  }

  const snapshot = await query.get();
  const journals = [];
  snapshot.forEach(doc => journals.push(doc.data()));

  return {
    journals: {
      total: journals.length,
      flagged: journals.filter(j => j.isFlagged).length,
      reviewed: journals.filter(j => j.status === 'reviewed').length,
      byMood: {
        'very-positive': journals.filter(j => j.mood === 'very-positive').length,
        'positive': journals.filter(j => j.mood === 'positive').length,
        'neutral': journals.filter(j => j.mood === 'neutral').length,
        'negative': journals.filter(j => j.mood === 'negative').length,
        'very-negative': journals.filter(j => j.mood === 'very-negative').length
      },
      trends: generateTrendData(journals, 'createdAt')
    }
  };
}

// Helper function to generate Q&A report data
async function generateQAReport(db, startDate, endDate, filters, userId) {
  let query = db.collection('qna')
    .where('createdAt', '>=', startDate)
    .where('createdAt', '<=', endDate);

  if (filters.category) {
    query = query.where('category', '==', filters.category);
  }

  const snapshot = await query.get();
  const questions = [];
  snapshot.forEach(doc => questions.push(doc.data()));

  return {
    qa: {
      total: questions.length,
      pending: questions.filter(q => q.status === 'pending').length,
      answered: questions.filter(q => q.status === 'answered').length,
      byCategory: {
        'academic-stress': questions.filter(q => q.category === 'academic-stress').length,
        'social-emotional': questions.filter(q => q.category === 'social-emotional').length,
        'wellness': questions.filter(q => q.category === 'wellness').length,
        'career-guidance': questions.filter(q => q.category === 'career-guidance').length,
        'relationships': questions.filter(q => q.category === 'relationships').length,
        'mental-health': questions.filter(q => q.category === 'mental-health').length,
        'general': questions.filter(q => q.category === 'general').length
      },
      trends: generateTrendData(questions, 'createdAt')
    }
  };
}

// Helper function to generate comprehensive report data
async function generateComprehensiveReport(db, startDate, endDate, filters, userId) {
  const [appointments, journals, questions, resources] = await Promise.all([
    generateAppointmentReport(db, startDate, endDate, filters, userId),
    generateJournalReport(db, startDate, endDate, filters, userId),
    generateQAReport(db, startDate, endDate, filters, userId),
    generateResourceReport(db, startDate, endDate, filters, userId)
  ]);

  return {
    ...appointments,
    ...journals,
    ...questions,
    ...resources
  };
}

// Helper function to generate resource report data
async function generateResourceReport(db, startDate, endDate, filters, userId) {
  let query = db.collection('resources')
    .where('createdAt', '>=', startDate)
    .where('createdAt', '<=', endDate);

  if (filters.category) {
    query = query.where('category', '==', filters.category);
  }

  const snapshot = await query.get();
  const resources = [];
  snapshot.forEach(doc => resources.push(doc.data()));

  return {
    resources: {
      total: resources.length,
      downloads: resources.reduce((sum, r) => sum + (r.downloads || 0), 0),
      views: resources.reduce((sum, r) => sum + (r.views || 0), 0),
      byCategory: {
        articles: resources.filter(r => r.category === 'articles').length,
        videos: resources.filter(r => r.category === 'videos').length,
        tips: resources.filter(r => r.category === 'tips').length,
        guides: resources.filter(r => r.category === 'guides').length,
        worksheets: resources.filter(r => r.category === 'worksheets').length,
        meditation: resources.filter(r => r.category === 'meditation').length,
        exercises: resources.filter(r => r.category === 'exercises').length
      },
      trends: generateTrendData(resources, 'createdAt')
    }
  };
}

// Helper function to generate trend data
function generateTrendData(data, dateField) {
  const trends = {};
  const now = new Date();
  const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

  // Group data by day
  data.forEach(item => {
    const date = new Date(item[dateField]);
    if (date >= thirtyDaysAgo) {
      const dayKey = date.toISOString().split('T')[0];
      trends[dayKey] = (trends[dayKey] || 0) + 1;
    }
  });

  // Convert to array format
  return Object.entries(trends).map(([date, count]) => ({
    date,
    count
  })).sort((a, b) => new Date(a.date) - new Date(b.date));
}

export default router;
