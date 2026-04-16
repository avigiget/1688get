#!/bin/bash
# 1688 Product Downloader Helper Script
# Usage: ./download-1688.sh <product_url> [output_dir]

set -e

PRODUCT_URL="$1"
OUTPUT_DIR="${2:-~/products}"

if [ -z "$PRODUCT_URL" ]; then
    echo "Usage: $0 <product_url> [output_dir]"
    echo "Example: $0 https://detail.1688.com/offer/694988388954.html"
    exit 1
fi

# Extract product ID from URL
PRODUCT_ID=$(echo "$PRODUCT_URL" | grep -oP 'offer/\K[0-9]+' || echo "")

if [ -z "$PRODUCT_ID" ]; then
    echo "Error: Could not extract product ID from URL"
    exit 1
fi

echo "Product ID: $PRODUCT_ID"
echo "Output Directory: $OUTPUT_DIR/product_$PRODUCT_ID"

# Create directory
mkdir -p "$OUTPUT_DIR/product_$PRODUCT_ID"
cd "$OUTPUT_DIR/product_$PRODUCT_ID"

echo "Directory created. Ready for download."
echo ""
echo "Next steps:"
echo "1. Navigate to product page with Playwright"
echo "2. Download main images"
echo "3. Scroll and capture detail images"
echo "4. Extract product info"
echo ""
echo "Product folder: $OUTPUT_DIR/product_$PRODUCT_ID"
