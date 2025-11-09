# Namecheap Shared Hosting Deployment Guide

## Complete Deployment Guide for fix.com.bd

This guide provides step-by-step instructions for deploying the Gig Marketplace platform to Namecheap shared hosting.

---

## 📋 Prerequisites

### Server Requirements
- **PHP Version**: 8.2 or higher
- **MySQL Database**: 5.7 or higher  
- **SSH Access**: Enabled (optional but recommended)
- **cPanel Access**: Required
- **Domain**: fix.com.bd pointing to your hosting

### Local Requirements
- Composer installed
- Git installed
- FTP/SFTP client (FileZilla recommended)
- Terminal/Command line access

---

## 🚀 Step-by-Step Deployment

### Step 1: Prepare Your Local Build

```bash
# Clone the repository (if not already done)
git clone https://github.com/rclet/gig.git
cd gig/backend

# Install dependencies with production optimizations
composer install --optimize-autoloader --no-dev

# Create production environment file
cp .env.example .env.production
```

### Step 2: Configure Environment Variables

Edit `.env.production` with your production settings:

```env
APP_NAME="Gig Marketplace"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://fix.com.bd

# Database Configuration (from cPanel)
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_secure_password

# Session & Cache (use file/database on shared hosting)
SESSION_DRIVER=file
CACHE_DRIVER=file
QUEUE_CONNECTION=database

# Mail Configuration (use cPanel email or SMTP)
MAIL_MAILER=smtp
MAIL_HOST=mail.fix.com.bd
MAIL_PORT=587
MAIL_USERNAME=noreply@fix.com.bd
MAIL_PASSWORD=your_email_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@fix.com.bd"
MAIL_FROM_NAME="${APP_NAME}"

# Disable features that require special server configuration
BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local

# Security
SANCTUM_STATEFUL_DOMAINS=fix.com.bd,www.fix.com.bd
```

### Step 3: Database Setup via cPanel

1. **Log in to cPanel** at https://cpanel.namecheap.com
2. **Create MySQL Database**:
   - Go to "MySQL® Databases"
   - Create database: `username_gig_marketplace`
   - Create user with strong password
   - Add user to database with ALL PRIVILEGES
   - Note down database name, username, and password

### Step 4: Upload Files to Server

#### Option A: Using FTP/SFTP (Recommended for first-time setup)

1. **Connect via FileZilla**:
   - Host: `ftp.fix.com.bd` or server IP
   - Username: Your cPanel username
   - Password: Your cPanel password
   - Port: 21 (FTP) or 22 (SFTP)

2. **Upload Backend Files**:
   - Navigate to `/public_html` directory
   - Upload ALL backend files EXCEPT:
     - `.git/` directory
     - `.env` file
     - `node_modules/` (if exists)
     - `tests/` directory
   - Upload `.env.production` as `.env`

3. **Directory Structure** on server:
   ```
   public_html/
   ├── .htaccess (root redirect)
   ├── app/
   ├── bootstrap/
   ├── config/
   ├── database/
   ├── public/
   │   ├── .htaccess
   │   └── index.php
   ├── routes/
   ├── storage/
   ├── vendor/
   ├── .env
   ├── artisan
   └── composer.json
   ```

#### Option B: Using SSH (If available)

```bash
# Connect to server
ssh username@fix.com.bd

# Navigate to public_html
cd public_html

# Clone repository
git clone https://github.com/rclet/gig.git temp
mv temp/backend/* .
mv temp/backend/.env.example .env
rm -rf temp

# Install dependencies
composer install --optimize-autoloader --no-dev
```

### Step 5: Configure File Permissions

Via cPanel File Manager or SSH:

```bash
# Set proper permissions
chmod -R 755 storage
chmod -R 755 bootstrap/cache
chmod 644 .env
chmod 644 composer.json
chmod 755 artisan

# If using SSH, set correct ownership
chown -R username:username storage
chown -R username:username bootstrap/cache
```

### Step 6: Configure .htaccess Files

#### Root .htaccess (`/public_html/.htaccess`)

This file redirects all requests to the `public` directory:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Force HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
    
    # Redirect to public directory
    RewriteCond %{REQUEST_URI} !^/public/
    RewriteRule ^(.*)$ /public/$1 [L,QSA]
</IfModule>
```

#### Public .htaccess (`/public_html/public/.htaccess`)

Already included in the repository, but verify it contains:

```apache
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
```

### Step 7: Initialize Application

Via SSH or cPanel Terminal:

```bash
# Generate application key
php artisan key:generate

# Run database migrations
php artisan migrate --force

# Seed initial data
php artisan db:seed --force

