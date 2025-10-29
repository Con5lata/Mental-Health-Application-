import Joi from 'joi';

export const questionSchema = Joi.object({
  id: Joi.string().optional(),
  question: Joi.string().min(10).max(1000).required(),
  category: Joi.string().valid('academic-stress', 'social-emotional', 'wellness', 'career-guidance', 'relationships', 'mental-health', 'general').required(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').default('medium'),
  status: Joi.string().valid('pending', 'answered', 'flagged', 'archived').default('pending'),
  response: Joi.string().max(2000).optional(),
  answeredBy: Joi.string().optional(),
  answeredAt: Joi.date().optional(),
  isAnonymous: Joi.boolean().default(true),
  studentId: Joi.string().optional(), // Optional for anonymous questions
  tags: Joi.array().items(Joi.string().max(50)).max(5).optional(),
  upvotes: Joi.number().min(0).default(0),
  downvotes: Joi.number().min(0).default(0),
  views: Joi.number().min(0).default(0),
  createdAt: Joi.date().default(Date.now),
  updatedAt: Joi.date().default(Date.now)
});

export const updateQuestionSchema = Joi.object({
  question: Joi.string().min(10).max(1000).optional(),
  category: Joi.string().valid('academic-stress', 'social-emotional', 'wellness', 'career-guidance', 'relationships', 'mental-health', 'general').optional(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').optional(),
  status: Joi.string().valid('pending', 'answered', 'flagged', 'archived').optional(),
  response: Joi.string().max(2000).optional(),
  tags: Joi.array().items(Joi.string().max(50)).max(5).optional()
});

export const answerSchema = Joi.object({
  response: Joi.string().min(10).max(2000).required(),
  isPublic: Joi.boolean().default(true),
  counsellorNotes: Joi.string().max(500).optional()
});

export const qaQuerySchema = Joi.object({
  category: Joi.string().valid('academic-stress', 'social-emotional', 'wellness', 'career-guidance', 'relationships', 'mental-health', 'general').optional(),
  status: Joi.string().valid('pending', 'answered', 'flagged', 'archived').optional(),
  priority: Joi.string().valid('low', 'medium', 'high', 'urgent').optional(),
  answeredBy: Joi.string().optional(),
  dateFrom: Joi.date().optional(),
  dateTo: Joi.date().optional(),
  search: Joi.string().max(100).optional(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'updatedAt', 'priority', 'upvotes', 'views').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});
