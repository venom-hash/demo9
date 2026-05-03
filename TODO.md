# Todo List - NovaDrop Performance Audit Fixes

## Completed Tasks:

### 1. index.html - SEO & Meta Tags
- [x] Removed rrweb tracking scripts (~50KB blocking scripts)
- [x] Added proper OG tags for WhatsApp/Facebook sharing
- [x] Added Twitter card meta tags
- [x] Added canonical URL
- [x] Added preconnect hints for external assets

### 2. Currency Change: QAR (ر.ق) → ර (LKR)
- [x] Updated ProductDetailPage.tsx - WhatsApp message price
- [x] Updated ProductDetailPage.tsx - price display
- [x] Updated HomePage.tsx - Free shipping threshold

### 3. HomePage.tsx - Hero Image
- [x] Optimized hero image dimensions for mobile-first

## Pending Tasks:

### ProductCard.tsx
- [ ] Add lazy loading to images
- [ ] Add width/height attributes to prevent CLS

### productService.ts
- [ ] Add 5-minute cache for Supabase queries

### All pages - Currency Display
- [ ] CartPage.tsx - Convert prices to ර
- [ ] CheckoutPage.tsx - Convert prices to ර

### Performance Optimizations
- [ ] Reduce Framer Motion animations on mobile
- [ ] Add skeleton loading states
- [ ] Optimize hero image (reduce size for 4G)

### Qatar-Specific Conversions
- [ ] Add Cash on Delivery mention
- [ ] Add "Same-day Doha delivery" badge
- [ ] Update country selector in checkout to include Qatar

## Files Modified:
- index.html
- src/pages/HomePage.tsx
- src/pages/ProductDetailPage.tsx
- PERFORMANCE_AUDIT_REPORT.md (reference document)
