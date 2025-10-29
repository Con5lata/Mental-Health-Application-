import Joi from 'joi';

export const userSchema = Joi.object({
  id: Joi.string().optional(),
  email: Joi.string().email().required(),
  name: Joi.string().min(2).max(100).required(),
  role: Joi.string().valid('counsellor', 'admin', 'student').default('counsellor'),
  title: Joi.string().max(100).optional(),
  department: Joi.string().max(100).optional(),
  phone: Joi.string().max(20).optional(),
  profileImage: Joi.string().uri().optional(),
  isActive: Joi.boolean().default(true),
  lastLogin: Joi.date().optional(),
  createdAt: Joi.date().default(Date.now),
  updatedAt: Joi.date().default(Date.now),
  preferences: Joi.object({
    notifications: Joi.object({
      newAppointments: Joi.boolean().default(true),
      urgentQuestions: Joi.boolean().default(true),
      flaggedJournals: Joi.boolean().default(true),
      systemUpdates: Joi.boolean().default(false),
      emailSummary: Joi.boolean().default(true)
    }).default(),
    privacy: Joi.object({
      profileVisibility: Joi.boolean().default(true),
      activityStatus: Joi.boolean().default(false),
      dataCollection: Joi.boolean().default(true)
    }).default()
  }).default()
});

export const updateUserSchema = Joi.object({
  name: Joi.string().min(2).max(100).optional(),
  title: Joi.string().max(100).optional(),
  department: Joi.string().max(100).optional(),
  phone: Joi.string().max(20).optional(),
  profileImage: Joi.string().uri().optional(),
  preferences: Joi.object({
    notifications: Joi.object({
      newAppointments: Joi.boolean().optional(),
      urgentQuestions: Joi.boolean().optional(),
      flaggedJournals: Joi.boolean().optional(),
      systemUpdates: Joi.boolean().optional(),
      emailSummary: Joi.boolean().optional()
    }).optional(),
    privacy: Joi.object({
      profileVisibility: Joi.boolean().optional(),
      activityStatus: Joi.boolean().optional(),
      dataCollection: Joi.boolean().optional()
    }).optional()
  }).optional()
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required()
});

export const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  name: Joi.string().min(2).max(100).required(),
  title: Joi.string().max(100).optional(),
  department: Joi.string().max(100).optional(),
  phone: Joi.string().max(20).optional()
});
