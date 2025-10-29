import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { getFirestore } from '../config/firebase.js';
import { validate, validateQuery } from '../middleware/validation.js';
import { authenticateToken, requireActiveUser, requireRole } from '../middleware/auth.js';
import { asyncHandler } from '../middleware/errorHandler.js';
import { successResponse, errorResponse, notFoundResponse, paginatedResponse } from '../utils/response.js';
import { resourceSchema, updateResourceSchema, resourceQuerySchema } from '../models/Resource.js';
import { calculatePagination, sortArray, filterArray, generateFileName, formatFileSize } from '../utils/helpers.js';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = process.env.UPLOAD_PATH || './uploads';
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const fileName = generateFileName(file.originalname, 'resource_');
    cb(null, fileName);
  }
});

const upload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024, // 10MB default
  },
  fileFilter: (req, file, cb) => {
    // Allow specific file types
    const allowedTypes = /pdf|doc|docx|txt|mp4|mp3|jpg|jpeg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only PDF, DOC, DOCX, TXT, MP4, MP3, JPG, JPEG, PNG, GIF files are allowed.'));
    }
  }
});

// Get all resources with filtering and pagination
router.get('/', optionalAuth, validateQuery(resourceQuerySchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const {
      category,
      type,
      targetAudience,
      difficulty,
      isPublic,
      isFeatured,
      createdBy,
      search,
      page,
      limit,
      sortBy,
      sortOrder
    } = req.query;

    let query = db.collection('resources');

    // Apply filters
    if (category) query = query.where('category', '==', category);
    if (type) query = query.where('type', '==', type);
    if (targetAudience) query = query.where('targetAudience', 'array-contains', targetAudience);
    if (difficulty) query = query.where('difficulty', '==', difficulty);
    if (isPublic !== undefined) query = query.where('isPublic', '==', isPublic === 'true');
    if (isFeatured !== undefined) query = query.where('isFeatured', '==', isFeatured === 'true');
    if (createdBy) query = query.where('createdBy', '==', createdBy);

    const snapshot = await query.get();
    let resources = [];

    snapshot.forEach(doc => {
      resources.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // Apply search filter
    if (search) {
      resources = resources.filter(resource => 
        resource.title.toLowerCase().includes(search.toLowerCase()) ||
        resource.description.toLowerCase().includes(search.toLowerCase()) ||
        (resource.tags && resource.tags.some(tag => 
          tag.toLowerCase().includes(search.toLowerCase())
        ))
      );
    }

    // Apply client-side filtering and sorting
    resources = filterArray(resources, req.query);
    resources = sortArray(resources, sortBy, sortOrder);

    // Calculate pagination
    const total = resources.length;
    const pagination = calculatePagination(page, limit, total);
    const paginatedResources = resources.slice(
      pagination.offset,
      pagination.offset + pagination.limit
    );

    logger.info('Resources retrieved', { 
      userId: req.user?.uid || 'anonymous', 
      count: paginatedResources.length,
      total 
    });

    paginatedResponse(res, paginatedResources, pagination, 'Resources retrieved successfully');

  } catch (error) {
    logger.error('Get resources error:', error);
    errorResponse(res, 'Failed to retrieve resources', 500);
  }
}));

// Get resource by ID
router.get('/:id', optionalAuth, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const resourceDoc = await db.collection('resources').doc(req.params.id).get();

    if (!resourceDoc.exists) {
      return notFoundResponse(res, 'Resource not found');
    }

    const resource = {
      id: resourceDoc.id,
      ...resourceDoc.data()
    };

    // Check if resource is public or user has access
    if (!resource.isPublic && (!req.user || req.user.role === 'student')) {
      return errorResponse(res, 'Access denied', 403);
    }

    // Increment view count
    await db.collection('resources').doc(req.params.id).update({
      views: (resource.views || 0) + 1
    });

    resource.views = (resource.views || 0) + 1;

    successResponse(res, resource, 'Resource retrieved successfully');

  } catch (error) {
    logger.error('Get resource error:', error);
    errorResponse(res, 'Failed to retrieve resource', 500);
  }
}));

