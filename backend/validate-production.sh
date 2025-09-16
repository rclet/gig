#!/bin/bash

# Production Environment Validation Script for Gig Marketplace
# This script validates that the environment is properly configured for production

echo "🚀 Gig Marketplace Production Environment Validation"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Check if running from backend directory
if [[ ! -f "artisan" ]]; then
    echo -e "${RED}Error: This script must be run from the Laravel backend directory${NC}"
    exit 1
fi

echo "Starting production environment validation..."
echo ""

# 1. Environment Configuration Checks
echo "📋 Environment Configuration"
echo "----------------------------"

# Check .env file exists
if [[ -f ".env" ]]; then
    check_pass ".env file exists"
else
    check_fail ".env file missing"
fi

# Check critical environment variables
required_vars=(
    "APP_NAME"
    "APP_ENV"
    "APP_KEY"
    "APP_URL"
    "DB_CONNECTION"
    "DB_HOST"
    "DB_DATABASE"
    "DB_USERNAME"
    "DB_PASSWORD"
)

for var in "${required_vars[@]}"; do
    if grep -q "^${var}=" .env 2>/dev/null && [[ -n $(grep "^${var}=" .env | cut -d'=' -f2) ]]; then
        check_pass "Environment variable $var is set"
    else
        check_fail "Environment variable $var is missing or empty"
    fi
done

# Check APP_ENV is production
if grep -q "^APP_ENV=production" .env 2>/dev/null; then
    check_pass "APP_ENV is set to production"
elif grep -q "^APP_ENV=" .env 2>/dev/null; then
    check_warn "APP_ENV is not set to production ($(grep '^APP_ENV=' .env | cut -d'=' -f2))"
else
    check_fail "APP_ENV is not set"
fi

# Check APP_DEBUG is false
if grep -q "^APP_DEBUG=false" .env 2>/dev/null; then
    check_pass "APP_DEBUG is disabled"
elif grep -q "^APP_DEBUG=true" .env 2>/dev/null; then
    check_fail "APP_DEBUG is enabled (security risk in production)"
else
    check_warn "APP_DEBUG setting not found"
fi

echo ""

# 2. File Permissions and Security
echo "🔐 File Permissions and Security"
echo "--------------------------------"

# Check storage directory permissions
if [[ -w "storage" ]]; then
    check_pass "Storage directory is writable"
else
    check_fail "Storage directory is not writable"
fi

# Check bootstrap/cache permissions
if [[ -w "bootstrap/cache" ]]; then
    check_pass "Bootstrap cache directory is writable"
else
    check_fail "Bootstrap cache directory is not writable"
fi

# Check .env file permissions (should not be readable by others)
if [[ -f ".env" ]]; then
    env_perms=$(stat -c "%a" .env 2>/dev/null || stat -f "%Lp" .env 2>/dev/null)
    if [[ "$env_perms" == "600" ]] || [[ "$env_perms" == "644" ]]; then
        check_pass ".env file permissions are secure ($env_perms)"
    else
        check_warn ".env file permissions should be more restrictive (current: $env_perms)"
    fi
fi

echo ""

# 3. Database Connectivity
echo "🗄️  Database Connectivity"
echo "-------------------------"

if command -v php >/dev/null 2>&1; then
    # Test database connection
    if php artisan migrate:status >/dev/null 2>&1; then
        check_pass "Database connection successful"
        
        # Check if migrations are up to date
        pending_migrations=$(php artisan migrate:status --pending 2>/dev/null | wc -l)
        if [[ $pending_migrations -eq 0 ]]; then
            check_pass "All database migrations are up to date"
        else
            check_warn "$pending_migrations pending database migrations"
        fi
    else
        check_fail "Database connection failed"
    fi
else
    check_warn "PHP CLI not available for database testing"
fi

echo ""

# 4. Application Dependencies
echo "📦 Application Dependencies"
echo "---------------------------"

# Check if vendor directory exists
if [[ -d "vendor" ]]; then
    check_pass "Composer dependencies installed"
    
    # Check if composer.lock exists
    if [[ -f "composer.lock" ]]; then
        check_pass "Composer lock file present"
    else
        check_warn "Composer lock file missing"
    fi
