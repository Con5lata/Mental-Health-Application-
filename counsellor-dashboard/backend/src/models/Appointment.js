import Joi from 'joi';

export const appointmentSchema = Joi.object({
  id: Joi.string().optional(),
  studentId: Joi.string().required(),
  studentName: Joi.string().min(2).max(100).required(),
  counsellorId: Joi.string().required(),
  counsellorName: Joi.string().min(2).max(100).required(),
  date: Joi.date().required(),
  time: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
  duration: Joi.number().min(15).max(120).default(60), // minutes
  reason: Joi.string().min(10).max(500).required(),
  status: Joi.string().valid('pending', 'approved', 'rejected', 'rescheduled', 'completed', 'cancelled').default('pending'),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').default('medium'),
  notes: Joi.string().max(1000).optional(),
  location: Joi.string().max(200).optional(),
  meetingLink: Joi.string().uri().optional(),
  createdAt: Joi.date().default(Date.now),
  updatedAt: Joi.date().default(Date.now),
  createdBy: Joi.string().required(),
  updatedBy: Joi.string().required()
});

export const updateAppointmentSchema = Joi.object({
  date: Joi.date().optional(),
  time: Joi.string().pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).optional(),
  duration: Joi.number().min(15).max(120).optional(),
  reason: Joi.string().min(10).max(500).optional(),
  status: Joi.string().valid('pending', 'approved', 'rejected', 'rescheduled', 'completed', 'cancelled').optional(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').optional(),
  notes: Joi.string().max(1000).optional(),
  location: Joi.string().max(200).optional(),
  meetingLink: Joi.string().uri().optional()
});

export const appointmentQuerySchema = Joi.object({
  status: Joi.string().valid('pending', 'approved', 'rejected', 'rescheduled', 'completed', 'cancelled').optional(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').optional(),
  counsellorId: Joi.string().optional(),
  studentId: Joi.string().optional(),
  dateFrom: Joi.date().optional(),
  dateTo: Joi.date().optional(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10),
  sortBy: Joi.string().valid('date', 'createdAt', 'priority', 'status').default('date'),
  sortOrder: Joi.string().valid('asc', 'desc').default('asc')
});