// Create new resource
router.post('/', authenticateToken, requireActiveUser, validate(resourceSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const resourceData = {
      ...req.body,
      createdBy: req.user.uid,
      updatedBy: req.user.uid,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const docRef = await db.collection('resources').add(resourceData);

    logger.info('Resource created', { 
      resourceId: docRef.id, 
      userId: req.user.uid 
    });

    successResponse(res, {
      id: docRef.id,
      ...resourceData
    }, 'Resource created successfully', 201);

  } catch (error) {
    logger.error('Create resource error:', error);
    errorResponse(res, 'Failed to create resource', 500);
  }
}));

// Upload file for resource
router.post('/upload', authenticateToken, requireActiveUser, upload.single('file'), asyncHandler(async (req, res) => {
  try {
    if (!req.file) {
      return errorResponse(res, 'No file uploaded', 400);
    }

    const fileInfo = {
      originalName: req.file.originalname,
      fileName: req.file.filename,
      filePath: req.file.path,
      fileSize: req.file.size,
      fileSizeFormatted: formatFileSize(req.file.size),
      mimeType: req.file.mimetype,
      uploadedAt: new Date()
    };

    logger.info('File uploaded', { 
      fileName: req.file.filename, 
      userId: req.user.uid,
      fileSize: fileInfo.fileSizeFormatted
    });

    successResponse(res, fileInfo, 'File uploaded successfully', 201);

  } catch (error) {
    logger.error('File upload error:', error);
    
    // Clean up uploaded file if there was an error
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    
    errorResponse(res, 'Failed to upload file', 500);
  }
}));

// Update resource
router.put('/:id', authenticateToken, requireActiveUser, validate(updateResourceSchema), asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const resourceDoc = await db.collection('resources').doc(req.params.id).get();

    if (!resourceDoc.exists) {
      return notFoundResponse(res, 'Resource not found');
    }

    const resource = resourceDoc.data();

    // Check if user has permission to update this resource
    if (req.user.role !== 'admin' && resource.createdBy !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    const updateData = {
      ...req.body,
      updatedBy: req.user.uid,
      updatedAt: new Date()
    };

    await db.collection('resources').doc(req.params.id).update(updateData);

    // Get updated resource
    const updatedDoc = await db.collection('resources').doc(req.params.id).get();
    const updatedResource = {
      id: updatedDoc.id,
      ...updatedDoc.data()
    };

    logger.info('Resource updated', { 
      resourceId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, updatedResource, 'Resource updated successfully');

  } catch (error) {
    logger.error('Update resource error:', error);
    errorResponse(res, 'Failed to update resource', 500);
  }
}));

// Delete resource
router.delete('/:id', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const resourceDoc = await db.collection('resources').doc(req.params.id).get();

    if (!resourceDoc.exists) {
      return notFoundResponse(res, 'Resource not found');
    }

    const resource = resourceDoc.data();

    // Check if user has permission to delete this resource
    if (req.user.role !== 'admin' && resource.createdBy !== req.user.uid) {
      return errorResponse(res, 'Access denied', 403);
    }

    // Delete associated file if it exists
    if (resource.fileUrl) {
      const filePath = path.join(process.env.UPLOAD_PATH || './uploads', path.basename(resource.fileUrl));
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    await db.collection('resources').doc(req.params.id).delete();

    logger.info('Resource deleted', { 
      resourceId: req.params.id, 
      userId: req.user.uid 
    });

    successResponse(res, null, 'Resource deleted successfully');

  } catch (error) {
    logger.error('Delete resource error:', error);
    errorResponse(res, 'Failed to delete resource', 500);
  }
}));

// Download resource file
router.get('/:id/download', optionalAuth, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const resourceDoc = await db.collection('resources').doc(req.params.id).get();

    if (!resourceDoc.exists) {
      return notFoundResponse(res, 'Resource not found');
    }

    const resource = resourceDoc.data();

    // Check if resource is public or user has access
    if (!resource.isPublic && (!req.user || req.user.role === 'student')) {
      return errorResponse(res, 'Access denied', 403);
    }

    if (!resource.fileUrl) {
      return errorResponse(res, 'No file available for download', 404);
    }

    const filePath = path.join(process.env.UPLOAD_PATH || './uploads', path.basename(resource.fileUrl));
    
    if (!fs.existsSync(filePath)) {
      return errorResponse(res, 'File not found', 404);
    }

    // Increment download count
    await db.collection('resources').doc(req.params.id).update({
      downloads: (resource.downloads || 0) + 1
    });

    logger.info('Resource downloaded', { 
      resourceId: req.params.id, 
      userId: req.user?.uid || 'anonymous' 
    });

    res.download(filePath, resource.title);

  } catch (error) {
    logger.error('Download resource error:', error);
    errorResponse(res, 'Failed to download resource', 500);
  }
}));