# Cache configuration for better performance
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Create storage link for public file access
php artisan storage:link
```

### Step 8: SSL Certificate Setup

1. **In cPanel**:
   - Go to "SSL/TLS Status"
   - Find fix.com.bd and www.fix.com.bd
   - Click "Run AutoSSL" to install Let's Encrypt certificate

2. **Force HTTPS**:
   - Already configured in root .htaccess
   - Verify by visiting http://fix.com.bd (should redirect to https)

### Step 9: Configure Domain

In Namecheap Domain Panel:
1. Set nameservers to Namecheap hosting nameservers
2. Wait for DNS propagation (up to 48 hours)
3. Add www subdomain if not already configured

### Step 10: Test Deployment

1. **Test API Endpoints**:
   ```bash
   curl https://fix.com.bd/api/health
   ```

2. **Test Web Interface**:
   - Visit https://fix.com.bd
   - Should see Laravel welcome page or your configured homepage

3. **Check Error Logs**:
   - In cPanel: "Errors" section
   - Or via SSH: `tail -f storage/logs/laravel.log`

---

## 🔧 Configuration for Shared Hosting Limitations

### Queue Processing

Shared hosting doesn't support long-running processes. Use these alternatives:

#### Option 1: Cron Jobs (Recommended)

In cPanel Cron Jobs, add:
```bash
* * * * * cd /home/username/public_html && php artisan schedule:run >> /dev/null 2>&1
```

#### Option 2: Database Queue with Manual Processing

```bash
# Process queue manually when needed
php artisan queue:work --once
```

### Session Management

Use file or database sessions (not Redis):
```env
SESSION_DRIVER=file
```

### Cache Management

Use file cache (not Redis):
```env
CACHE_DRIVER=file
```

### Broadcasting

Use log driver for development, or implement with external service:
```env
BROADCAST_CONNECTION=log
```

---

## 🔒 Security Best Practices

### 1. Protect Sensitive Files

Add to root `.htaccess`:
```apache
# Deny access to sensitive files
<FilesMatch "^\.">
    Require all denied
</FilesMatch>

<FilesMatch "(^composer\.(json|lock)|^package.*\.json|\.env)$">
    Require all denied
</FilesMatch>
```

### 2. Disable Directory Listing

```apache
Options -Indexes
```

### 3. Secure File Permissions

```bash
# Files should be 644
find . -type f -exec chmod 644 {} \;

# Directories should be 755
find . -type d -exec chmod 755 {} \;

# Make artisan executable
chmod 755 artisan
```

### 4. Regular Backups

Set up automated backups in cPanel:
- Database backups: Daily
- File backups: Weekly

---

## 🐛 Troubleshooting

### Issue: 500 Internal Server Error

**Solutions**:
1. Check file permissions (755 for directories, 644 for files)
2. Check `.htaccess` syntax
3. Check PHP version in cPanel (must be 8.2+)
4. Check error logs: `storage/logs/laravel.log`
5. Disable `APP_DEBUG` in production

### Issue: Database Connection Error

**Solutions**:
1. Verify database credentials in `.env`
2. Check if database user has proper privileges
3. Ensure database host is `localhost`
4. Check MySQL is running in cPanel

### Issue: Composer Dependencies Not Working

**Solutions**:
1. Re-run: `composer install --optimize-autoloader --no-dev`
2. Check PHP version: `php -v`
3. Increase memory limit in `.htaccess`:
   ```apache
   php_value memory_limit 256M
   ```

### Issue: Storage/Cache Permission Denied

**Solutions**:
```bash
chmod -R 775 storage
chmod -R 775 bootstrap/cache
```

### Issue: .htaccess Not Working

**Solutions**:
1. Ensure mod_rewrite is enabled (contact support if not)
2. Check .htaccess file syntax
3. Try adding to beginning of .htaccess:
   ```apache
   Options +FollowSymLinks
   ```

---

## 🔄 Update/Deployment Process

### For Future Updates:

1. **Backup Current Installation**:
   ```bash
   # Via cPanel: Create full backup
   # Or via SSH:
   tar -czf backup_$(date +%Y%m%d).tar.gz public_html/
   ```

2. **Upload New Files**:
   - Upload only changed files via FTP
   - Or pull changes via git if using SSH

3. **Run Update Commands**:
   ```bash
   composer install --optimize-autoloader --no-dev
   php artisan migrate --force
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

4. **Test**:
   - Check website functionality
   - Monitor error logs

---

## 📊 Performance Optimization

### 1. Enable OPcache

In `.htaccess`:
```apache
php_value opcache.enable 1
php_value opcache.memory_consumption 256
php_value opcache.max_accelerated_files 20000
```

### 2. Cache Everything

```bash
php artisan optimize
```

### 3. Enable Compression

In `.htaccess`:
```apache
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>
```

### 4. Browser Caching

In `public/.htaccess`:
```apache
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

---

## 📞 Support Resources

- **Namecheap Support**: https://support.namecheap.com
- **cPanel Documentation**: https://docs.cpanel.net
- **Laravel Deployment**: https://laravel.com/docs/deployment

---

## ✅ Post-Deployment Checklist

- [ ] Website accessible via https://fix.com.bd
- [ ] SSL certificate installed and working
- [ ] Database connected and migrations run
- [ ] File permissions set correctly
- [ ] Storage linked and writable
- [ ] Cron jobs configured for queue processing
- [ ] Error logging enabled
- [ ] Backups configured
- [ ] Mail configuration tested
- [ ] API endpoints responding
- [ ] Performance optimizations applied

---

**Note**: This deployment is optimized for Namecheap shared hosting limitations. For better performance, consider VPS or dedicated hosting for production applications.
