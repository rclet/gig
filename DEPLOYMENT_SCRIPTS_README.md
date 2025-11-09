# Deployment Scripts for Namecheap Shared Hosting

This directory contains all necessary scripts and configuration files for deploying the Gig Marketplace to Namecheap shared hosting at **fix.com.bd**.

---

## 📁 Files Overview

### Documentation
- **`NAMECHEAP_DEPLOYMENT.md`** - Complete deployment guide with step-by-step instructions
- **`DEPLOYMENT_SCRIPTS_README.md`** - This file, explaining all deployment scripts
- **`DEPLOYMENT.md`** - General deployment documentation for various platforms

### Deployment Scripts
- **`deploy_to_namecheap.sh`** - Main deployment preparation script (run locally)
- **`backup_namecheap.sh`** - Backup script for database and files (run on server)
- **`diagnose_server.sh`** - Diagnostic script to check server health (run on server)

### Configuration Files
- **`backend/.htaccess`** - Root directory .htaccess with security and redirects
- **`backend/public/.htaccess`** - Public directory .htaccess with performance optimizations
- **`cron_jobs.txt`** - Cron job configurations for Laravel scheduler and maintenance
- **`maintenance.html`** - Maintenance mode page to display during updates

### Build Scripts
- **`validate_build.sh`** - Validates frontend Flutter build (for local testing)

---

## 🚀 Quick Start Guide

### For Initial Deployment:

1. **Prepare deployment package locally:**
   ```bash
   ./deploy_to_namecheap.sh
   ```
   This creates a `deploy_package` directory with all necessary files.

2. **Upload to Namecheap:**
   - Extract the `deploy_package` folder
   - Upload all contents to `/public_html` via FTP/SFTP
   - Follow instructions in `deploy_package/UPLOAD_INSTRUCTIONS.txt`

3. **Configure on server:**
   ```bash
   # Via SSH or cPanel Terminal
   cd /home/username/public_html
   mv .env.production .env
   # Edit .env with your database credentials
   php artisan key:generate
   php artisan migrate --force
   php artisan optimize
   ```

4. **Set up cron jobs:**
   - Copy jobs from `cron_jobs.txt` to cPanel Cron Jobs section

5. **Test deployment:**
   ```bash
   ./diagnose_server.sh
   ```

---

## 📋 Detailed Script Documentation

### 1. deploy_to_namecheap.sh

**Purpose:** Prepares your Laravel backend for deployment to Namecheap shared hosting.

**What it does:**
- Creates a clean deployment package
- Installs production Composer dependencies
- Creates production environment template
- Generates upload instructions
- Creates deployment archive

**Usage:**
```bash
# Run from project root
./deploy_to_namecheap.sh
```

**Output:**
- `deploy_package/` - Directory ready for upload
- `gig_marketplace_namecheap_TIMESTAMP.tar.gz` - Compressed archive
- `QUICK_REFERENCE.txt` - Quick deployment reference

**When to use:**
- Initial deployment
- Major updates requiring full redeployment
- Creating deployment archive for backup

---

### 2. backup_namecheap.sh

**Purpose:** Creates automated backups of database and application files on the server.

**What it does:**
- Backs up MySQL database to SQL file
- Archives application files (excluding vendor, cache)
- Backs up .env configuration
- Cleans up old backups (configurable retention)
- Creates compressed backup archive

**Configuration:** Edit these variables in the script:
```bash
APP_PATH="/home/username/public_html"
BACKUP_PATH="/home/username/backups"
DB_NAME="your_database_name"
DB_USER="your_database_user"
DB_PASS="your_database_password"
RETENTION_DAYS=30
```

**Usage:**
```bash
# Upload to server first
chmod +x backup_namecheap.sh

# Run manually
./backup_namecheap.sh

# Or set up in cron (see cron_jobs.txt)
```

**Output:**
- Creates backup archive in specified backup path
- Includes database dump, files, and configuration
- Automatically removes backups older than retention period

**Best practices:**
- Run daily via cron job (recommended time: 2:00 AM)
- Store backups in directory outside public_html
- Download backups to local machine periodically
- Test restore process regularly

---

### 3. diagnose_server.sh

**Purpose:** Diagnoses common server issues and checks system health.

**What it checks:**
- PHP version and required extensions
- File and directory permissions
- Environment configuration (.env)
- .htaccess files presence
- Composer dependencies
- Database connectivity
- Storage symlink
- Recent errors in logs
- Web server configuration
- System resources (memory, disk)

**Usage:**
```bash
# Upload to server and make executable
chmod +x diagnose_server.sh

# Run from application root directory
cd /home/username/public_html
./diagnose_server.sh
```

**Output:**
- ✅ Green checkmarks for passing checks
- ⚠️ Yellow warnings for potential issues
- ❌ Red errors for critical problems
- Suggestions for fixing issues

**When to use:**
- After initial deployment
- When troubleshooting errors
- Before major updates
- Regular health checks
- When experiencing issues

---

## 🔧 Configuration Files

### backend/.htaccess (Root)

**Purpose:** Redirects all requests to the public directory and enforces security.

**Key features:**
- Forces HTTPS (SSL required)
- Redirects to /public directory
- Denies access to sensitive files (.env, composer.json, etc.)
- Disables directory listing
- Custom error pages

**Installation:**
- Automatically included in deployment package
- Should be in `/public_html/.htaccess`

---

### backend/public/.htaccess (Public)

**Purpose:** Laravel routing and performance optimizations.

