# 🛒 Kisaan Mitra Marketplace - Buyer Platform Specifications

> This document contains all the specifications, hardcoded data, and design guidelines for creating the **Buyer-side Web Application** that will integrate with the Kisaan Mitra farmer's app marketplace.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Data Models](#data-models)
3. [Mock/Hardcoded Data](#mockhardcoded-data)
4. [Feature Specifications](#feature-specifications)
5. [Image Assets](#image-assets)
6. [Farmer App Styling Reference](#farmer-app-styling-reference)
7. [Suggested Buyer Platform Styling](#suggested-buyer-platform-styling)
8. [API Endpoints (Proposed)](#api-endpoints-proposed)

---

## Overview

The marketplace feature in Kisaan Mitra allows farmers to:
- List their crops for sale
- View all available crop listings
- Track their own listings
- Save interesting listings for reference
- View government market prices
- Get AI-suggested pricing based on crop type and location

The **Buyer Platform** will be a web application that allows buyers to:
- Browse available crop listings from farmers
- Filter and search for specific crops
- View detailed listing information
- Contact sellers
- Track market prices
- Place orders (future enhancement)

---

## Data Models

### CropListingModel

```typescript
interface CropListingModel {
  id: string;                    // Unique identifier (UUID)
  userId: string;                // Seller's user ID
  userName: string;              // Seller's display name
  cropType: string;              // Type of crop (e.g., "Wheat", "Rice", "Cotton")
  quantity: number;              // Available quantity
  quantityUnit: string;          // Unit: "kg" | "quintal" | "ton"
  price: number;                 // Price per unit (in ₹)
  location: string;              // Location (e.g., "Punjab, India")
  harvestDate: Date;             // When the crop was harvested
  listedDate: Date;              // When the listing was created
  description: string;           // Detailed description
  images: string[];              // Array of image paths/URLs
  isAvailable: boolean;          // Availability status
}
```

### MarketPriceModel

```typescript
interface MarketPriceModel {
  cropType: string;              // Crop name
  location: string;              // Market location
  minPrice: number;              // Minimum price per kg (₹)
  maxPrice: number;              // Maximum price per kg (₹)
  avgPrice: number;              // Average price per kg (₹)
  updatedAt: Date;               // Last update timestamp
}
```

---

## Mock/Hardcoded Data

### Sample Crop Listings

| ID | User ID | User Name | Crop Type | Quantity | Unit | Price (₹) | Location | Harvest Date | Description | Image |
|----|---------|-----------|-----------|----------|------|-----------|----------|--------------|-------------|-------|
| 1 | user1 | Farmer Singh | Wheat | 500 | kg | 22.50 | Punjab, India | 15 days ago | High-quality wheat harvested from organic farm. | wheat.jpg |
| 2 | user2 | Test Farmer | Rice | 300 | kg | 35.00 | Haryana, India | 20 days ago | Premium basmati rice, freshly harvested. | rice.jpg |
| 3 | user3 | Anita Patel | Cotton | 200 | kg | 65.00 | Gujarat, India | 30 days ago | High-quality cotton, ready for processing. | cotton.jpg |

### Market Prices (Government/Official)

| Crop | Price/kg (₹) | Trend | Change (%) |
|------|--------------|-------|------------|
| Wheat | 22.50 | up | +2.5% |
| Rice | 35.00 | stable | 0.0% |
| Cotton | 65.00 | down | -1.2% |
| Sugarcane | 3.50 | up | +0.5% |
| Maize | 18.75 | up | +1.8% |
| Soybean | 42.30 | down | -0.7% |
| Potato | 15.20 | stable | +0.1% |
| Tomato | 25.80 | up | +3.2% |
| Onion | 28.50 | down | -2.1% |
| Pulses | 55.25 | stable | +0.3% |

### Market Price Data by Location

| Crop | Location | Min Price (₹/kg) | Max Price (₹/kg) | Avg Price (₹/kg) |
|------|----------|------------------|------------------|------------------|
| Wheat | Punjab, India | 20.00 | 25.00 | 22.50 |
| Wheat | Haryana, India | 19.00 | 24.00 | 21.50 |
| Rice | Punjab, India | 30.00 | 40.00 | 35.00 |
| Cotton | Gujarat, India | 60.00 | 70.00 | 65.00 |

### Default Fallback Prices (when no location match)

| Crop | Default Price (₹/kg) |
|------|----------------------|
| Rice | 25.00 |
| Wheat | 20.00 |
| Corn | 18.00 |
| Cotton | 60.00 |
| Sugarcane | 3.00 |
| Potato | 15.00 |
| Tomato | 25.00 |

### Quantity Units

| Value | Display Text |
|-------|--------------|
| kg | Kilograms (kg) |
| quintal | Quintal |
| ton | Ton |

### Sample Locations Used

- Punjab, India (default)
- Haryana, India
- Gujarat, India

---

## Feature Specifications

### 1. Marketplace Home / Browse Listings

**Farmer App Tab Structure:**
- Tab 1: "All Listings" - Shows all available crop listings
- Tab 2: "My Listings" - Shows user's own listings (seller-side)

**Buyer Platform Equivalent:**
- Single view showing all available listings
- Grid or list view toggle
- Featured/promoted listings section (optional)

**Search Functionality:**
- Search by: crop type, location, description
- Real-time filtering as user types

**Listing Card Display:**
Each listing card shows:
- Crop image (150px height in mobile)
- Price badge: "Above Market" or "Below Market" (calculated as 95% of listing price = market average)
- Crop type (bold, 20px font)
- Price: `₹{price}/{unit}` format (18px, green color)
- Market average comparison (12px, grey, italic)
- Quantity: `{quantity} {unit}` with scale icon
- Location: with location_on icon
- Harvest date: "Harvested: MMM d, yyyy" format with calendar icon
- Description (max 2 lines, ellipsis overflow)
- Seller info: Avatar (first letter of name), Name
- "View Details" button

**Price Comparison Logic:**
```javascript
const marketAverage = listing.price * 0.95;
const priceDifference = listing.price - marketAverage;
const isAboveMarket = priceDifference > 0;
// Badge color: Blue for above market, Green for below market
```

### 2. Market Prices Section

**Collapsible Panel showing:**
- Quick view: Wheat ₹22.50/kg, Rice ₹35.00/kg, Cotton ₹65.00/kg
- "Tap to view all prices" link

**Full Market Prices Screen:**
- Title: "Government Market Prices"
- Subtitle: "Official Crop Prices"
- Source: "Agricultural Price Commission"
- Last updated: Current date in "MMM d, yyyy" format

**Each crop row shows:**
- Crop name (bold)
- "Per kilogram" subtitle
- Price in ₹ format (green, bold)
- Trend icon and percentage:
  - Up: trending_up icon (green)
  - Down: trending_down icon (red)
  - Stable: trending_flat icon (blue)

### 3. Listing Detail View

**Sections:**

1. **Crop Image Header** (200px height, full width)

2. **Price & Quantity Section**
   - Price: Large green text (24px, bold)
   - "per {unit}" text
   - "{quantity} {unit} available"

3. **Crop Details Section**
   - Crop Type (with grass icon)
   - Location (with location_on icon)
   - Harvest Date (with calendar_today icon) - Format: "MMM d, yyyy"
   - Listed Date (with access_time icon) - Format: "MMM d, yyyy"

4. **Description Section**
   - Full description text

5. **Seller Information Section**
   - Avatar: Circle with first letter of name (green background)
   - Seller name (bold)
   - Seller location

6. **Market Price Comparison Box** (green background)
   - Your Price: {listing price}
   - Market Average: {calculated 95% of price}
   - Price Difference: +/- {difference}
   - Color: Blue if above, Orange if below

7. **Price Recommendation Text**
   - Dynamic text based on price comparison

8. **Action Button**
   - Farmer app: "Save Listing" button
   - Buyer platform: "Contact Seller" or "Request Quote" button

### 4. Saved Listings (Farmer App Feature)

**Buyer Platform Equivalent:**
- "Favorites" or "Watchlist" feature
- Store in localStorage or user account
- Similar card display as browse view
- Remove from saved functionality

---

## Image Assets

### Required Images

| Filename | Location | Size (bytes) | Usage |
|----------|----------|--------------|-------|
| wheat.jpg | assets/images/ | 90,765 | Default for wheat listings |
| rice.jpg | assets/images/ | 114,403 | Default for rice listings |
| cotton.jpg | assets/images/ | 15,747 | Default for cotton listings |

### Image Mapping Logic

```javascript
function getImagePath(cropType) {
  switch (cropType.toLowerCase()) {
    case 'wheat':
      return 'assets/images/wheat.jpg';
    case 'rice':
      return 'assets/images/rice.jpg';
    case 'cotton':
      return 'assets/images/cotton.jpg';
    default:
      return ''; // Show placeholder icon
  }
}
```

### Placeholder for Unknown Crops
- Display: Generic image icon (Icons.image)
- Size: 50px
- Color: Grey

---

## Farmer App Styling Reference

### Color Palette (Farmer App - DO NOT USE, reference only)

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary Color | #4CAF50 | App bar, buttons, accents (Green) |
| Accent Color | #8BC34A | Secondary highlights (Light Green) |
| Text Color | #212121 | Primary text |
| Secondary Text | #757575 | Subtitles, hints |
| Background | #F5F5F5 | Page backgrounds |
| Error Color | #D32F2F | Error states |

### Typography (Farmer App)
- Font Family: **Poppins** (Google Fonts)
- Material 3 Design System

### Component Styling (Farmer App)

**App Bar:**
- Background: Primary green (#4CAF50)
- Foreground: White
- Elevation: 0

**Cards:**
- Elevation: 2
- Border Radius: 12px
- Margin bottom: 16px

**Buttons:**
- Border Radius: 8px
- Padding: 12px vertical, 16px horizontal

**Input Fields:**
- Border Radius: 8px
- Focus border: 2px primary color


## Suggested Buyer Platform Styling

### Recommended Color Palette (BUYER - Professional/Business Theme)

| Color Name | Hex Code | Usage | Notes |
|------------|----------|-------|-------|
| Primary | #1E3A5F | Headers, primary buttons | Deep Navy Blue |
| Secondary | #3D5A80 | Secondary elements | Medium Blue |
| Accent | #EE6C4D | CTAs, highlights | Coral Orange |
| Success | #4ECDC4 | Success states, "good deals" | Teal |
| Warning | #FFD166 | Warnings, price alerts | Warm Yellow |
| Text Primary | #1A1A2E | Main text | Dark Blue-Black |
| Text Secondary | #6B7280 | Secondary text | Cool Grey |
| Background | #F8FAFC | Page background | Cool White |
| Surface | #FFFFFF | Cards, modals | Pure White |
| Border | #E5E7EB | Dividers, borders | Light Grey |

### Alternative Color Schemes

**Option B - Modern Corporate:**
| Color | Hex |
|-------|-----|
| Primary | #2563EB | (Blue)
| Secondary | #7C3AED | (Purple)
| Accent | #F59E0B | (Amber)

**Option C - Earth Tones (Agricultural feel but professional):**
| Color | Hex |
|-------|-----|
| Primary | #78350F | (Brown)
| Secondary | #B45309 | (Orange-Brown)
| Accent | #059669 | (Emerald)

### Typography Recommendations

**Web Fonts:**
- Headings: **Inter** or **Outfit** (Google Fonts)
- Body: **Inter** or **Source Sans Pro**
- Alternative: **Nunito Sans** for a softer feel

**Font Sizes (Desktop):**
| Element | Size | Weight |
|---------|------|--------|
| H1 | 36px | 700 |
| H2 | 28px | 600 |
| H3 | 22px | 600 |
| Body | 16px | 400 |
| Caption | 14px | 400 |
| Small | 12px | 400 |

### Component Guidelines

**Cards:**
```css
.listing-card {
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
  transition: box-shadow 0.2s, transform 0.2s;
}

.listing-card:hover {
  box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1), 0 4px 6px rgba(0, 0, 0, 0.05);
  transform: translateY(-2px);
}
```

**Buttons:**
```css
.btn-primary {
  background: linear-gradient(135deg, #1E3A5F 0%, #3D5A80 100%);
  color: white;
  border-radius: 8px;
  padding: 12px 24px;
  font-weight: 600;
  transition: all 0.2s;
}

.btn-primary:hover {
  box-shadow: 0 4px 12px rgba(30, 58, 95, 0.3);
}

.btn-accent {
  background: #EE6C4D;
  color: white;
}
```

**Price Display:**
```css
.price {
  font-size: 24px;
  font-weight: 700;
  color: #059669; /* Emerald green for prices */
}

.price-badge-above-market {
  background: #DBEAFE;
  color: #1E40AF;
  border: 1px solid #93C5FD;
}

.price-badge-below-market {
  background: #D1FAE5;
  color: #065F46;
  border: 1px solid #6EE7B7;
}
```

### Responsive Breakpoints

```css
/* Mobile First Approach */
@media (min-width: 640px) { /* sm */ }
@media (min-width: 768px) { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
```

### Layout Suggestions

**Desktop Layout:**
- Sidebar navigation
- 3-4 column grid for listings
- Sticky filters panel
- Quick view market prices in header

**Tablet Layout:**
- 2-3 column grid
- Collapsible filters

**Mobile Layout:**
- Single column
- Bottom navigation or hamburger menu
- Floating "Contact" button

---

## API Endpoints (Proposed)

For the buyer platform to work with the farmer app, you'll need a backend. Here are suggested endpoints:

### Listings

```
GET    /api/listings                    # Get all available listings
GET    /api/listings/:id                # Get single listing details
GET    /api/listings?crop={type}        # Filter by crop type
GET    /api/listings?location={loc}     # Filter by location
GET    /api/listings?search={query}     # Search listings
```

### Market Prices

```
GET    /api/market-prices               # Get all market prices
GET    /api/market-prices/:crop         # Get prices for specific crop
GET    /api/suggested-price?crop={type}&location={loc}  # Get AI suggested price
```

### User/Seller Info

```
GET    /api/sellers/:id                 # Get seller profile
POST   /api/contact/:listingId          # Contact seller about listing
```

### Buyer Actions

```
POST   /api/favorites                   # Add to favorites
DELETE /api/favorites/:listingId        # Remove from favorites
GET    /api/favorites                   # Get all favorites
POST   /api/inquiries                   # Submit purchase inquiry
```

---

## Currency Formatting

```javascript
const currencyFormat = new Intl.NumberFormat('en-IN', {
  style: 'currency',
  currency: 'INR',
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

// Usage: currencyFormat.format(22.50) => "₹22.50"
```

---

## Date Formatting

```javascript
// Format: "MMM d, yyyy" (e.g., "Jan 15, 2026")
const dateFormat = new Intl.DateTimeFormat('en-US', {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
});
```

---

## Icons Used (Material Icons)

| Icon Name | Usage |
|-----------|-------|
| search | Search bar |
| bookmark | Save/favorite listing |
| bookmark_border | Unsaved state |
| add | Add listing FAB |
| grass | Crop type |
| scale | Quantity |
| location_on | Location |
| calendar_today | Harvest date |
| access_time | Listed date |
| currency_rupee | Price fields |
| trending_up | Price increase |
| trending_down | Price decrease |
| trending_flat | Price stable |
| arrow_upward | Above market badge |
| arrow_downward | Below market badge |
| visibility_outlined | View details |
| edit | Edit listing |
| delete | Delete action |
| person | User profile |
| image | Image placeholder |

---

## Notes for Buyer Platform Development

1. **Authentication**: Implement separate buyer authentication system
2. **Real-time Updates**: Consider WebSocket for live listing updates
3. **Notifications**: Email/push notifications for watchlist price changes
4. **Payment Gateway**: Future integration for direct purchases
5. **Reviews/Ratings**: Add buyer reviews for sellers
6. **Order Tracking**: Track purchase inquiries and orders
7. **Analytics Dashboard**: Show market trends, popular crops, etc.

---

*Document generated for Kisaan Mitra Hackathon Project*
*Last Updated: January 31, 2026*