// Get resource statistics
router.get('/stats/overview', authenticateToken, requireActiveUser, asyncHandler(async (req, res) => {
  try {
    const db = getFirestore();
    const { dateFrom, dateTo } = req.query;

    let query = db.collection('resources');

    if (dateFrom) query = query.where('createdAt', '>=', new Date(dateFrom));
    if (dateTo) query = query.where('createdAt', '<=', new Date(dateTo));

    const snapshot = await query.get();
    const resources = [];

    snapshot.forEach(doc => {
      resources.push(doc.data());
    });

    // Calculate statistics
    const stats = {
      total: resources.length,
      public: resources.filter(r => r.isPublic).length,
      featured: resources.filter(r => r.isFeatured).length,
      byCategory: {
        articles: resources.filter(r => r.category === 'articles').length,
        videos: resources.filter(r => r.category === 'videos').length,
        tips: resources.filter(r => r.category === 'tips').length,
        guides: resources.filter(r => r.category === 'guides').length,
        worksheets: resources.filter(r => r.category === 'worksheets').length,
        meditation: resources.filter(r => r.category === 'meditation').length,
        exercises: resources.filter(r => r.category === 'exercises').length
      },
      byType: {
        PDF: resources.filter(r => r.type === 'PDF').length,
        Video: resources.filter(r => r.type === 'Video').length,
        Article: resources.filter(r => r.type === 'Article').length,
        Link: resources.filter(r => r.type === 'Link').length,
        Audio: resources.filter(r => r.type === 'Audio').length,
        Document: resources.filter(r => r.type === 'Document').length
      },
      totalDownloads: resources.reduce((sum, r) => sum + (r.downloads || 0), 0),
      totalViews: resources.reduce((sum, r) => sum + (r.views || 0), 0),
      thisWeek: resources.filter(r => {
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        return new Date(r.createdAt) >= weekAgo;
      }).length
    };

    successResponse(res, stats, 'Resource statistics retrieved successfully');

  } catch (error) {
    logger.error('Get resource stats error:', error);
    errorResponse(res, 'Failed to retrieve resource statistics', 500);
  }
}));

// Rate resource
router.post('/:id/rate', optionalAuth, asyncHandler(async (req, res) => {
  const { rating } = req.body;

  if (!rating || rating < 1 || rating > 5) {
    return errorResponse(res, 'Rating must be between 1 and 5', 400);
  }

  try {
    const db = getFirestore();
    const resourceDoc = await db.collection('resources').doc(req.params.id).get();

    if (!resourceDoc.exists) {
      return notFoundResponse(res, 'Resource not found');
    }

    const resource = resourceDoc.data();
    const currentRating = resource.rating || 0;
    const currentRatingCount = resource.ratingCount || 0;

    // Calculate new average rating
    const newRatingCount = currentRatingCount + 1;
    const newRating = ((currentRating * currentRatingCount) + rating) / newRatingCount;

    const updateData = {
      rating: Math.round(newRating * 10) / 10, // Round to 1 decimal place
      ratingCount: newRatingCount,
      updatedAt: new Date()
    };

    await db.collection('resources').doc(req.params.id).update(updateData);

    logger.info('Resource rated', { 
      resourceId: req.params.id, 
      rating,
      userId: req.user?.uid || 'anonymous' 
    });

    successResponse(res, { 
      rating: updateData.rating,
      ratingCount: updateData.ratingCount
    }, 'Resource rated successfully');

  } catch (error) {
    logger.error('Rate resource error:', error);
    errorResponse(res, 'Failed to rate resource', 500);
  }
}));

export default router;
