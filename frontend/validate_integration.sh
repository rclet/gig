#!/bin/bash

# Flutter Frontend API Integration Validation Script
# This script validates that all required components are in place

echo "============================================"
echo "Flutter Frontend API Integration Validation"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PASSED=0
FAILED=0

check_file() {
    TOTAL=$((TOTAL + 1))
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $2 (Missing: $1)"
        FAILED=$((FAILED + 1))
    fi
}

check_dir() {
    TOTAL=$((TOTAL + 1))
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $2 (Missing: $1)"
        FAILED=$((FAILED + 1))
    fi
}

cd frontend

echo "Core Infrastructure"
echo "-------------------"
check_file "lib/core/api_client.dart" "API Client"
check_file "lib/core/token_store.dart" "Token Store"
check_file "lib/core/error_mapper.dart" "Error Mapper"
check_file "lib/core/config/environment_config.dart" "Environment Config"
echo ""

echo "Auth Features"
echo "-------------"
check_dir "lib/features/auth/services" "Auth Services Directory"
check_file "lib/features/auth/services/auth_service.dart" "Auth Service"
check_file "lib/features/auth/providers/auth_provider.dart" "Auth Provider"
check_file "lib/features/auth/screens/login_screen.dart" "Login Screen"
check_file "lib/features/auth/screens/register_screen.dart" "Register Screen"
echo ""

echo "Users Features"
echo "--------------"
check_dir "lib/features/users/services" "Users Services Directory"
check_file "lib/features/users/services/users_service.dart" "Users Service"
echo ""

echo "Jobs Features"
echo "-------------"
check_dir "lib/features/jobs/services" "Jobs Services Directory"
check_file "lib/features/jobs/services/jobs_service.dart" "Jobs Service"
check_file "lib/features/jobs/screens/job_list_screen.dart" "Job List Screen"
check_file "lib/features/jobs/screens/job_detail_screen.dart" "Job Detail Screen"
echo ""

echo "Chat Features"
echo "-------------"
check_dir "lib/features/chat/services" "Chat Services Directory"
check_file "lib/features/chat/services/chat_service.dart" "Chat Service"
check_file "lib/features/chat/screens/chat_list_screen.dart" "Chat List Screen"
echo ""

echo "Projects Features"
echo "-----------------"
check_dir "lib/features/projects/services" "Projects Services Directory"
check_file "lib/features/projects/services/projects_service.dart" "Projects Service"
check_file "lib/features/projects/screens/project_list_screen.dart" "Project List Screen"
echo ""

echo "Proposals Features"
echo "------------------"
check_dir "lib/features/proposals/services" "Proposals Services Directory"
check_file "lib/features/proposals/services/proposals_service.dart" "Proposals Service"
check_file "lib/features/proposals/screens/my_proposals_screen.dart" "My Proposals Screen"
echo ""

echo "Notifications Features"
echo "----------------------"
check_dir "lib/features/notifications/services" "Notifications Services Directory"
check_file "lib/features/notifications/services/notifications_service.dart" "Notifications Service"
check_file "lib/features/notifications/screens/notifications_screen.dart" "Notifications Screen"
echo ""

echo "Routing & Guards"
echo "----------------"
check_file "lib/core/routing/app_router.dart" "App Router with Guards"
check_file "lib/shared/screens/splash_screen.dart" "Splash Screen with Auth Check"
echo ""

echo "Documentation"
echo "-------------"
check_file "API_INTEGRATION_GUIDE.md" "API Integration Guide"
echo ""

# Count endpoints in services
echo "Endpoint Coverage"
echo "-----------------"
echo "Counting implemented service methods..."

AUTH_METHODS=$(grep -c "static Future" lib/features/auth/services/auth_service.dart 2>/dev/null || echo "0")
USERS_METHODS=$(grep -c "static Future" lib/features/users/services/users_service.dart 2>/dev/null || echo "0")
JOBS_METHODS=$(grep -c "static Future" lib/features/jobs/services/jobs_service.dart 2>/dev/null || echo "0")
CHAT_METHODS=$(grep -c "static Future" lib/features/chat/services/chat_service.dart 2>/dev/null || echo "0")
PROJECTS_METHODS=$(grep -c "static Future" lib/features/projects/services/projects_service.dart 2>/dev/null || echo "0")
PROPOSALS_METHODS=$(grep -c "static Future" lib/features/proposals/services/proposals_service.dart 2>/dev/null || echo "0")
NOTIFICATIONS_METHODS=$(grep -c "static Future" lib/features/notifications/services/notifications_service.dart 2>/dev/null || echo "0")

TOTAL_METHODS=$((AUTH_METHODS + USERS_METHODS + JOBS_METHODS + CHAT_METHODS + PROJECTS_METHODS + PROPOSALS_METHODS + NOTIFICATIONS_METHODS))

echo -e "Auth Service:          ${GREEN}$AUTH_METHODS${NC} methods"
echo -e "Users Service:         ${GREEN}$USERS_METHODS${NC} methods"
echo -e "Jobs Service:          ${GREEN}$JOBS_METHODS${NC} methods"
echo -e "Chat Service:          ${GREEN}$CHAT_METHODS${NC} methods"
echo -e "Projects Service:      ${GREEN}$PROJECTS_METHODS${NC} methods"
echo -e "Proposals Service:     ${GREEN}$PROPOSALS_METHODS${NC} methods"
echo -e "Notifications Service: ${GREEN}$NOTIFICATIONS_METHODS${NC} methods"
echo -e "${YELLOW}Total Service Methods: ${TOTAL_METHODS}${NC}"
echo ""

# Summary
echo "============================================"
echo "Summary"
echo "============================================"
echo -e "Total Checks:  $TOTAL"
echo -e "${GREEN}Passed:        $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed:        $FAILED${NC}"
else
    echo -e "Failed:        $FAILED"
fi
echo ""

# Success rate
SUCCESS_RATE=$((PASSED * 100 / TOTAL))
if [ $SUCCESS_RATE -eq 100 ]; then
    echo -e "${GREEN}✓ All checks passed! Frontend is ready.${NC}"
    exit 0
elif [ $SUCCESS_RATE -ge 90 ]; then
    echo -e "${YELLOW}⚠ Most checks passed ($SUCCESS_RATE%). Review failures above.${NC}"
    exit 0
else
    echo -e "${RED}✗ Several checks failed ($SUCCESS_RATE%). Review failures above.${NC}"
    exit 1
fi
