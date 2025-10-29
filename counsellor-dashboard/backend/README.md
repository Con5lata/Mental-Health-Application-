# Mental Health Counsellor Dashboard - Backend API

A comprehensive backend API for a mental health counselling dashboard built with Node.js, Express, and Firebase Firestore. This backend provides secure, scalable, and modular APIs for managing appointments, journals, Q&A, resources, and reports.

## 🚀 Features

- **Authentication & Authorization**: JWT-based authentication with role-based access control
- **Appointment Management**: Complete CRUD operations for student appointments
- **Journal Review**: Professional review and moderation of student journal entries
- **Q&A System**: Anonymous question answering with categorization and priority
- **Resource Management**: File upload and management for educational resources
- **Analytics & Reporting**: Comprehensive reporting and dashboard statistics
- **User Management**: Admin controls for user accounts and permissions
- **Security**: Input validation, rate limiting, CORS, and data sanitization
- **Logging**: Comprehensive logging with Winston
- **Error Handling**: Centralized error handling and response formatting

## 🛠️ Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: Firebase Firestore
- **Authentication**: Firebase Admin SDK + JWT
- **Validation**: Joi
- **File Upload**: Multer
- **Logging**: Winston
- **Security**: Helmet, CORS, Rate Limiting

## 📋 Prerequisites

- Node.js 18.0.0 or higher
- npm or yarn
- Firebase project with Firestore enabled
- Firebase service account key

## 🚀 Quick Start

### 1. Clone and Install

```bash
cd backend
npm install
```

### 2. Environment Setup

Copy the example environment file and configure your variables:

```bash
cp env.example .env
```

Edit `.env` with your Firebase configuration:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project-id.iam.gserviceaccount.com

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRES_IN=24h

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firestore Database
3. Generate a service account key:
   - Go to Project Settings > Service Accounts
   - Click "Generate new private key"
   - Download the JSON file and extract the values for your `.env`

### 4. Deploy Firestore Rules

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy rules
firebase deploy --only firestore:rules
```

### 5. Start the Server

```bash
# Development
npm run dev

# Production
npm start
```

The API will be available at `http://localhost:5000`

## 📚 API Documentation

### Base URL
```
http://localhost:5000/api
```

### Authentication

All protected routes require a JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

### Endpoints

#### Authentication (`/api/auth`)
- `POST /register` - Register new user
- `POST /login` - User login
- `GET /me` - Get current user profile
- `PUT /me` - Update user profile
- `PUT /change-password` - Change password
- `POST /logout` - Logout user
- `POST /refresh` - Refresh JWT token

#### Appointments (`/api/appointments`)
- `GET /` - Get all appointments (with filtering/pagination)
- `GET /:id` - Get appointment by ID
- `POST /` - Create new appointment
- `PUT /:id` - Update appointment
- `DELETE /:id` - Delete appointment
- `PATCH /:id/status` - Update appointment status
- `GET /stats/overview` - Get appointment statistics

#### Journals (`/api/journals`)
- `GET /` - Get all journal entries (with filtering/pagination)
- `GET /:id` - Get journal entry by ID
- `POST /` - Create new journal entry
- `PUT /:id` - Update journal entry
- `DELETE /:id` - Delete journal entry
- `PATCH /:id/flag` - Flag journal entry for review
- `PATCH /:id/review` - Review journal entry
- `GET /stats/overview` - Get journal statistics

#### Q&A (`/api/qa`)
- `GET /` - Get all questions (with filtering/pagination)
- `GET /:id` - Get question by ID
- `POST /` - Create new question
- `PUT /:id` - Update question
- `DELETE /:id` - Delete question
- `POST /:id/answer` - Answer question
- `PATCH /:id/flag` - Flag question
- `POST /:id/vote` - Vote on question
- `GET /stats/overview` - Get Q&A statistics

#### Resources (`/api/resources`)
- `GET /` - Get all resources (with filtering/pagination)
- `GET /:id` - Get resource by ID
- `POST /` - Create new resource
- `POST /upload` - Upload file for resource
- `PUT /:id` - Update resource
- `DELETE /:id` - Delete resource
- `GET /:id/download` - Download resource file
- `POST /:id/rate` - Rate resource
- `GET /stats/overview` - Get resource statistics

#### Reports (`/api/reports`)
- `GET /` - Get all reports (with filtering/pagination)
- `GET /:id` - Get report by ID
- `POST /generate` - Generate new report
- `DELETE /:id` - Delete report
- `GET /stats/dashboard` - Get dashboard statistics

#### Users (`/api/users`)
- `GET /` - Get all users (admin only)
- `GET /:id` - Get user by ID
- `PUT /:id` - Update user
- `PATCH /:id/activate` - Activate user (admin only)
- `PATCH /:id/deactivate` - Deactivate user (admin only)
- `DELETE /:id` - Delete user (admin only)
- `GET /stats/overview` - Get user statistics (admin only)

### Response Format

All API responses follow a consistent format:

#### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

#### Paginated Response
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

#### Error Response
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

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Role-Based Access Control**: Different permissions for counsellors and admins
- **Input Validation**: Comprehensive validation using Joi schemas
- **Rate Limiting**: Prevents abuse with configurable rate limits
- **CORS Protection**: Configurable cross-origin resource sharing
- **Data Sanitization**: Protection against NoSQL injection and XSS
- **Helmet Security**: Security headers for protection
- **File Upload Security**: Type and size validation for uploads

## 📊 Database Schema

### Collections

#### `users`
- User profiles and authentication data
- Role-based permissions (counsellor, admin, student)
- Preferences and settings

#### `appointments`
- Student appointment requests and management
- Status tracking and priority levels
- Counsellor assignments

#### `journals`
- Student journal entries
- Mood tracking and flagging system
- Professional review workflow

#### `qna`
- Anonymous Q&A system
- Categorization and priority
- Response management

#### `resources`
- Educational resources and materials
- File uploads and external links
- Download tracking and ratings

#### `reports`
- Generated reports and analytics
- Dashboard statistics
- Export functionality

## 🚀 Deployment

### Environment Variables for Production

```env
NODE_ENV=production
PORT=5000
FIREBASE_PROJECT_ID=your-production-project-id
# ... other Firebase config
JWT_SECRET=your-production-jwt-secret
CORS_ORIGIN=https://your-frontend-domain.com
```

### Docker Deployment

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

### Health Check

The API provides a health check endpoint:
```
GET /health
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

## 📝 Logging

Logs are written to:
- Console (development)
- `logs/combined.log` (all logs)
- `logs/error.log` (error logs only)
- `logs/exceptions.log` (uncaught exceptions)
- `logs/rejections.log` (unhandled promise rejections)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the API documentation
- Review the logs for error details

## 🔄 Version History

- **v1.0.0** - Initial release with core functionality
- Complete CRUD operations for all entities
- Authentication and authorization
- File upload capabilities
- Comprehensive reporting
- Security features and validation
