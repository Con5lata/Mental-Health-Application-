# API Documentation

Complete API reference for the Mental Health Counsellor Dashboard Backend.

## Base URL
```
http://localhost:5000/api
```

## Authentication

Most endpoints require authentication via JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## Response Format

All responses follow a consistent format:

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format",
      "value": "invalid-email"
    }
  ],
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### Paginated Response
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "pages": 10,
    "hasNext": true,
    "hasPrev": false
  },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

## Authentication Endpoints

### POST /api/auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "title": "Senior Counsellor",
  "department": "Student Services",
  "phone": "+1234567890"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "counsellor",
      "title": "Senior Counsellor",
      "department": "Student Services",
      "phone": "+1234567890"
    },
    "token": "jwt-token"
  }
}
```

### POST /api/auth/login
Authenticate user and return JWT token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "counsellor",
      "preferences": { ... }
    },
    "token": "jwt-token"
  }
}
```

### GET /api/auth/me
Get current user profile.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": "user-id",
    "email": "user@example.com",
    "name": "John Doe",
    "role": "counsellor",
    "title": "Senior Counsellor",
    "department": "Student Services",
    "phone": "+1234567890",
    "preferences": { ... }
  }
}
```

### PUT /api/auth/me
Update current user profile.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "John Smith",
  "title": "Lead Counsellor",
  "department": "Mental Health Services",
  "phone": "+1234567890",
  "preferences": {
    "notifications": {
      "newAppointments": true,
      "urgentQuestions": true,
      "flaggedJournals": false
    }
  }
}
```

### PUT /api/auth/change-password
Change user password.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "currentPassword": "oldpassword123",
  "newPassword": "newpassword123"
}
```

---

## Appointment Endpoints

### GET /api/appointments
Get all appointments with filtering and pagination.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `status` (string): Filter by status (pending, approved, rejected, rescheduled, completed, cancelled)
- `priority` (string): Filter by priority (low, medium, high, urgent)
- `counsellorId` (string): Filter by counsellor ID
- `studentId` (string): Filter by student ID
- `dateFrom` (string): Filter by date from (ISO string)
- `dateTo` (string): Filter by date to (ISO string)
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 10)
- `sortBy` (string): Sort field (date, createdAt, priority, status)
- `sortOrder` (string): Sort order (asc, desc)

**Response:**
```json
{
  "success": true,
  "message": "Appointments retrieved successfully",
  "data": [
    {
      "id": "appointment-id",
      "studentId": "student-id",
      "studentName": "Jane Doe",
      "counsellorId": "counsellor-id",
      "counsellorName": "Dr. Smith",
      "date": "2024-01-20T10:00:00.000Z",
      "time": "10:00",
      "duration": 60,
      "reason": "Academic stress counseling",
      "status": "pending",
      "priority": "high",
      "notes": "Student experiencing exam anxiety",
      "location": "Room 101",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "pagination": { ... }
}
```

### GET /api/appointments/:id
Get appointment by ID.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "message": "Appointment retrieved successfully",
  "data": {
    "id": "appointment-id",
    "studentId": "student-id",
    "studentName": "Jane Doe",
    "counsellorId": "counsellor-id",
    "counsellorName": "Dr. Smith",
    "date": "2024-01-20T10:00:00.000Z",
    "time": "10:00",
    "duration": 60,
    "reason": "Academic stress counseling",
    "status": "pending",
    "priority": "high",
    "notes": "Student experiencing exam anxiety",
    "location": "Room 101",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

### POST /api/appointments
Create new appointment.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "studentId": "student-id",
  "studentName": "Jane Doe",
  "date": "2024-01-20T10:00:00.000Z",
  "time": "10:00",
  "duration": 60,
  "reason": "Academic stress counseling",
  "priority": "high",
  "location": "Room 101"
}
```

### PUT /api/appointments/:id
Update appointment.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "date": "2024-01-21T10:00:00.000Z",
  "time": "11:00",
  "reason": "Updated reason",
  "status": "approved",
  "notes": "Additional notes"
}
```

### PATCH /api/appointments/:id/status
Update appointment status.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "status": "approved",
  "notes": "Approved for next week"
}
```

### GET /api/appointments/stats/overview
Get appointment statistics.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `dateFrom` (string): Start date for statistics
- `dateTo` (string): End date for statistics

**Response:**
```json
{
  "success": true,
  "message": "Appointment statistics retrieved successfully",
  "data": {
    "total": 150,
    "pending": 8,
    "approved": 45,
    "completed": 90,
    "cancelled": 7,
    "byPriority": {
      "low": 20,
      "medium": 80,
      "high": 40,
      "urgent": 10
    },
    "thisWeek": 25
  }
}
```

---

## Journal Endpoints

### GET /api/journals
Get all journal entries with filtering and pagination.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `studentId` (string): Filter by student ID
- `status` (string): Filter by status (pending, reviewed, flagged, archived)
- `priority` (string): Filter by priority (low, medium, high, urgent)
- `mood` (string): Filter by mood (very-positive, positive, neutral, negative, very-negative)
- `isFlagged` (boolean): Filter by flagged status
- `dateFrom` (string): Filter by date from
- `dateTo` (string): Filter by date to
- `search` (string): Search in title and content
- `page` (number): Page number
- `limit` (number): Items per page

**Response:**
```json
{
  "success": true,
  "message": "Journal entries retrieved successfully",
  "data": [
    {
      "id": "journal-id",
      "studentId": "student-id",
      "studentName": "Jane Doe",
      "title": "Feeling overwhelmed with coursework",
      "content": "I've been struggling to keep up with my classes...",
      "mood": "negative",
      "tags": ["academic", "stress"],
      "isFlagged": true,
      "priority": "high",
      "status": "pending",
      "counsellorNotes": "",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "pagination": { ... }
}
```

### POST /api/journals
Create new journal entry.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "studentId": "student-id",
  "studentName": "Jane Doe",
  "title": "Weekly reflection",
  "content": "This week has been challenging...",
  "mood": "neutral",
  "tags": ["reflection", "weekly"]
}
```

### PATCH /api/journals/:id/flag
Flag journal entry for review.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "flagReason": "Contains concerning content",
  "priority": "high"
}
```

