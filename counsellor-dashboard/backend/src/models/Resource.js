import Joi from 'joi';

export const resourceSchema = Joi.object({
  id: Joi.string().optional(),
  title: Joi.string().min(5).max(200).required(),
  description: Joi.string().min(10).max(1000).required(),
  category: Joi.string().valid('articles', 'videos', 'tips', 'guides', 'worksheets', 'meditation', 'exercises').required(),
  type: Joi.string().valid('PDF', 'Video', 'Article', 'Link', 'Audio', 'Document').required(),
  content: Joi.string().max(10000).optional(), // For text-based resources
  fileUrl: Joi.string().uri().optional(), // For uploaded files
  externalUrl: Joi.string().uri().optional(), // For external links
  thumbnailUrl: Joi.string().uri().optional(),
  tags: Joi.array().items(Joi.string().max(50)).max(10).optional(),
  targetAudience: Joi.array().items(Joi.string().valid('students', 'counsellors', 'general')).default(['students']),
  difficulty: Joi.string().valid('beginner', 'intermediate', 'advanced').default('beginner'),
  duration: Joi.number().min(1).optional(), // in minutes
  isPublic: Joi.boolean().default(true),
  isFeatured: Joi.boolean().default(false),
  downloads: Joi.number().min(0).default(0),
  views: Joi.number().min(0).default(0),
  rating: Joi.number().min(0).max(5).optional(),
  ratingCount: Joi.number().min(0).default(0),
  createdBy: Joi.string().required(),
  updatedBy: Joi.string().required(),
  createdAt: Joi.date().default(Date.now),
  updatedAt: Joi.date().default(Date.now)
});

export const updateResourceSchema = Joi.object({
  title: Joi.string().min(5).max(200).optional(),
  description: Joi.string().min(10).max(1000).optional(),
  category: Joi.string().valid('articles', 'videos', 'tips', 'guides', 'worksheets', 'meditation', 'exercises').optional(),
  type: Joi.string().valid('PDF', 'Video', 'Article', 'Link', 'Audio', 'Document').optional(),
  content: Joi.string().max(10000).optional(),
  fileUrl: Joi.string().uri().optional(),
  externalUrl: Joi.string().uri().optional(),
  thumbnailUrl: Joi.string().uri().optional(),
  tags: Joi.array().items(Joi.string().max(50)).max(10).optional(),
  targetAudience: Joi.array().items(Joi.string().valid('students', 'counsellors', 'general')).optional(),
  difficulty: Joi.string().valid('beginner', 'intermediate', 'advanced').optional(),
  duration: Joi.number().min(1).optional(),
  isPublic: Joi.boolean().optional(),
  isFeatured: Joi.boolean().optional()
});

export const resourceQuerySchema = Joi.object({
  category: Joi.string().valid('articles', 'videos', 'tips', 'guides', 'worksheets', 'meditation', 'exercises').optional(),
  type: Joi.string().valid('PDF', 'Video', 'Article', 'Link', 'Audio', 'Document').optional(),
  targetAudience: Joi.string().valid('students', 'counsellors', 'general').optional(),
  difficulty: Joi.string().valid('beginner', 'intermediate', 'advanced').optional(),
  isPublic: Joi.boolean().optional(),
  isFeatured: Joi.boolean().optional(),
  createdBy: Joi.string().optional(),
  search: Joi.string().max(100).optional(),
  page: Joi.number().min(1).default(1),
  limit: Joi.number().min(1).max(100).default(10),
  sortBy: Joi.string().valid('createdAt', 'updatedAt', 'downloads', 'views', 'rating', 'title').default('createdAt'),
  sortOrder: Joi.string().valid('asc', 'desc').default('desc')
});