**Key features:**
- URL rewriting for Laravel
- Authorization header handling
- Gzip compression for text files
- Browser caching for static assets
- Security headers (X-Frame-Options, XSS protection)
- PHP configuration adjustments

**Installation:**
- Automatically included in deployment package
- Should be in `/public_html/public/.htaccess`

---

### cron_jobs.txt

**Purpose:** Configuration file for cPanel cron jobs.

**Essential cron jobs:**
1. **Laravel Scheduler** (every minute) - REQUIRED
   ```
   * * * * * cd /home/username/public_html && php artisan schedule:run
   ```

2. **Database Backup** (daily)
   ```
   0 2 * * * cd /home/username && bash backup_namecheap.sh
   ```

3. **Queue Processing** (every 5 minutes)
   ```
   */5 * * * * cd /home/username/public_html && php artisan queue:work --stop-when-empty
   ```

**Setup:**
1. Log in to cPanel
2. Go to Advanced → Cron Jobs
3. Add each cron job from the file
4. Replace 'username' with your actual cPanel username

---

### maintenance.html

**Purpose:** Display professional maintenance page during updates.

**Features:**
- Responsive design
- Bangladesh brand colors
- Animated loading indicator
- Contact information
- Mobile-friendly

**Usage:**
```bash
# To enable maintenance mode
cd /home/username/public_html
cp maintenance.html public/index.html.bak
cp ../maintenance.html public/index.html

# To disable maintenance mode
cd /home/username/public_html/public
mv index.html.bak index.html
```

**Alternative:** Use Laravel's built-in maintenance mode:
```bash
# Enable
php artisan down --render="maintenance"

# Disable
php artisan up
```

---

## 🔄 Update Workflow

### For Regular Updates:

1. **Enable maintenance mode:**
   ```bash
   php artisan down
   ```

2. **Backup current installation:**
   ```bash
   ./backup_namecheap.sh
   ```

3. **Upload updated files:**
   - Use FTP/SFTP to upload only changed files
   - Or use git pull if repository is cloned on server

4. **Update dependencies and database:**
   ```bash
   composer install --optimize-autoloader --no-dev
   php artisan migrate --force
   php artisan optimize
   ```

5. **Test and disable maintenance mode:**
   ```bash
   ./diagnose_server.sh  # Check for issues
   php artisan up
   ```

---

## 🐛 Troubleshooting

### Common Issues and Solutions:

1. **500 Internal Server Error**
   - Run `./diagnose_server.sh`
   - Check `storage/logs/laravel.log`
   - Verify file permissions (storage: 755, .env: 644)
   - Check PHP version in cPanel

2. **Composer Install Fails**
   - Check PHP version: `php -v` (must be 8.2+)
   - Increase memory: add `php_value memory_limit 256M` to .htaccess
   - Run: `composer clear-cache`

3. **Database Connection Error**
   - Verify .env database credentials
   - Check database user privileges in cPanel
   - Ensure DB_HOST is set to 'localhost'

4. **Queue Jobs Not Processing**
   - Verify cron job is running: check cPanel cron logs
   - Manually test: `php artisan queue:work --once`
   - Check queue driver in .env (should be 'database')

5. **Performance Issues**
   - Run: `php artisan optimize`
   - Enable OPcache in cPanel
   - Check .htaccess caching rules
   - Monitor resource usage

---

## 📊 Monitoring

### Regular Checks:

1. **Daily:**
   - Check error logs: `tail -f storage/logs/laravel.log`
   - Verify website is accessible
   - Check email deliverability

2. **Weekly:**
   - Run diagnostic script
   - Review backup logs
   - Check disk space usage
   - Monitor database size

3. **Monthly:**
   - Test backup restoration
   - Review security logs
   - Update dependencies (carefully)
   - Performance audit

---

## 🔒 Security Best Practices

1. **File Permissions:**
   - Directories: 755
   - PHP files: 644
   - .env file: 644 (never 777!)

2. **Environment Variables:**
   - Never commit .env to version control
   - Use strong APP_KEY
   - Disable APP_DEBUG in production

3. **Regular Maintenance:**
   - Keep Laravel and dependencies updated
   - Monitor security advisories
   - Regular backups (automated)
   - Review access logs

4. **Database Security:**
   - Use strong passwords
   - Limit user privileges
   - Regular backups
   - Encrypt sensitive data

---

## 📞 Support

### Resources:
- **Full Deployment Guide:** See `NAMECHEAP_DEPLOYMENT.md`
- **Laravel Docs:** https://laravel.com/docs/deployment
- **Namecheap Support:** https://support.namecheap.com
- **cPanel Docs:** https://docs.cpanel.net

### Getting Help:
1. Run diagnostic script for system check
2. Check Laravel logs for errors
3. Review cPanel error logs
4. Contact Namecheap support for server issues
5. Refer to Laravel documentation for application issues

---

## ✅ Deployment Checklist

Before going live:

- [ ] Run `deploy_to_namecheap.sh` successfully
- [ ] Upload all files to server
- [ ] Configure .env with production settings
- [ ] Run database migrations
- [ ] Set correct file permissions
- [ ] Install SSL certificate
- [ ] Configure cron jobs
- [ ] Test all major features
- [ ] Set up automated backups
- [ ] Configure error monitoring
- [ ] Document custom configurations
- [ ] Test backup restoration process

---

**Last Updated:** 2025-11-09  
**Version:** 1.0  
**Tested With:** Laravel 12.x, PHP 8.2, Namecheap Shared Hosting
