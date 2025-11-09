#!/bin/bash

#################################################################################
# Namecheap Shared Hosting Deployment Script for Gig Marketplace
# Domain: fix.com.bd
#
# This script prepares the Laravel backend for deployment to Namecheap
# shared hosting environment.
#################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEPLOY_DIR="deploy_package"
BACKEND_DIR="backend"
EXCLUDE_FILES=(
    ".git"
    ".gitignore"
    ".github"
    "tests"
    "node_modules"
    "storage/logs/*"
    "storage/framework/cache/*"
    "storage/framework/sessions/*"
    "storage/framework/views/*"
    ".env"
    ".env.example"
    "phpunit.xml"
    "README.md"
    ".editorconfig"
    ".styleci.yml"
    "vite.config.js"
    "package.json"
    "package-lock.json"
)

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}\n"
}

# Check if backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    print_error "Backend directory not found. Please run from project root."
    exit 1
fi

print_header "Namecheap Deployment Package Creator"

# Step 1: Clean previous deployment
print_info "Step 1/7: Cleaning previous deployment..."
if [ -d "$DEPLOY_DIR" ]; then
    rm -rf "$DEPLOY_DIR"
    print_status "Removed previous deployment directory"
fi
mkdir -p "$DEPLOY_DIR"
print_status "Created fresh deployment directory"

