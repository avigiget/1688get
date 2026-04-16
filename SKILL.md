---
name: 1688get
description: Download product information and images from 1688.com product pages. Use when the user wants to scrape/download product data from 1688 including main images, detail images, product attributes, and specifications. Triggers on phrases like "download from 1688", "get 1688 product", "scrape 1688", "1688 product download", or when given 1688.com product URLs.
---

# 1688get - 1688 Product Downloader

Download complete product information from 1688.com product pages.

## What This Skill Does

This skill automates the download of:
- **Main product images** (img1.jpg - img5.jpg)
- **Detail page images** (detail_01.jpg - detail_NN.jpg)
- **Product information** (title, price, specs, attributes)
- **Packaging information** (weight, dimensions)

## Prerequisites

- Chrome browser running with CDP (Chrome DevTools Protocol) on port 9222
- Playwright MCP configured in `~/.openclaw/config/mcporter.json`
- `curl` available for image downloads

## Workflow

### 1. Navigate to Product Page

Use Playwright to navigate to the 1688 product URL:
```bash
mcporter --config ~/.openclaw/config/mcporter.json call playwright.browser_navigate url="https://detail.1688.com/offer/[PRODUCT_ID].html"
```

### 2. Create Product Directory

```bash
mkdir -p ~/products/product_[PRODUCT_ID]
cd ~/products/product_[PRODUCT_ID]
```

### 3. Download Main Images

Extract main image URLs and download:
```bash
# Get image URLs via Playwright
mcporter --config ~/.openclaw/config/mcporter.json call playwright.browser_evaluate function="() => { const imgs = Array.from(document.querySelectorAll('img')).filter(img => img.src?.includes('alicdn.com') && img.src?.includes('ibank') && img.naturalWidth > 300).map(img => img.src.replace(/\?.*$/, '').replace('_.webp', '')); return [...new Set(imgs)].slice(0, 10).join('\\n'); }"

# Download each image
curl -sL -o img1.jpg "[IMAGE_URL_1]"
curl -sL -o img2.jpg "[IMAGE_URL_2]"
# ... etc
```

### 4. Download Detail Images

Scroll page to load detail images, then capture network requests:
```bash
# Scroll to trigger lazy loading
mcporter --config ~/.openclaw/config/mcporter.json call playwright.browser_evaluate function="() => { for(let i=0; i<8; i++) { setTimeout(()=>window.scrollBy(0,600), i*800); } return 'scrolling'; }"

# Wait and capture network requests
sleep 8
mcporter --config ~/.openclaw/config/mcporter.json call playwright.browser_network_requests static=true requestBody=false requestHeaders=false filter=".*ibank.*\.jpg"
```

Extract detail image URLs from network requests (look for `__r__` timestamp parameters) and download to `detail_images/` folder.

### 5. Extract Product Info

Get product title, price, specs:
```bash
mcporter --config ~/.openclaw/config/mcporter.json call playwright.browser_evaluate function="() => { const title = document.title?.replace(' - 阿里巴巴', '') || ''; const offerTitle = document.querySelector('.offer-title')?.innerText?.trim() || ''; return JSON.stringify({pageTitle: title, offerTitle}); }"
```

### 6. Create info.txt

Create `info.txt` with product details:
```
标题：[Product Title]
价格：[Price]
材质：[Materials]
尺码：[Sizes]
货号：[SKU]
1688链接：[URL]
销量：[Sales]
店铺：[Shop Name]

【商品属性】
[Attributes]

【包装信息】
件重尺：[Weight/Dimensions]

【下载信息】
下载时间: [Date]
主图: img1.jpg - img5.jpg (5张)
详情图: detail_01.jpg - detail_NN.jpg (NN张)
```

### 7. Generate Shopify CSV (English Version)

After downloading product data, generate a Shopify-compatible CSV file for bulk import:

**CSV Structure:**
- Handle: URL-friendly product identifier
- Title: English product title
- Body (HTML): Full product description with size chart and attributes
- Vendor: 佳佳利鞋业
- Type: Flat Shoes
- Tags: Product category tags
- Variants: Size × Color combinations with inventory tracking

