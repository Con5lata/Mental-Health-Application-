import express from 'express';
import { getFirestore } from '../config/firebase.js';
import { validate, validateQuery } from '../middleware/validation.js';
import { authenticateToken, requireActiveUser, requireRole } from '../middleware/auth.js';
import { asyncHandler } from '../middleware/errorHandler.js';
import { successResponse, errorResponse, notFoundResponse, paginatedResponse } from '../utils/response.js';
import { appointmentSchema, updateAppointmentSchema, appointmentQuerySchema } from '../models/Appointment.js';
import { calculatePagination, sortArray, filterArray } from '../utils/helpers.js';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Get all appointments with filtering and pagination
router.get('/', authenticateToken, requireActiveUser, validateQuery(appointmentQuerySchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const {
      status,
      priority,
      counsellorId,
      studentId,
      dateFrom,
      dateTo,
      page,
      limit,
      sortBy,
      sortOrder
    } = req.query;

    let query = db.collection('appointments');

    // Apply filters
    if (status) query = query.where('status', '==', status);
    if (priority) query = query.where('priority', '==', priority);
    if (counsellorId) query = query.where('counsellorId', '==', counsellorId);
    if (studentId) query = query.where('studentId', '==', studentId);
    if (dateFrom) query = query.where('date', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('date', '<=', new Date(dateTo));

    // If user is not admin, only show their appointments
    if (req.user.role !== 'admin') {
      query = query.where('counsellorId', '==', req.user.uid);
    }

    const snapshot = await query.get();
    let appointments = [];

    snapshot.forEach(doc => {
      appointments.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // Apply client-side filtering and sorting
    if (Object.keys(req.query).length > 0) {
      appointments = filterArray(appointments, req.query);
    }

    appointments = sortArray(appointments, sortBy, sortOrder);

    // Calculate pagination
    const total = appointments.length;
    const pagination = calculatePagination(page, limit, total);
    const paginatedAppointments = appointments.slice(
      pagination.offset,
      pagination.offset + pagination.limit
    );

    logger.info('Appointments retrieved', { 
      userId: req.user.uid, 
      count: paginatedAppointments.length,
      total 
    });

    paginatedResponse(res, paginatedAppointments, pagination, 'Appointments retrieved successfully');

  } catch (error) {
    logger.error('Get appointments error:', error);
    errorResponse(res, 'Failed to retrieve appointments', 500);
  }
}));

// Get appointment by ID
router.get('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const appointmentDoc = await db.collection('appointments').doc(req.params.id).get();

    if (!appointmentDoc.exists) {
      return notFoundResponse(res, 'Appointment not found');
    }

    const appointment = {
      id: appointmentDoc.id,
      ...appointmentDoc.data()
    };

    // Check if user has permission to view this appointment
    if (req.user.role !== 'admin' && appointment.counsellorId !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    successResponse(res, appointment, 'Appointment retrieved successfully');

  } catch (error) {
    logger.error('Get appointment error:', error);
    errorResponse(res, 'Failed to retrieve appointment', 500);
  }
}));

// Create new appointment
router.post('/', authenticateToken, requireActiveUser, validate(appointmentSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const appointmentData = {
      ...req.body,
      counsellorId: req.user.uid,
      counsellorName: req.user.name,
      createdBy: req.user.uid,
      updatedBy: req.user.uid,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const docRef = await db.collection('appointments').add(appointmentData);

    logger.info('Appointment created', { 
      appointmentId: docRef.id, 
      userId: req.user.uid 
    });

    successResponse(res, {
      id: docRef.id,
      ...appointmentData
    }, 'Appointment created successfully', 201);

  } catch (error) {
    logger.error('Create appointment error:', error);
    errorResponse(res, 'Failed to create appointment', 500);
  }
}));

