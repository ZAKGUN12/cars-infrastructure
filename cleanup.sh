#!/bin/bash

# Vehicle Guesser - Infrastructure Cleanup Script
# This script archives unused infrastructure files for better organization

set -e

echo "🧹 Vehicle Guesser Infrastructure Cleanup"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to infrastructure directory
cd "$(dirname "$0")"

# Create archive directory
echo "📁 Creating archive directory..."
mkdir -p archive

# Archive old Cognito templates
echo "📦 Archiving old Cognito templates..."
if [ -f "cognito-secrets.yml" ]; then
    mv cognito-secrets.yml archive/
    echo "  ✅ Moved cognito-secrets.yml to archive/"
fi

if [ -f "cognito-secrets-secure.yml" ]; then
    mv cognito-secrets-secure.yml archive/
    echo "  ✅ Moved cognito-secrets-secure.yml to archive/"
fi

# Create README in archive
echo "📝 Creating archive README..."
cat > archive/README.md << 'EOF'
# Archived Infrastructure Files

This directory contains old or alternative infrastructure templates that are not actively deployed.

## Files

### `cognito-secrets.yml`
- **Status:** Superseded by `templates/cognito-simple.yml`
- **Reason:** Used complex custom Lambda for secret retrieval
- **Date Archived:** January 15, 2025

### `cognito-secrets-secure.yml`
- **Status:** Alternative approach not used in production
- **Reason:** Different secret management strategy
- **Date Archived:** January 15, 2025

## Why Archive?

These files are kept for historical reference and potential future use, but are not part of the active deployment pipeline.

## Active Templates

See `templates/` directory for currently deployed infrastructure:
- `templates/cognito-simple.yml` - Active Cognito configuration
- `templates/backend-updated.yml` - Active backend configuration
EOF

echo ""
echo "${GREEN}✅ Cleanup complete!${NC}"
echo ""
echo "📋 Summary:"
echo "  - Created archive/ directory"
echo "  - Moved 2 old Cognito templates to archive/"
echo "  - Created archive/README.md"
echo ""
echo "${YELLOW}Note:${NC} The following files are kept for manual deployment:"
echo "  - frontend-hosting.yml"
echo "  - monitoring.yml"
echo "  - real-time-matchmaking.yml"
echo "  - deploy-matchmaking.sh"
echo ""
echo "Run 'git status' to review changes before committing."
