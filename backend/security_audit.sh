#!/bin/bash

################################################################################
# Security Audit Script for Gig Marketplace
# 
# This script performs security checks on the deployment
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_header() { echo -e "\n${BLUE}========================================\n$1\n========================================${NC}"; }

ISSUES_FOUND=0
WARNINGS_FOUND=0

check_fail() {
    print_error "$1"
    ((ISSUES_FOUND++))
}

check_warn() {
    print_warning "$1"
    ((WARNINGS_FOUND++))
}

check_pass() {
    print_status "$1"
}

# Navigate to backend directory
if [ ! -f "artisan" ]; then
    print_error "Please run this script from the backend directory"
    exit 1
fi

print_header "🔒 Security Audit for Gig Marketplace"

# Check 1: .env file exists
print_header "Checking Environment Configuration"

if [ ! -f ".env" ]; then
    check_fail ".env file not found! Application cannot run."
else
    check_pass ".env file exists"
    
    # Check debug mode
    if grep -q "APP_DEBUG=true" .env; then
        check_fail "APP_DEBUG=true in production is a CRITICAL security risk!"
    else
        check_pass "APP_DEBUG is false or not set to true"
    fi
    
    # Check environment
    if grep -q "APP_ENV=production" .env; then
        check_pass "APP_ENV is set to production"
    else
        check_warn "APP_ENV is not set to 'production'"
    fi
    
    # Check APP_KEY is set
    if grep -q "APP_KEY=$" .env || grep -q "APP_KEY=\"\"" .env; then
        check_fail "APP_KEY is not set! Generate with: php artisan key:generate"
    else
        check_pass "APP_KEY is set"
    fi
    
    # Check database is configured
    if grep -q "DB_DATABASE=$" .env || grep -q "DB_USERNAME=$" .env; then
        check_fail "Database credentials are not configured"
    else
        check_pass "Database credentials appear to be configured"
    fi
fi

# Check 2: File permissions
print_header "Checking File Permissions"

if [ -d "storage" ]; then
    STORAGE_PERMS=$(stat -c %a storage 2>/dev/null || echo "unknown")
    if [ "$STORAGE_PERMS" = "775" ] || [ "$STORAGE_PERMS" = "755" ]; then
        check_pass "Storage directory permissions are correct ($STORAGE_PERMS)"
    elif [ "$STORAGE_PERMS" = "777" ]; then
        check_warn "Storage directory is 777 (too permissive, should be 775 or 755)"
    else
        check_warn "Storage directory permissions are $STORAGE_PERMS (should be 775 or 755)"
    fi
else
    check_fail "Storage directory does not exist!"
fi

if [ -d "bootstrap/cache" ]; then
    check_pass "bootstrap/cache directory exists"
else
    check_fail "bootstrap/cache directory does not exist!"
fi

# Check 3: Sensitive files protection
print_header "Checking Sensitive Files Protection"

if [ -f "public/.htaccess" ]; then
    check_pass ".htaccess file exists for Apache"
else
    check_warn ".htaccess file not found (ensure Nginx config is secure)"
fi

# Check that .env is not in public directory
if [ -f "public/.env" ]; then
    check_fail ".env file found in public directory! CRITICAL SECURITY RISK!"
else
    check_pass ".env is not in public directory"
fi

# Check 4: Dependencies
print_header "Checking Dependencies"

if [ -d "vendor" ]; then
    check_pass "Vendor directory exists (dependencies installed)"
    
    # Check for dev dependencies in production
    if [ -f "vendor/phpunit" ] || [ -d "vendor/phpunit" ]; then
        check_warn "PHPUnit found in vendor (dev dependencies may be installed)"
        check_warn "Run: composer install --no-dev --optimize-autoloader"
    else
        check_pass "No obvious dev dependencies found"
    fi
else
    check_fail "Vendor directory not found! Run: composer install"
fi

# Check 5: CORS configuration
print_header "Checking CORS Configuration"

if [ -f "config/cors.php" ]; then
    if grep -q "'allowed_origins' => \['\*'\]" config/cors.php; then
        check_fail "CORS allows all origins (*) - SECURITY RISK in production!"
    else
        check_pass "CORS configuration appears to be restricted"
    fi
else
    check_warn "CORS config file not found"
fi

# Check 6: Cache status
print_header "Checking Cache Configuration"

if [ -f "bootstrap/cache/config.php" ]; then
    check_pass "Configuration is cached (good for production)"
    
    # Check if cached config has debug=true
    if grep -q "'debug' => true" bootstrap/cache/config.php; then
        check_fail "Cached config has debug=true! Clear cache and recache."
    fi
else
    check_warn "Configuration is not cached (run: php artisan config:cache)"
fi

if [ -f "bootstrap/cache/routes-v7.php" ]; then
    check_pass "Routes are cached (good for production)"
else
    check_warn "Routes are not cached (run: php artisan route:cache)"
fi

# Check 7: Storage structure
print_header "Checking Storage Structure"

REQUIRED_DIRS=(
    "storage/app"
    "storage/app/public"
    "storage/framework"
    "storage/framework/cache"
    "storage/framework/sessions"
    "storage/framework/views"
    "storage/logs"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        check_pass "$dir exists"
    else
        check_fail "$dir is missing!"
    fi
done

# Check 8: Security headers check (if we can test)
print_header "Security Recommendations"

print_info "Ensure the following are configured on your web server:"
echo "  - Force HTTPS redirect"
echo "  - HSTS header (Strict-Transport-Security)"
echo "  - X-Frame-Options: DENY or SAMEORIGIN"
echo "  - X-Content-Type-Options: nosniff"
echo "  - X-XSS-Protection: 1; mode=block"
echo "  - Content-Security-Policy"

# Check 9: Database connection test
print_header "Testing Database Connection"

if command -v php &> /dev/null && [ -f ".env" ]; then
    print_info "Attempting database connection test..."
    php artisan migrate:status > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        check_pass "Database connection successful"
    else
        check_warn "Database connection test failed or migrations not run"
    fi
else
    check_warn "Cannot test database connection (PHP not available or .env missing)"
fi

# Final Summary
print_header "📊 Security Audit Summary"

echo ""
if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS_FOUND -eq 0 ]; then
    print_status "🎉 No security issues found! Application appears secure."
    echo ""
    exit 0
elif [ $ISSUES_FOUND -eq 0 ]; then
    print_warning "⚠️  Found $WARNINGS_FOUND warning(s). Review recommended but not critical."
    echo ""
    exit 0
else
    print_error "❌ Found $ISSUES_FOUND critical issue(s) and $WARNINGS_FOUND warning(s)."
    print_error "⛔ DO NOT DEPLOY until critical issues are resolved!"
    echo ""
    exit 1
fi
