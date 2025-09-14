# Gig Marketplace Deployment Scripts

## Backend Deployment (Shared Hosting Setup)

### Server Requirements
- PHP 8.2 or higher
- MySQL 5.7 or higher
- Composer installed
- Redis (optional but recommended)

### Deployment Steps

1. **Upload Files**
   ```bash
   # Upload all backend files to your hosting directory
   # Make sure to exclude .git, .env, and vendor folders
   ```

2. **Install Dependencies**
   ```bash
   cd /path/to/your/website
   composer install --optimize-autoloader --no-dev
   ```

3. **Environment Setup**
   ```bash
   cp .env.example .env
   # Edit .env file with your database and other configurations
   php artisan key:generate
   ```

4. **Database Setup**
   ```bash
   php artisan migrate
   php artisan db:seed
   ```

5. **File Permissions**
   ```bash
   chmod -R 755 storage
   chmod -R 755 bootstrap/cache
   ```

6. **Optimization**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

## Frontend Deployment

### Web Deployment (Firebase Hosting)

1. **Build for Web**
   ```bash
   cd frontend
   flutter build web --release
   ```

2. **Deploy to Firebase**
   ```bash
   firebase init hosting
   firebase deploy
   ```

### Mobile App Deployment

#### Android (Google Play Store)

1. **Build APK/AAB**
   ```bash
   flutter build appbundle --release
   # or
   flutter build apk --release
   ```

2. **Upload to Play Console**
   - Create app listing
   - Upload AAB file
   - Complete store listing
   - Submit for review

#### iOS (App Store)

1. **Build for iOS**
   ```bash
   flutter build ios --release
   ```

2. **Archive and Upload**
   - Open iOS/Runner.xcworkspace in Xcode
   - Archive and upload to App Store Connect
   - Submit for review

## Environment Variables

### Backend (.env)
```env
APP_NAME="Gig Marketplace"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.gig.com.bd

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password

MAIL_MAILER=smtp
MAIL_HOST=your_smtp_host
MAIL_PORT=587
MAIL_USERNAME=your_email
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@gig.com.bd"

# Social Login
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
FACEBOOK_CLIENT_ID=your_facebook_client_id
FACEBOOK_CLIENT_SECRET=your_facebook_client_secret

# Payment
STRIPE_KEY=your_stripe_publishable_key
STRIPE_SECRET=your_stripe_secret_key
```

### Frontend (Firebase Config)
```javascript
// firebase_options.dart
const firebaseConfig = {
  apiKey: "your_api_key",
  authDomain: "gig-marketplace-bd.firebaseapp.com",
  projectId: "gig-marketplace-bd",
  storageBucket: "gig-marketplace-bd.appspot.com",
  messagingSenderId: "your_sender_id",
  appId: "your_app_id"
};
```

## SSL Certificate Setup

For shared hosting with cPanel:
1. Go to SSL/TLS section
2. Install Let's Encrypt certificate
3. Force HTTPS redirect

## Monitoring and Maintenance

### Backend Monitoring
- Laravel Telescope for debugging
- Log monitoring via storage/logs
- Database backup scripts
- Performance monitoring

### Frontend Monitoring
- Firebase Analytics
- Crashlytics for error tracking
- Performance monitoring

## Backup Strategy

### Database Backup
```bash
#!/bin/bash
# backup-db.sh
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u username -ppassword database_name > backup_$DATE.sql
```

### File Backup
```bash
#!/bin/bash
# backup-files.sh
tar -czf website_backup_$(date +%Y%m%d).tar.gz /path/to/website
```

## Performance Optimization

### Backend
- Enable OPcache
- Use Redis for caching
- Optimize database queries
- CDN for static assets

### Frontend
- Image optimization
- Code splitting
- Lazy loading
- Service worker for caching

## Security Checklist

- [ ] SSL certificate installed
- [ ] Firewall configured
- [ ] Regular security updates
- [ ] Database credentials secured
- [ ] API rate limiting enabled
- [ ] File upload restrictions
- [ ] Input validation and sanitization
- [ ] CORS properly configured