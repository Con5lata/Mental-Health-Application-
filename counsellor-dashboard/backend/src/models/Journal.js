import Joi from 'joi';

export const journalSchema = Joi.object({
  id: Joi.string().optional(),
  studentId: Joi.string().required(),
  studentName: Joi.string().min(2).max(100).required(),
  title: Joi.string().min(5).max(200).required(),
  content: Joi.string().min(10).max(5000).required(),
  mood: Joi.string().valid('very-positive', 'positive', 'neutral', 'negative', 'very-negative').optional(),
  tags: Joi.array().items(Joi.string().max(50)).max(10).optional(),
  isFlagged: Joi.boolean().default(false),
  flagReason: Joi.string().max(200).optional(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').default('medium'),
  status: Joi.string().valid('pending', 'reviewed', 'flagged', 'archived').default('pending'),
  counsellorNotes: Joi.string().max(1000).optional(),
  reviewedBy: Joi.string().optional(),
  reviewedAt: Joi.date().optional(),
  createdAt: Joi.date().default(Date.now),
  updatedAt: Joi.date().default(Date.now),
  createdBy: Joi.string().required()
});

export const updateJournalSchema = Joi.object({
  title: Joi.string().min(5).max(200).optional(),
  content: Joi.string().min(10).max(5000).optional(),
  mood: Joi.string().valid('very-positive', 'positive', 'neutral', 'negative', 'very-negative').optional(),
  tags: Joi.array().items(Joi.string().max(50)).max(10).optional(),
  isFlagged: Joi.boolean().optional(),
  flagReason: Joi.string().max(200).optional(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').optional(),
  status: Joi.string().valid('pending', 'reviewed', 'flagged', 'archived').optional(),
  counsellorNotes: Joi.string().max(1000).optional()
});

export const journalQuerySchema = Joi.object({
  studentId: Joi.string().optional(),
  status: Joi.string().valid('pending', 'reviewed', 'flagged', 'archived').optional(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').optional(),
  mood: Joi.string().valid('very-positive', 'positive', 'neutral', 'negative', 'very-negative').optional(),
  isFlagged: Joi.boolean().optional(),
  dateFrom: Joi.date().optional(),
  dateTo: Joi.date().optional(),
  search: Joi.string().max(100).optional(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'updatedAt', 'priority', 'mood').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});