**Example CSV Row:**
```
summer-hollow-slippers,Summer Hollow Closed-toe Slippers - Cowhide Flat Mom Shoes,"<h3>Product Details</h3>...",佳佳利鞋业,Flat Shoes,"Slippers, Mom Shoes",TRUE,Size,US 5,Color,Bean Paste,SLIPPER713-US5-BNP,500,shopify,300,deny,manual,34.00,44.00,TRUE,TRUE,,,,,,Summer Hollow Closed-toe Slippers | Quinn Shop,High-quality summer slippers...,Women,Adult,713806855449-US5-BNP,,,new,FALSE,,,,,,,kg,,20.00,active
```

**Key Fields:**
- `Handle`: Unique product identifier (lowercase, hyphen-separated)
- `Title`: English product title (e.g., "Summer Hollow Closed-toe Slippers")
- `Body (HTML)`: Complete product description with:
  - Product Details section
  - Size Chart (US sizes with CN equivalents)
  - Product Attributes table
  - Packaging Information
- `Option1 Name`: Size
- `Option1 Value`: US 5, US 6, etc.
- `Option2 Name`: Color
- `Option2 Value`: English color names
- `Variant SKU`: Format `[PRODUCT]-[SIZE]-[COLOR-CODE]`
- `Variant Inventory Qty`: 300 (default stock)
- `Variant Price`: Suggested retail price in USD
- `Variant Compare At Price`: Original price (for showing discount)
- `SEO Title`: Optimized title for search engines
- `SEO Description`: Meta description for search results

**Color Mapping (Chinese → English):**
- 红色/豆沙 → Red / Bean Paste
- 黑色 → Black
- 蓝色 → Blue
- 米色/杏色 → Beige / Apricot
- 灰色 → Gray
- 白色 → White
- 粉色 → Pink
- 黄色 → Yellow

**Size Conversion (CN → US):**
- 35 → US 5
- 36 → US 6
- 37 → US 6.5
- 38 → US 7.5
- 39 → US 8
- 40 → US 9
- 41 → US 10
- 42 → US 11
- 43 → US 12
- 44 → US 13

**Template Script:**
Create `~/products/product_[ID]/shopify_import.csv` with:
1. Header row with all Shopify product fields
2. First data row with complete product information
3. Subsequent rows for each variant (Size × Color combination)
4. All text in English except vendor name

**Example Workflow:**
```bash
# After downloading product data
cd ~/products/product_[PRODUCT_ID]

# Create CSV with Python script or manual entry
# Include all variants: [Size Options] × [Color Options]
# Each variant gets 300 inventory
```

**File Structure After CSV Generation:**
```
product_[ID]/
├── img1.jpg - img5.jpg          # Main product images
├── detail_images/               # Detail page images
│   ├── detail_01.jpg
│   └── ...
├── info.txt                     # Product information (Chinese)
└── shopify_import.csv           # Shopify import file (English)
```

## File Structure

After download, each product folder contains:
```
product_[ID]/
├── img1.jpg - img5.jpg          # Main product images
├── detail_images/               # Detail page images
│   ├── detail_01.jpg
│   ├── detail_02.jpg
│   └── ...
├── info.txt                     # Product information (Chinese)
└── shopify_import.csv           # Shopify import file (English)
```

**shopify_import.csv** contains:
- Complete product data in English
- All size/color variants with 300 inventory each
- SEO-optimized titles and descriptions
- Ready for direct import to Shopify


## Tips

- **Login required**: Some detail images require login to view. Ensure browser is logged into 1688.
- **Lazy loading**: Detail images load on scroll. Must scroll page before capturing network requests.
- **Image URLs**: Look for URLs with `?__r__=` timestamp parameters for full-resolution detail images.
- **Rate limiting**: Add delays between requests to avoid being blocked.

## Example Usage

User: "Download product info from https://detail.1688.com/offer/694988388954.html"

Response: Navigate to URL, create folder `product_694988988954`, download 5 main images, scroll and capture 32 detail images, extract product info, create info.txt, and generate `shopify_import.csv` with English product data and all variants.

**Complete Workflow:**
1. Navigate to 1688 product page
2. Create product directory: `~/products/product_694988388954/`
3. Download 5 main images (img1.jpg - img5.jpg)
4. Scroll page and capture detail images
5. Download detail images to `detail_images/` folder
6. Extract product info and create `info.txt` (Chinese)
7. Generate `shopify_import.csv` (English) with:
   - Product title and description in English
   - Size chart (US sizes with CN equivalents)
   - All product attributes
   - Size × Color variants (e.g., 6 sizes × 5 colors = 30 variants)
   - Each variant with 300 inventory
   - SEO-optimized metadata