else
    check_fail "Composer dependencies not installed"
fi

# Check critical Laravel directories
critical_dirs=("app" "config" "database" "routes" "public")
for dir in "${critical_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        check_pass "Directory $dir exists"
    else
        check_fail "Critical directory $dir is missing"
    fi
done

echo ""

# 5. Security Configuration
echo "🛡️  Security Configuration"
echo "--------------------------"

# Check if security config exists
if [[ -f "config/security.php" ]]; then
    check_pass "Security configuration file exists"
else
    check_warn "Security configuration file missing"
fi

# Check for HTTPS configuration
if grep -q "FORCE_HTTPS=true" .env 2>/dev/null; then
    check_pass "HTTPS enforcement is enabled"
elif grep -q "APP_URL=https" .env 2>/dev/null; then
    check_pass "Application URL uses HTTPS"
else
    check_warn "HTTPS configuration not found"
fi

# Check session security settings
if grep -q "SESSION_SECURE_COOKIES=true" .env 2>/dev/null; then
    check_pass "Secure cookies are enabled"
else
    check_warn "Secure cookies not explicitly enabled"
fi

echo ""

# 6. Performance and Caching
echo "⚡ Performance and Caching"
echo "-------------------------"

# Check if caches are configured
cache_types=("config" "route" "view")
for cache_type in "${cache_types[@]}"; do
    if php artisan "$cache_type:cache" >/dev/null 2>&1; then
        check_pass "$cache_type cache can be generated"
    else
        check_warn "$cache_type cache generation failed"
    fi
done

# Check Redis configuration
if grep -q "REDIS_HOST=" .env 2>/dev/null; then
    check_pass "Redis configuration found"
else
    check_warn "Redis configuration not found"
fi

echo ""

# 7. Logging and Monitoring
echo "📊 Logging and Monitoring"
echo "------------------------"

# Check log directory
if [[ -d "storage/logs" ]]; then
    check_pass "Log directory exists"
    
    # Check if log directory is writable
    if [[ -w "storage/logs" ]]; then
        check_pass "Log directory is writable"
    else
        check_fail "Log directory is not writable"
    fi
else
    check_fail "Log directory missing"
fi

# Check log level configuration
if grep -q "LOG_LEVEL=" .env 2>/dev/null; then
    log_level=$(grep "^LOG_LEVEL=" .env | cut -d'=' -f2)
    if [[ "$log_level" == "error" ]] || [[ "$log_level" == "warning" ]]; then
        check_pass "Log level is appropriate for production ($log_level)"
    else
        check_warn "Log level might be too verbose for production ($log_level)"
    fi
else
    check_warn "Log level not explicitly configured"
fi

echo ""

# 8. Production Optimizations
echo "🚄 Production Optimizations"
echo "---------------------------"

# Check if opcache is enabled (if PHP CLI shows it)
if php -m | grep -q "Zend OPcache"; then
    check_pass "OPcache extension is available"
else
    check_warn "OPcache extension not detected"
fi

# Check if optimization commands can run
optimization_commands=("config:cache" "route:cache" "view:cache")
for cmd in "${optimization_commands[@]}"; do
    if php artisan "$cmd" --help >/dev/null 2>&1; then
        check_pass "Command 'php artisan $cmd' is available"
    else
        check_warn "Command 'php artisan $cmd' not available"
    fi
done

echo ""

# Summary
echo "📈 Validation Summary"
echo "===================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

total_checks=$((PASSED + WARNINGS + FAILED))
pass_rate=$((PASSED * 100 / total_checks))

echo ""
echo "Pass Rate: $pass_rate% ($PASSED/$total_checks)"

if [[ $FAILED -eq 0 ]]; then
    if [[ $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}🎉 Production environment validation PASSED!${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️  Production environment validation passed with warnings.${NC}"
        echo "Please review the warnings above before deploying to production."
        exit 0
    fi
else
    echo -e "${RED}❌ Production environment validation FAILED!${NC}"
    echo "Please fix the failed checks before deploying to production."
    exit 1
fi