### PATCH /api/journals/:id/review
Review journal entry.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "counsellorNotes": "Student shows signs of stress. Recommend follow-up.",
  "status": "reviewed"
}
```

---

## Q&A Endpoints

### GET /api/qa
Get all questions with filtering and pagination.

**Headers:** `Authorization: Bearer <token>` (optional)

**Query Parameters:**
- `category` (string): Filter by category
- `status` (string): Filter by status (pending, answered, flagged, archived)
- `priority` (string): Filter by priority
- `answeredBy` (string): Filter by answerer
- `dateFrom` (string): Filter by date from
- `dateTo` (string): Filter by date to
- `search` (string): Search in question text
- `page` (number): Page number
- `limit` (number): Items per page

**Response:**
```json
{
  "success": true,
  "message": "Questions retrieved successfully",
  "data": [
    {
      "id": "question-id",
      "question": "How can I manage my anxiety before exams?",
      "category": "academic-stress",
      "priority": "high",
      "status": "pending",
      "response": "",
      "isAnonymous": true,
      "tags": ["anxiety", "exams"],
      "upvotes": 5,
      "downvotes": 0,
      "views": 12,
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "pagination": { ... }
}
```

### POST /api/qa
Create new question.

**Headers:** `Authorization: Bearer <token>` (optional)

**Request Body:**
```json
{
  "question": "How can I manage my anxiety before exams?",
  "category": "academic-stress",
  "priority": "high",
  "isAnonymous": true,
  "tags": ["anxiety", "exams"]
}
```

### POST /api/qa/:id/answer
Answer a question.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "response": "Here are some effective strategies for managing exam anxiety...",
  "isPublic": true,
  "counsellorNotes": "Standard anxiety management response"
}
```

### POST /api/qa/:id/vote
Vote on a question.

**Headers:** `Authorization: Bearer <token>` (optional)

**Request Body:**
```json
{
  "voteType": "upvote"
}
```

---

## Resource Endpoints

### GET /api/resources
Get all resources with filtering and pagination.

**Headers:** `Authorization: Bearer <token>` (optional)

**Query Parameters:**
- `category` (string): Filter by category
- `type` (string): Filter by type
- `targetAudience` (string): Filter by target audience
- `difficulty` (string): Filter by difficulty
- `isPublic` (boolean): Filter by public status
- `isFeatured` (boolean): Filter by featured status
- `search` (string): Search in title and description
- `page` (number): Page number
- `limit` (number): Items per page

**Response:**
```json
{
  "success": true,
  "message": "Resources retrieved successfully",
  "data": [
    {
      "id": "resource-id",
      "title": "Managing Exam Anxiety",
      "description": "Comprehensive guide on coping strategies",
      "category": "articles",
      "type": "PDF",
      "fileUrl": "https://example.com/file.pdf",
      "tags": ["anxiety", "exams", "study"],
      "targetAudience": ["students"],
      "difficulty": "beginner",
      "isPublic": true,
      "downloads": 145,
      "views": 200,
      "rating": 4.5,
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "pagination": { ... }
}
```

### POST /api/resources
Create new resource.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "title": "Managing Exam Anxiety",
  "description": "Comprehensive guide on coping strategies",
  "category": "articles",
  "type": "PDF",
  "content": "Resource content here...",
  "tags": ["anxiety", "exams"],
  "targetAudience": ["students"],
  "difficulty": "beginner",
  "isPublic": true
}
```

### POST /api/resources/upload
Upload file for resource.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** `multipart/form-data`
- `file`: File to upload

**Response:**
```json
{
  "success": true,
  "message": "File uploaded successfully",
  "data": {
    "originalName": "document.pdf",
    "fileName": "resource_document_1642248600000.pdf",
    "filePath": "./uploads/resource_document_1642248600000.pdf",
    "fileSize": 1024000,
    "fileSizeFormatted": "1.02 MB",
    "mimeType": "application/pdf",
    "uploadedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

### GET /api/resources/:id/download
Download resource file.

**Headers:** `Authorization: Bearer <token>` (optional)

**Response:** File download

### POST /api/resources/:id/rate
Rate a resource.

**Headers:** `Authorization: Bearer <token>` (optional)

**Request Body:**
```json
{
  "rating": 5
}
```

---

## Report Endpoints

### GET /api/reports
Get all reports with filtering and pagination.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `type` (string): Filter by report type
- `generatedBy` (string): Filter by generator
- `isPublic` (boolean): Filter by public status
- `dateFrom` (string): Filter by date from
- `dateTo` (string): Filter by date to
- `page` (number): Page number
- `limit` (number): Items per page

### POST /api/reports/generate
Generate new report.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "title": "Monthly Summary Report",
  "type": "monthly",
  "dateRange": {
    "start": "2024-01-01T00:00:00.000Z",
    "end": "2024-01-31T23:59:59.999Z"
  },
  "filters": {
    "counsellorId": "counsellor-id"
  },
  "format": "pdf",
  "includeCharts": true,
  "isPublic": false
}
```

### GET /api/reports/stats/dashboard
Get dashboard statistics.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `dateFrom` (string): Start date for statistics
- `dateTo` (string): End date for statistics

**Response:**
```json
{
  "success": true,
  "message": "Dashboard statistics retrieved successfully",
  "data": {
    "overview": {
      "pendingAppointments": 8,
      "newQuestions": 12,
      "flaggedJournals": 5,
      "activeStudents": 124
    },
    "appointments": {
      "total": 135,
      "pending": 8,
      "approved": 45,
      "completed": 90,
      "cancelled": 7
    },
    "journals": {
      "total": 56,
      "flagged": 5,
      "reviewed": 45,
      "byMood": {
        "very-positive": 10,
        "positive": 20,
        "neutral": 15,
        "negative": 8,
        "very-negative": 3
      }
    },
    "qa": {
      "total": 247,
      "pending": 12,
      "answered": 230,
      "byCategory": {
        "academic-stress": 89,
        "social-emotional": 45,
        "wellness": 67,
        "career-guidance": 23,
        "relationships": 15,
        "mental-health": 8
      }
    },
    "resources": {
      "total": 45,
      "downloads": 1200,
      "views": 2500,
      "byCategory": {
        "articles": 20,
        "videos": 15,
        "tips": 10
      }
    }
  }
}
```

---

## User Endpoints (Admin Only)

### GET /api/users
Get all users with filtering and pagination.

**Headers:** `Authorization: Bearer <token>`
**Role Required:** Admin

**Query Parameters:**
- `role` (string): Filter by role
- `isActive` (boolean): Filter by active status
- `search` (string): Search in name, email, title
- `page` (number): Page number
- `limit` (number): Items per page

### GET /api/users/:id
Get user by ID.

**Headers:** `Authorization: Bearer <token>`

### PUT /api/users/:id
Update user.

**Headers:** `Authorization: Bearer <token>`

### PATCH /api/users/:id/activate
Activate user.

**Headers:** `Authorization: Bearer <token>`
**Role Required:** Admin

### PATCH /api/users/:id/deactivate
Deactivate user.

**Headers:** `Authorization: Bearer <token>`
**Role Required:** Admin

---

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request - Invalid input data |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Resource already exists |
| 413 | Payload Too Large - File too large |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |

## Rate Limiting

- **Window:** 15 minutes
- **Limit:** 100 requests per IP
- **Headers:** Rate limit information included in response headers

## File Upload Limits

- **Max File Size:** 10MB
- **Allowed Types:** PDF, DOC, DOCX, TXT, MP4, MP3, JPG, JPEG, PNG, GIF
- **Upload Path:** `./uploads/`

## Webhooks

Currently, the API does not support webhooks. Future versions may include webhook support for real-time notifications.
