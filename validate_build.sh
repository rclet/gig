#!/bin/bash

# Build Validation Script for Gig Marketplace
# This script validates the development environment and builds the project

set -e  # Exit on any error

echo "🚀 Gig Marketplace Build Validation"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "frontend/pubspec.yaml" ]; then
    print_error "Please run this script from the root directory of the project"
    exit 1
fi

cd frontend

echo ""
print_info "Step 1: Checking Flutter installation..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    print_info "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
print_status "Flutter version: $FLUTTER_VERSION"

# Check Dart version
DART_VERSION=$(flutter --version | grep "Dart SDK" | cut -d ' ' -f 3)
print_status "Dart SDK version: $DART_VERSION"

# Check if Dart version is compatible
if [[ "$DART_VERSION" < "3.1.0" ]]; then
    print_warning "Dart SDK version $DART_VERSION may be incompatible. Required: >=3.1.0"
    print_info "Consider upgrading Flutter: 'flutter upgrade'"
fi

echo ""
print_info "Step 2: Running Flutter Doctor..."
flutter doctor

echo ""
print_info "Step 3: Checking animation assets..."

# Check if all animation files exist
ANIMATION_FILES=(
    "assets/animations/gig_success.json"
    "assets/animations/proposal_sent.json"
    "assets/animations/loading_spinner.json"
    "assets/animations/error_red.json"
    "assets/animations/empty_state.json"
    "assets/animations/chatbot_agent.json"
    "assets/animations/gig_loading_spinner.json"
    "assets/animations/no_gigs_empty.json"
    "assets/animations/booking_success_tick.json"
    "assets/animations/error_red_alert.json"
    "assets/animations/onboarding_handshake.json"
    "assets/animations/tap_ripple_micro.json"
    "assets/animations/gig_pack_manifest.json"
)

MISSING_FILES=0
for file in "${ANIMATION_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status "Found: $file"
    else
        print_error "Missing: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -eq 0 ]; then
    print_status "All animation assets found (${#ANIMATION_FILES[@]} files)"
else
    print_error "$MISSING_FILES animation files are missing"
    exit 1
fi

echo ""
print_info "Step 4: Installing dependencies..."
flutter pub get

echo ""
print_info "Step 5: Running code analysis..."
flutter analyze

echo ""
print_info "Step 6: Building for web..."
flutter build web --release

echo ""
print_status "Build completed successfully! 🎉"
print_info "Web build output is in: build/web/"
print_info "You can serve it locally with: 'flutter run -d chrome'"

echo ""
echo "🎯 Summary:"
echo "- Flutter/Dart versions: Compatible"
echo "- Animation assets: All present"
echo "- Dependencies: Resolved"
echo "- Code analysis: Passed"
echo "- Web build: Successful"
echo ""
print_status "Your environment is ready for development!"