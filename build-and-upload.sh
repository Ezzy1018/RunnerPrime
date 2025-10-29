#!/bin/bash

# RunnerPrime - Build and Upload Script
# This script automates the process of building and uploading to App Store Connect

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/Users/ankity/Documents/Projects/RunnerPrime/RunnerPrime"
PROJECT_NAME="RunnerPrime"
SCHEME="RunnerPrime"
ARCHIVE_PATH="$PROJECT_DIR/build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="$PROJECT_DIR/build/AppStore"
EXPORT_OPTIONS="$PROJECT_DIR/ExportOptions.plist"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}     RunnerPrime - Build & Upload Script       ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found. Make sure Xcode is installed.${NC}"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Project directory not found at $PROJECT_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"
echo ""

# Step 2: Clean previous builds
echo -e "${YELLOW}Step 2: Cleaning previous builds...${NC}"
cd "$PROJECT_DIR"
rm -rf build
xcodebuild clean -project ${PROJECT_NAME}.xcodeproj -scheme $SCHEME > /dev/null 2>&1
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Step 3: Build archive
echo -e "${YELLOW}Step 3: Building archive (this may take a few minutes)...${NC}"
xcodebuild archive \
  -project ${PROJECT_NAME}.xcodeproj \
  -scheme $SCHEME \
  -archivePath "$ARCHIVE_PATH" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=72D4Q3VJSY \
  | xcpretty || true

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}Error: Archive creation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Archive created successfully${NC}"
echo ""

# Step 4: Export for App Store
echo -e "${YELLOW}Step 4: Exporting for App Store...${NC}"

if [ ! -f "$EXPORT_OPTIONS" ]; then
    echo -e "${RED}Error: ExportOptions.plist not found${NC}"
    exit 1
fi

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  | xcpretty || true

if [ ! -d "$EXPORT_PATH" ]; then
    echo -e "${RED}Error: Export failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Export complete${NC}"
echo ""

# Step 5: Show results
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${YELLOW}Archive location:${NC} $ARCHIVE_PATH"
echo -e "${YELLOW}IPA location:${NC} $EXPORT_PATH/${PROJECT_NAME}.ipa"
echo ""

# Step 6: Upload to App Store Connect (Optional)
echo -e "${YELLOW}Step 5: Upload to App Store Connect?${NC}"
echo -e "You can upload using:"
echo -e "  1. Xcode Organizer (Recommended)"
echo -e "  2. Command line using xcrun altool"
echo ""
echo -e "To upload via command line, run:"
echo -e "${BLUE}xcrun altool --upload-app --type ios --file \"$EXPORT_PATH/${PROJECT_NAME}.ipa\" --username YOUR_APPLE_ID --password YOUR_APP_SPECIFIC_PASSWORD${NC}"
echo ""

# Step 7: Open Organizer
read -p "Open Xcode Organizer now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$ARCHIVE_PATH"
    echo -e "${GREEN}Opening Xcode Organizer...${NC}"
    echo -e "In Organizer:"
    echo -e "  1. Select your archive"
    echo -e "  2. Click 'Distribute App'"
    echo -e "  3. Choose 'App Store Connect'"
    echo -e "  4. Click 'Upload'"
else
    echo -e "${YELLOW}You can open Organizer manually from Xcode → Window → Organizer${NC}"
fi

echo ""
echo -e "${GREEN}Done! 🚀${NC}"
echo -e "${BLUE}Built with love in India 🇮🇳${NC}"

