#!/bin/bash

#################################################################################
# Server Diagnostic Script for Gig Marketplace on Namecheap
# Domain: fix.com.bd
#
# Run this script on the server to diagnose common issues
#################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}\n"
}

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header "Gig Marketplace Server Diagnostics"

# Check PHP version
echo "Checking PHP version..."
PHP_VERSION=$(php -v | head -n 1 | cut -d ' ' -f 2)
if [[ "$PHP_VERSION" > "8.2" ]]; then
    print_status "PHP version: $PHP_VERSION (Compatible)"
else
    print_error "PHP version: $PHP_VERSION (Requires 8.2+)"
fi

# Check PHP extensions
echo -e "\nChecking required PHP extensions..."
REQUIRED_EXTENSIONS=("curl" "json" "mbstring" "openssl" "pdo" "tokenizer" "xml" "ctype" "fileinfo" "zip")

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if php -m | grep -q "^$ext$"; then
        print_status "$ext: Installed"
    else
        print_error "$ext: Missing"
    fi
done

# Check file permissions
echo -e "\nChecking file permissions..."
if [ -d "storage" ]; then
    STORAGE_PERMS=$(stat -c "%a" storage 2>/dev/null || stat -f "%Lp" storage 2>/dev/null)
    if [ "$STORAGE_PERMS" == "755" ] || [ "$STORAGE_PERMS" == "775" ]; then
        print_status "storage directory: $STORAGE_PERMS (OK)"
    else
        print_warning "storage directory: $STORAGE_PERMS (Should be 755 or 775)"
    fi
else
    print_error "storage directory not found"
fi

if [ -d "bootstrap/cache" ]; then
    CACHE_PERMS=$(stat -c "%a" bootstrap/cache 2>/dev/null || stat -f "%Lp" bootstrap/cache 2>/dev/null)
    if [ "$CACHE_PERMS" == "755" ] || [ "$CACHE_PERMS" == "775" ]; then
        print_status "bootstrap/cache directory: $CACHE_PERMS (OK)"
    else
        print_warning "bootstrap/cache directory: $CACHE_PERMS (Should be 755 or 775)"
    fi
else
    print_error "bootstrap/cache directory not found"
fi

# Check .env file
echo -e "\nChecking environment configuration..."
if [ -f ".env" ]; then
    print_status ".env file exists"
    
    # Check APP_KEY
    if grep -q "APP_KEY=base64:" .env; then
        print_status "APP_KEY is set"
    else
        print_error "APP_KEY not set. Run: php artisan key:generate"
    fi
    
    # Check database configuration
    if grep -q "DB_DATABASE=" .env && grep -q "DB_USERNAME=" .env; then
        print_status "Database configuration present"
    else
        print_warning "Database configuration may be incomplete"
    fi
else
    print_error ".env file not found"
fi

# Check .htaccess files
echo -e "\nChecking .htaccess configuration..."
if [ -f ".htaccess" ]; then
    print_status "Root .htaccess exists"
else
    print_warning "Root .htaccess not found"
fi

if [ -f "public/.htaccess" ]; then
    print_status "Public .htaccess exists"
else
    print_error "Public .htaccess not found"
fi

# Check composer dependencies
echo -e "\nChecking Composer dependencies..."
if [ -d "vendor" ]; then
    print_status "Vendor directory exists"
    if [ -f "vendor/autoload.php" ]; then
        print_status "Composer autoloader present"
    else
        print_error "Composer autoloader missing. Run: composer install"
    fi
else
    print_error "Vendor directory not found. Run: composer install"
fi

# Check database connection
echo -e "\nTesting database connection..."
if php artisan migrate:status >/dev/null 2>&1; then
    print_status "Database connection successful"
else
    print_error "Database connection failed. Check .env credentials"
fi

# Check storage link
echo -e "\nChecking storage link..."
if [ -L "public/storage" ]; then
    print_status "Storage link exists"
else
    print_warning "Storage link not found. Run: php artisan storage:link"
fi

# Check log files
echo -e "\nChecking recent errors..."
if [ -f "storage/logs/laravel.log" ]; then
    RECENT_ERRORS=$(tail -n 50 storage/logs/laravel.log | grep -c "ERROR" || echo "0")
    if [ "$RECENT_ERRORS" -gt 0 ]; then
        print_warning "Found $RECENT_ERRORS recent errors in log"
        echo -e "\nRecent errors (last 10 lines):"
        echo -e "${RED}"
        tail -n 10 storage/logs/laravel.log | grep "ERROR"
        echo -e "${NC}"
    else
        print_status "No recent errors in log"
    fi
else
    print_warning "No log file found yet"
fi

# Check web server
echo -e "\nChecking web server..."
if command -v apache2 &> /dev/null; then
    print_status "Apache detected"
    if apache2 -M 2>/dev/null | grep -q rewrite; then
        print_status "mod_rewrite is enabled"
    else
        print_warning "mod_rewrite status unknown (may require root)"
    fi
elif command -v nginx &> /dev/null; then
    print_status "Nginx detected"
else
    print_warning "Web server type unknown"
fi

# Memory and disk space
echo -e "\nChecking system resources..."
if command -v free &> /dev/null; then
    MEMORY=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
    echo -e "Memory usage: $MEMORY"
fi

DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}')
echo -e "Disk usage: $DISK_USAGE"

# Summary
print_header "Diagnostic Summary"

echo -e "Run this script regularly to check server health."
echo -e "For detailed troubleshooting, see NAMECHEAP_DEPLOYMENT.md"
echo -e "\n${YELLOW}Common fixes:${NC}"
echo -e "  • 500 Error: Check storage permissions and .env file"
echo -e "  • Database Error: Verify .env database credentials"
echo -e "  • Composer Error: Run 'composer install --no-dev'"
echo -e "  • Cache Issues: Run 'php artisan optimize:clear'"

echo -e "\n${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Diagnostic check completed! ${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}\n"