// Update appointment
router.put('/:id', authenticateToken, requireActiveUser, validate(updateAppointmentSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const appointmentDoc = await db.collection('appointments').doc(req.params.id).get();

    if (!appointmentDoc.exists) {
      return notFoundResponse(res, 'Appointment not found');
    }

    const appointment = appointmentDoc.data();

    // Check if user has permission to update this appointment
    if (req.user.role !== 'admin' && appointment.counsellorId !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    const updateData = {
      ...req.body,
      updatedBy: req.user.uid,
      updatedAt: new Date()
    };

    await db.collection('appointments').doc(req.params.id).update(updateData);

    // Get updated appointment
    const updatedDoc = await db.collection('appointments').doc(req.params.id).get();
    const updatedAppointment = {
      id: updatedDoc.id,
      ...updatedDoc.data()
    };

    logger.info('Appointment updated', { 
      appointmentId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, updatedAppointment, 'Appointment updated successfully');

  } catch (error) {
    logger.error('Update appointment error:', error);
    errorResponse(res, 'Failed to update appointment', 500);
  }
}));

// Delete appointment
router.delete('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const appointmentDoc = await db.collection('appointments').doc(req.params.id).get();

    if (!appointmentDoc.exists) {
      return notFoundResponse(res, 'Appointment not found');
    }

    const appointment = appointmentDoc.data();

    // Check if user has permission to delete this appointment
    if (req.user.role !== 'admin' && appointment.counsellorId !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    await db.collection('appointments').doc(req.params.id).delete();

    logger.info('Appointment deleted', { 
      appointmentId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, null, 'Appointment deleted successfully');

  } catch (error) {
    logger.error('Delete appointment error:', error);
    errorResponse(res, 'Failed to delete appointment', 500);
  }
}));

// Get appointment statistics
router.get('/stats/overview', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const { dateFrom, dateTo } = req.query;

    let query = db.collection('appointments');

    // If user is not admin, only show their appointments
    if (req.user.role !== 'admin') {
      query = query.where('counsellorId', '==', req.user.uid);
    }

    if (dateFrom) query = query.where('date', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('date', '<=', new Date(dateTo));

    const snapshot = await query.get();
    const appointments = [];

    snapshot.forEach(doc => {
      appointments.push(doc.data());
    });

    // Calculate statistics
    const stats = {
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
      thisWeek: appointments.filter(apt => {
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        return new Date(apt.date) >= weekAgo;
      }).length
    };

    successResponse(res, stats, 'Appointment statistics retrieved successfully');

  } catch (error) {
    logger.error('Get appointment stats error:', error);
    errorResponse(res, 'Failed to retrieve appointment statistics', 500);
  }
}));

// Update appointment status
router.patch('/:id/status', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  const { status, notes } = req.body;

  if (!status) {
    return errorResponse(res, 'Status is required', 400);
  }

  const validStatuses = ['pending', 'approved', 'rejected', 'rescheduled', 'completed', 'cancelled'];
  if (!validStatuses.includes(status)) {
    return errorResponse(res, 'Invalid status', 400);
  }

  try {
    const db = getFirestore();
    const appointmentDoc = await db.collection('appointments').doc(req.params.id).get();

    if (!appointmentDoc.exists) {
      return notFoundResponse(res, 'Appointment not found');
    }

    const appointment = appointmentDoc.data();

    // Check if user has permission to update this appointment
    if (req.user.role !== 'admin' && appointment.counsellorId !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    const updateData = {
      status,
      updatedBy: req.user.uid,
      updatedAt: new Date()
    };

    if (notes) {
      updateData.notes = notes;
    }

    await db.collection('appointments').doc(req.params.id).update(updateData);

    logger.info('Appointment status updated', { 
      appointmentId: req.params.id, 
      status, 
      userId: req.user.uid 
    });

    successResponse(res, { status }, 'Appointment status updated successfully');

  } catch (error) {
    logger.error('Update appointment status error:', error);
    errorResponse(res, 'Failed to update appointment status', 500);
  }
}));

export default router;
