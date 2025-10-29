import Joi from 'joi';

export const reportSchema = Joi.object({
  id: Joi.string().optional(),
  title: Joi.string().min(5).max(200).required(),
  type: Joi.string().valid('monthly', 'weekly', 'daily', 'custom', 'appointment', 'journal', 'qa', 'comprehensive').required(),
  dateRange: Joi.object({
    start: Joi.date().required(),
    end: Joi.date().required()
  }).required(),
  filters: Joi.object({
    counsellorId: Joi.string().optional(),
    studentId: Joi.string().optional(),
    category: Joi.string().optional(),
    status: Joi.string().optional(),
    priority: Joi.string().optional()
  }).optional(),
  data: Joi.object({
    appointments: Joi.object({
      total: Joi.number().min(0).default(0),
      pending: Joi.number().min(0).default(0),
      approved: Joi.number().min(0).default(0),
      completed: Joi.number().min(0).default(0),
      cancelled: Joi.number().min(0).default(0),
      byPriority: Joi.object().optional(),
      byCategory: Joi.object().optional(),
      trends: Joi.array().optional()
    }).optional(),
    journals: Joi.object({
      total: Joi.number().min(0).default(0),
      flagged: Joi.number().min(0).default(0),
      reviewed: Joi.number().min(0).default(0),
      byMood: Joi.object().optional(),
      byPriority: Joi.object().optional(),
      trends: Joi.array().optional()
    }).optional(),
    qa: Joi.object({
      total: Joi.number().min(0).default(0),
      pending: Joi.number().min(0).default(0),
      answered: Joi.number().min(0).default(0),
      byCategory: Joi.object().optional(),
      byPriority: Joi.object().optional(),
      trends: Joi.array().optional()
    }).optional(),
    resources: Joi.object({
      total: Joi.number().min(0).default(0),
      downloads: Joi.number().min(0).default(0),
      views: Joi.number().min(0).default(0),
      byCategory: Joi.object().optional(),
      byType: Joi.object().optional(),
      trends: Joi.array().optional()
    }).optional(),
    students: Joi.object({
      active: Joi.number().min(0).default(0),
      new: Joi.number().min(0).default(0),
      byDepartment: Joi.object().optional(),
      trends: Joi.array().optional()
    }).optional()
  }).required(),
  fileRef: Joi.string().optional(), // Reference to generated file
  generatedAt: Joi.date().default(Date.now),
  generatedBy: Joi.string().required(),
  isPublic: Joi.boolean().default(false),
  createdAt: Joi.date().default(Date.now),
  updatedAt: Joi.date().default(Date.now)
});

export const generateReportSchema = Joi.object({
  title: Joi.string().min(5).max(200).required(),
  type: Joi.string().valid('monthly', 'weekly', 'daily', 'custom', 'appointment', 'journal', 'qa', 'comprehensive').required(),
  dateRange: Joi.object({
    start: Joi.date().required(),
    end: Joi.date().required()
  }).required(),
  filters: Joi.object({
    counsellorId: Joi.string().optional(),
    studentId: Joi.string().optional(),
    category: Joi.string().optional(),
    status: Joi.string().optional(),
    priority: Joi.string().optional()
  }).optional(),
  format: Joi.string().valid('pdf', 'excel', 'csv', 'json').default('pdf'),
  includeCharts: Joi.boolean().default(true),
  isPublic: Joi.boolean().default(false)
});

export const reportQuerySchema = Joi.object({
  type: Joi.string().valid('monthly', 'weekly', 'daily', 'custom', 'appointment', 'journal', 'qa', 'comprehensive').optional(),
  generatedBy: Joi.string().optional(),
  isPublic: Joi.boolean().optional(),
  dateFrom: Joi.date().optional(),
  dateTo: Joi.date().optional(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'generatedAt', 'title').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});
