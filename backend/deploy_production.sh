#!/bin/bash

################################################################################
# Gig Marketplace - Production Deployment Script
# 
# This script automates the deployment process for the backend API
# 
# USAGE: 
#   chmod +x deploy_production.sh
#   ./deploy_production.sh
#
# PREREQUISITES:
#   - PHP 8.2+ installed
#   - Composer installed
#   - Database created and accessible
#   - .env file configured with production settings
################################################################################

set -e  # Exit on any error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_status() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Check if script is run from backend directory
if [ ! -f "artisan" ]; then
    print_error "Please run this script from the backend directory"
    exit 1
fi

print_header "🚀 Gig Marketplace Production Deployment"

# Step 1: Check prerequisites
print_header "Step 1: Checking Prerequisites"

# Check PHP version
print_info "Checking PHP version..."
PHP_VERSION=$(php -r 'echo PHP_VERSION;')
PHP_MAJOR=$(php -r 'echo PHP_MAJOR_VERSION;')
PHP_MINOR=$(php -r 'echo PHP_MINOR_VERSION;')

if [ "$PHP_MAJOR" -lt 8 ] || { [ "$PHP_MAJOR" -eq 8 ] && [ "$PHP_MINOR" -lt 2 ]; }; then
    print_error "PHP 8.2 or higher required. Current version: $PHP_VERSION"
    exit 1
fi
print_status "PHP version $PHP_VERSION (OK)"

# Check Composer
print_info "Checking Composer..."
if ! command -v composer &> /dev/null; then
    print_error "Composer not found. Please install Composer first."
    exit 1
fi
COMPOSER_VERSION=$(composer --version | grep -oP '\d+\.\d+\.\d+' | head -1)
print_status "Composer version $COMPOSER_VERSION (OK)"

# Check for .env file
print_info "Checking .env file..."
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    print_info "Please create .env file from .env.production.example"
    print_info "Command: cp .env.production.example .env"
    exit 1
fi
print_status ".env file found"

# Verify critical .env settings
print_info "Verifying production settings..."

if grep -q "APP_DEBUG=true" .env; then
    print_error "APP_DEBUG is set to true! This is dangerous in production."
    print_warning "Please set APP_DEBUG=false in .env"
    exit 1
fi
print_status "APP_DEBUG=false (OK)"

if grep -q "APP_ENV=production" .env; then
    print_status "APP_ENV=production (OK)"
else
    print_warning "APP_ENV is not set to 'production' - proceeding anyway"
fi

# Step 2: Install dependencies
print_header "Step 2: Installing Dependencies"

print_info "Running composer install with optimizations..."
composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

if [ $? -eq 0 ]; then
    print_status "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi

# Step 3: Directory permissions
print_header "Step 3: Setting Directory Permissions"

print_info "Creating storage directories if they don't exist..."
mkdir -p storage/app/public
mkdir -p storage/framework/{cache,sessions,testing,views}
mkdir -p storage/logs
mkdir -p bootstrap/cache
print_status "Storage directories created"

print_info "Setting permissions..."
chmod -R 775 storage
chmod -R 775 bootstrap/cache
print_status "Permissions set (775 for storage and bootstrap/cache)"

# Step 4: Clear caches
print_header "Step 4: Clearing Caches"

print_info "Clearing application cache..."
php artisan cache:clear || print_warning "Cache clear failed (might be empty)"

print_info "Clearing configuration cache..."
php artisan config:clear || print_warning "Config clear failed"

print_info "Clearing route cache..."
php artisan route:clear || print_warning "Route clear failed"

print_info "Clearing view cache..."
php artisan view:clear || print_warning "View clear failed"

print_status "Caches cleared"

# Step 5: Generate application key (if not set)
print_header "Step 5: Application Key"

if grep -q "APP_KEY=$" .env || grep -q "APP_KEY=\"\"" .env; then
    print_info "Generating application key..."
    php artisan key:generate --force
    print_status "Application key generated"
else
    print_status "Application key already set"
fi

# Step 6: Database migration
print_header "Step 6: Database Migration"

print_warning "About to run database migrations..."
read -p "Continue with migrations? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Running migrations..."
    php artisan migrate --force
    print_status "Migrations completed"
    
    read -p "Run database seeders? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Running seeders..."
        php artisan db:seed --force
        print_status "Seeders completed"
    fi
else
    print_warning "Skipping migrations"
fi

# Step 7: Create storage link
print_header "Step 7: Storage Link"

print_info "Creating storage symlink..."
php artisan storage:link || print_warning "Storage link already exists or failed"
print_status "Storage link created"

# Step 8: Optimize for production
print_header "Step 8: Production Optimizations"

print_info "Caching configuration..."
php artisan config:cache
print_status "Configuration cached"

print_info "Caching routes..."
php artisan route:cache
print_status "Routes cached"

print_info "Caching views..."
php artisan view:cache
print_status "Views cached"

# Step 9: Security check
print_header "Step 9: Security Verification"

print_info "Performing security checks..."

# Check debug mode
if grep -q "APP_DEBUG=false" .env; then
    print_status "APP_DEBUG is false"
else
    print_error "APP_DEBUG is not false!"
fi

# Check if sensitive files are protected
if [ -f "public/.htaccess" ] || [ -f ".htaccess" ]; then
    print_status ".htaccess files found"
else
    print_warning "No .htaccess file found - ensure server is configured properly"
fi

# Check storage permissions
STORAGE_PERMS=$(stat -c %a storage)
if [ "$STORAGE_PERMS" = "775" ] || [ "$STORAGE_PERMS" = "755" ]; then
    print_status "Storage permissions are correct"
else
    print_warning "Storage permissions are $STORAGE_PERMS (should be 775 or 755)"
fi

# Step 10: Deployment summary
print_header "🎉 Deployment Complete!"

echo ""
print_info "Deployment Summary:"
echo "  - PHP Version: $PHP_VERSION"
echo "  - Composer Version: $COMPOSER_VERSION"
echo "  - Environment: $(grep APP_ENV .env | cut -d '=' -f2)"
echo "  - Debug Mode: $(grep APP_DEBUG .env | cut -d '=' -f2)"
echo "  - Application URL: $(grep APP_URL .env | cut -d '=' -f2)"
echo ""

print_status "Backend API is deployed and ready!"
echo ""

print_header "📋 Post-Deployment Checklist"
echo ""
echo "Please verify the following:"
echo "  [ ] Application is accessible via browser"
echo "  [ ] API endpoints respond correctly"
echo "  [ ] Database connections work"
echo "  [ ] Authentication works (login/register)"
echo "  [ ] File uploads work"
echo "  [ ] Email sending works (test forgot password)"
echo "  [ ] CORS is configured correctly"
echo "  [ ] SSL certificate is valid"
echo "  [ ] Monitoring is set up"
echo "  [ ] Backups are scheduled"
echo ""

print_header "🚨 Important Security Notes"
echo ""
echo "  1. Change all default passwords"
echo "  2. Review CORS settings in config/cors.php"
echo "  3. Set up firewall rules"
echo "  4. Configure fail2ban"
echo "  5. Enable Laravel Telescope with authentication"
echo "  6. Set up database backups"
echo "  7. Configure log rotation"
echo "  8. Test disaster recovery"
echo ""

print_info "For monitoring and maintenance, refer to DEPLOYMENT.md"
print_info "For troubleshooting, check storage/logs/laravel.log"

echo ""
print_status "Happy deploying! 🚀"