# Step 2: Copy backend files
print_info "Step 2/7: Copying backend files..."
cp -r "$BACKEND_DIR"/* "$DEPLOY_DIR/"
print_status "Backend files copied"

# Step 3: Install production dependencies
print_info "Step 3/7: Installing production dependencies..."
cd "$DEPLOY_DIR"

if command -v composer &> /dev/null; then
    print_info "Running composer install..."
    composer install --optimize-autoloader --no-dev --no-interaction
    print_status "Production dependencies installed"
else
    print_warning "Composer not found. You'll need to run 'composer install' on the server."
fi

cd ..

# Step 4: Create production environment template
print_info "Step 4/7: Creating production environment template..."
cat > "$DEPLOY_DIR/.env.production" << 'EOF'
# Production Environment Configuration for fix.com.bd
# Copy this file to .env and update with your actual values

APP_NAME="Gig Marketplace"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://fix.com.bd

# IMPORTANT: Generate a new key on the server with: php artisan key:generate
APP_KEY=

# Database Configuration - Get from cPanel MySQL Databases
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_secure_password

# Session & Cache (file driver for shared hosting)
SESSION_DRIVER=file
SESSION_LIFETIME=120
CACHE_DRIVER=file
QUEUE_CONNECTION=database

# Mail Configuration - Use cPanel email
MAIL_MAILER=smtp
MAIL_HOST=mail.fix.com.bd
MAIL_PORT=587
MAIL_USERNAME=noreply@fix.com.bd
MAIL_PASSWORD=your_email_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@fix.com.bd"
MAIL_FROM_NAME="${APP_NAME}"

# Filesystem
FILESYSTEM_DISK=local

# Broadcasting (use log for shared hosting)
BROADCAST_CONNECTION=log

# Security
SANCTUM_STATEFUL_DOMAINS=fix.com.bd,www.fix.com.bd

# Disable features that require special configuration
REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Currency & Localization
DEFAULT_CURRENCY=BDT
SUPPORTED_CURRENCIES=BDT,USD,EUR,GBP

# Rate Limiting
API_RATE_LIMIT=60
AUTH_RATE_LIMIT=5
EOF

print_status "Production environment template created"

# Step 5: Optimize for production
print_info "Step 5/7: Optimizing for production..."

# Remove development files
cd "$DEPLOY_DIR"
rm -f .env.example README.md phpunit.xml
rm -rf tests/

# Create required directories
mkdir -p storage/app/public
mkdir -p storage/framework/{cache,sessions,views}
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Create gitkeep files to preserve structure
touch storage/app/.gitkeep
touch storage/app/public/.gitkeep
touch storage/framework/cache/.gitkeep
touch storage/framework/sessions/.gitkeep
touch storage/framework/views/.gitkeep
touch storage/logs/.gitkeep

print_status "Production optimization complete"

cd ..

# Step 6: Create deployment instructions
print_info "Step 6/7: Creating deployment instructions..."
cat > "$DEPLOY_DIR/UPLOAD_INSTRUCTIONS.txt" << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║         NAMECHEAP SHARED HOSTING UPLOAD INSTRUCTIONS          ║
║                    for fix.com.bd                             ║
╚═══════════════════════════════════════════════════════════════╝

STEP-BY-STEP UPLOAD PROCESS:

1. PREPARE YOUR HOSTING
   ----------------------
   □ Log in to cPanel at: https://cpanel.namecheap.com
   □ Ensure PHP version is set to 8.2 or higher (Software → Select PHP Version)
   □ Create MySQL database (MySQL Databases section):
     - Database name: username_gig_marketplace
     - Create database user with strong password
     - Add user to database with ALL PRIVILEGES
     - Note down credentials

2. UPLOAD FILES VIA FTP/SFTP
   --------------------------
   □ Open FileZilla or your FTP client
   □ Connect to: ftp.fix.com.bd (or your server IP)
   □ Username: Your cPanel username
   □ Password: Your cPanel password
   
   □ Navigate to /public_html directory
   □ Upload ALL files from this deploy_package folder
   □ This may take 10-30 minutes depending on your connection

3. CONFIGURE ENVIRONMENT
   ----------------------
   □ In cPanel File Manager, navigate to /public_html
   □ Rename .env.production to .env
   □ Edit .env file with your actual database credentials
   □ Save the file

4. SET FILE PERMISSIONS
   --------------------
   Via cPanel File Manager:
   □ Select 'storage' folder → Right-click → Change Permissions → 755
   □ Select 'bootstrap/cache' → Right-click → Change Permissions → 755
   □ Select '.env' file → Right-click → Change Permissions → 644

5. INITIALIZE APPLICATION
   -----------------------
   Via cPanel Terminal or SSH:
   
   cd public_html
   php artisan key:generate
   php artisan migrate --force
   php artisan db:seed --force
   php artisan storage:link
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache

6. INSTALL SSL CERTIFICATE
   ------------------------
   □ In cPanel → SSL/TLS Status
   □ Find fix.com.bd → Click "Run AutoSSL"
   □ Wait for certificate installation
   □ Test: https://fix.com.bd should work

7. CONFIGURE CRON JOBS
   -------------------
   □ In cPanel → Cron Jobs
   □ Add new cron job:
     Command: cd /home/username/public_html && php artisan schedule:run >> /dev/null 2>&1
     Schedule: * * * * * (every minute)

8. TEST YOUR DEPLOYMENT
   --------------------
   □ Visit: https://fix.com.bd
   □ Test API: https://fix.com.bd/api/health
   □ Check error logs in cPanel if issues occur
   □ Monitor: storage/logs/laravel.log

9. POST-DEPLOYMENT
   ---------------
   □ Set up automated backups in cPanel
   □ Configure email notifications
   □ Test all critical functionality
   □ Document any custom configurations

TROUBLESHOOTING:
───────────────
• 500 Error: Check storage/logs/laravel.log
• Database Error: Verify .env database credentials
• Permission Error: Set storage and bootstrap/cache to 755
• .htaccess Error: Ensure mod_rewrite is enabled (contact support)

For detailed instructions, see NAMECHEAP_DEPLOYMENT.md in the repository.

═══════════════════════════════════════════════════════════════
Support: Check cPanel error logs or contact Namecheap support
═══════════════════════════════════════════════════════════════
EOF

print_status "Upload instructions created"

# Step 7: Create deployment package archive
print_info "Step 7/7: Creating deployment archive..."
ARCHIVE_NAME="gig_marketplace_namecheap_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$ARCHIVE_NAME" "$DEPLOY_DIR"
print_status "Deployment archive created: $ARCHIVE_NAME"

# Summary
print_header "Deployment Package Ready!"

echo -e "${GREEN}✅ Deployment package created successfully!${NC}\n"
echo -e "${BLUE}📦 Package Location:${NC} ./$DEPLOY_DIR/"
echo -e "${BLUE}📦 Archive File:${NC} ./$ARCHIVE_NAME"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "  1. Extract or use the $DEPLOY_DIR folder"
echo -e "  2. Read UPLOAD_INSTRUCTIONS.txt for detailed upload steps"
echo -e "  3. Upload all files to your Namecheap hosting"
echo -e "  4. Follow the configuration steps in the instructions"
echo -e "\n${BLUE}Files Prepared:${NC}"
echo -e "  • Laravel application with production dependencies"
echo -e "  • Optimized .htaccess files"
echo -e "  • Production environment template (.env.production)"
echo -e "  • Upload instructions (UPLOAD_INSTRUCTIONS.txt)"
echo -e "\n${GREEN}Ready to deploy to fix.com.bd! 🚀${NC}\n"

# Create quick reference
cat > "QUICK_REFERENCE.txt" << 'EOF'
QUICK DEPLOYMENT REFERENCE
═════════════════════════

1. Upload contents of 'deploy_package' to /public_html via FTP
2. Rename .env.production to .env
3. Edit .env with database credentials
4. Set permissions: storage (755), bootstrap/cache (755)
5. Run: php artisan key:generate
6. Run: php artisan migrate --force
7. Run: php artisan optimize
8. Install SSL in cPanel
9. Test: https://fix.com.bd

For detailed steps, see: deploy_package/UPLOAD_INSTRUCTIONS.txt
For troubleshooting, see: NAMECHEAP_DEPLOYMENT.md
EOF

print_status "Quick reference created: QUICK_REFERENCE.txt"
echo -e "\n${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Deployment preparation completed successfully! ✅${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}\n"
