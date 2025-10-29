# Deployment Guide

This guide covers deploying the Mental Health Counsellor Dashboard Backend API to various platforms.

## 🚀 Quick Deployment Options

### 1. Heroku Deployment

#### Prerequisites
- Heroku CLI installed
- Git repository
- Heroku account

#### Steps

1. **Create Heroku App**
```bash
heroku create your-app-name
```

2. **Set Environment Variables**
```bash
heroku config:set NODE_ENV=production
heroku config:set PORT=5000
heroku config:set FIREBASE_PROJECT_ID=your-project-id
heroku config:set FIREBASE_PRIVATE_KEY_ID=your-private-key-id
heroku config:set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n"
heroku config:set FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
heroku config:set FIREBASE_CLIENT_ID=your-client-id
heroku config:set FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
heroku config:set FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
heroku config:set FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
heroku config:set FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your-project-id.iam.gserviceaccount.com
heroku config:set JWT_SECRET=your-super-secret-jwt-key-here
heroku config:set JWT_EXPIRES_IN=24h
heroku config:set CORS_ORIGIN=https://your-frontend-domain.com
```

3. **Deploy**
```bash
git push heroku main
```

4. **Deploy Firestore Rules**
```bash
firebase deploy --only firestore:rules
```

### 2. Railway Deployment

#### Prerequisites
- Railway account
- GitHub repository

#### Steps

1. **Connect Repository**
   - Go to Railway dashboard
   - Click "New Project"
   - Connect your GitHub repository

2. **Set Environment Variables**
   - Go to project settings
   - Add all environment variables from `env.example`

3. **Deploy**
   - Railway will automatically deploy on push to main branch

### 3. DigitalOcean App Platform

#### Prerequisites
- DigitalOcean account
- GitHub repository

#### Steps

1. **Create App**
   - Go to DigitalOcean App Platform
   - Click "Create App"
   - Connect your GitHub repository

2. **Configure App**
   - Choose Node.js
   - Set build command: `npm install`
   - Set run command: `npm start`
   - Set source directory: `backend`

3. **Set Environment Variables**
   - Add all environment variables from `env.example`

4. **Deploy**
   - Click "Create Resources"

### 4. AWS Elastic Beanstalk

#### Prerequisites
- AWS account
- EB CLI installed

#### Steps

1. **Initialize EB Application**
```bash
eb init
```

2. **Create Environment**
```bash
eb create production
```

3. **Set Environment Variables**
```bash
eb setenv NODE_ENV=production
eb setenv PORT=5000
# ... set all other environment variables
```

4. **Deploy**
```bash
eb deploy
```

### 5. Google Cloud Run

#### Prerequisites
- Google Cloud account
- gcloud CLI installed

#### Steps

1. **Build Container**
```bash
gcloud builds submit --tag gcr.io/PROJECT-ID/mental-health-api
```

2. **Deploy to Cloud Run**
```bash
gcloud run deploy --image gcr.io/PROJECT-ID/mental-health-api --platform managed --region us-central1 --allow-unauthenticated
```

3. **Set Environment Variables**
```bash
gcloud run services update mental-health-api --set-env-vars NODE_ENV=production,PORT=5000
```

## 🔧 Environment Configuration

### Required Environment Variables

```env
# Server Configuration
NODE_ENV=production
PORT=5000

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
CORS_ORIGIN=https://your-frontend-domain.com

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_PATH=./uploads
```

### Optional Environment Variables

```env
# Email Configuration (for notifications)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# Logging
LOG_LEVEL=info
```

## 🗄️ Database Setup

### Firestore Rules Deployment

1. **Install Firebase CLI**
```bash
npm install -g firebase-tools
```

2. **Login to Firebase**
```bash
firebase login
```

3. **Initialize Firebase in Project**
```bash
firebase init firestore
```

4. **Deploy Rules**
```bash
firebase deploy --only firestore:rules
```

### Firestore Indexes

The `firestore.indexes.json` file contains all necessary indexes. Deploy them with:

```bash
firebase deploy --only firestore:indexes
```

## 🔒 Security Considerations

### 1. Environment Variables
- Never commit `.env` files to version control
- Use strong, unique JWT secrets
- Rotate secrets regularly
- Use different secrets for different environments

### 2. Firebase Security
- Review and test Firestore rules
- Use least privilege principle
- Regularly audit access logs
- Enable Firebase App Check for additional security

### 3. CORS Configuration
- Set specific origins instead of wildcards
- Update CORS_ORIGIN when deploying frontend

### 4. Rate Limiting
- Adjust rate limits based on expected traffic
- Monitor for abuse patterns
- Implement IP-based blocking if needed

## 📊 Monitoring and Logging

### 1. Application Logs
- Logs are written to `logs/` directory
- Use log aggregation services (e.g., LogRocket, Sentry)
- Monitor error rates and response times

### 2. Health Checks
- Use `/health` endpoint for load balancer health checks
- Monitor database connectivity
- Set up alerts for service downtime

### 3. Performance Monitoring
- Use APM tools (e.g., New Relic, DataDog)
- Monitor memory usage and CPU
- Track API response times

## 🚀 CI/CD Pipeline

### GitHub Actions Example

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: cd backend && npm ci
      
    - name: Run tests
      run: cd backend && npm test
      
    - name: Deploy to Heroku
      uses: akhileshns/heroku-deploy@v3.12.12
      with:
        heroku_api_key: ${{secrets.HEROKU_API_KEY}}
        heroku_app_name: "your-app-name"
        heroku_email: "your-email@example.com"
        app_dir: "backend"
        
    - name: Deploy Firestore Rules
      run: |
        cd backend
        firebase deploy --only firestore:rules --token ${{secrets.FIREBASE_TOKEN}}
```

## 🔄 Rollback Strategy

### 1. Application Rollback
- Keep previous versions tagged in Git
- Use platform-specific rollback commands
- Test rollback procedures regularly

### 2. Database Rollback
- Firestore rules are versioned
- Keep backups of critical data
- Test data migration scripts

## 📈 Scaling Considerations

### 1. Horizontal Scaling
- Use load balancers
- Implement session affinity if needed
- Consider database connection pooling

### 2. Vertical Scaling
- Monitor resource usage
- Scale up when CPU/memory limits are reached
- Use auto-scaling when available

### 3. Database Scaling
- Firestore scales automatically
- Consider read replicas for heavy read workloads
- Implement caching for frequently accessed data

## 🆘 Troubleshooting

### Common Issues

1. **Environment Variables Not Set**
   - Check platform-specific environment variable configuration
   - Verify variable names match exactly

2. **Firebase Connection Issues**
   - Verify service account key is correct
   - Check Firebase project ID
   - Ensure Firestore is enabled

3. **CORS Errors**
   - Update CORS_ORIGIN environment variable
   - Check frontend domain configuration

4. **File Upload Issues**
   - Verify upload directory permissions
   - Check file size limits
   - Ensure storage service is configured

### Debug Commands

```bash
# Check application health
curl https://your-api-domain.com/health

# View logs (platform-specific)
heroku logs --tail
railway logs
gcloud logs tail

# Test database connection
node -e "require('./src/config/firebase.js').initializeFirebase()"
```

## 📞 Support

For deployment issues:
1. Check platform-specific documentation
2. Review application logs
3. Verify environment configuration
4. Test locally with production environment variables
5. Create an issue in the repository
