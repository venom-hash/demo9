# NovaDrop - Supabase Integration Guide

## Overview
This guide explains how to integrate Supabase with your NovaDrop e-commerce application.

## Project Configuration
- **Supabase URL**: https://lkceazxyrtnxytvtjzas.supabase.co
- **Publishable Key**: sb_publishable_68WMnlkwJ0zF7f3fRo72fw_cAIQNd4G
- **Plan**: Free Tier

---

## Step 1: Set Up Supabase Database

### Option A: Using Supabase Dashboard (Recommended)
1. Go to https://supabase.com/dashboard
2. Select your project: `lkceazxyrtnxytvtjzas`
3. Go to **SQL Editor** in the left sidebar
4. Copy the contents of `SUPABASE_SETUP.sql`
5. Paste and run the SQL

### Option B: Create Tables Manually

#### Create profiles table
```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (linked to auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
```

#### Create products table
```sql
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC NOT NULL,
  original_price NUMERIC,
  images TEXT[] DEFAULT '{}',
  category TEXT,
  brand TEXT,
  stock INTEGER DEFAULT 0,
  rating NUMERIC DEFAULT 0,
  num_reviews INTEGER DEFAULT 0,
  featured BOOLEAN DEFAULT false,
  tags TEXT[] DEFAULT '{}',
  specifications JSONB DEFAULT '{}',
  shipping_fee NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Products are viewable by everyone" ON public.products FOR SELECT USING (true);
```

#### Create orders table
```sql
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  items JSONB NOT NULL DEFAULT '[]',
  shipping_address JSONB,
  payment_method TEXT,
  payment_status TEXT DEFAULT 'pending',
  order_status TEXT DEFAULT 'processing',
  subtotal NUMERIC DEFAULT 0,
  tax NUMERIC DEFAULT 0,
  shipping NUMERIC DEFAULT 0,
  discount NUMERIC DEFAULT 0,
  total NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);
```

#### Create wishlist table
```sql
CREATE TABLE public.wishlist (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own wishlist" ON public.wishlist FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can add to wishlist" ON public.wishlist FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can remove from wishlist" ON public.wishlist FOR DELETE USING (auth.uid() = user_id);
```

#### Create trigger for auto-creating profiles
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## Step 2: Seed Products (Optional)
If you want to use Supabase products instead of local data:
```sql
INSERT INTO public.products (name, description, price, original_price, images, category, brand, stock, rating, num_reviews, featured, tags, specifications) VALUES
('Luxe Round Anti-Blue Light Glass', 'Stay comfortable and focused during long screen hours.', 1599, 2500, ARRAY['https://example.com/image1.jpg'], 'Eye glasses', 'Anti Blue Ray', 45, 4.8, 234, true, ARRAY['reading-glasses'], '{"Size": "Free Size"}'::jsonb, 0);
```

---

## Step 3: Configure Environment Variables (Optional)

Create a `.env` file in the project root:
```env
VITE_SUPABASE_URL=https://lkceazxyrtnxytvtjzas.supabase.co
VITE_SUPABASE_ANON_KEY=sb_publishable_68WMnlkwJ0zF7f3fRo72fw_cAIQNd4G
```

---

## Step 4: Update Your Code

### Files Created:
1. `src/lib/supabase.ts` - Supabase client configuration
2. `src/services/productService.ts` - Product CRUD operations
3. `src/services/orderService.ts` - Order management
4. `src/services/wishlistService.ts` - Wishlist operations
5. `src/context/AuthContext.tsx` - Updated auth with Supabase

### Using Services in Components:

```tsx
// Example: Fetch products from Supabase
import { getProducts } from './services/productService';

const products = await getProducts({ category: 'Eye glasses' });
```

```tsx
// Example: Create an order
import { createOrder } from './services/orderService';

const order = await createOrder(
  userId,
  cartItems,
  shippingAddress,
  paymentMethod,
  subtotal,
  tax,
  shipping,
  discount,
  total
);
```

---

## Step 5: Test Your Integration

1. Run `npm run dev` to start the development server
2. Test user registration/login
3. Test viewing products
4. Test order creation
5. Test wishlist functionality

---

## Supabase Features Used:

- ✅ **Authentication**: Email/password signup & login
- ✅ **Database**: PostgreSQL with RLS policies
- ✅ **Realtime**: Optional - for live order updates

---

## Troubleshooting

### Common Issues:

1. **Auth not working**: Make sure RLS policies are set up correctly
2. **Products not showing**: Ensure products table has data
3. **CORS errors**: Add your domain to Supabase allowed origins

### Enable Debug Logging:
```typescript
const supabase = createClient(url, key, {
  global: {
    headers: {
      'x-client-info': '.Supabase-JS/2.x.x'
    }
  },
  auth: {
    debug: true
  }
});
```

---

## Next Steps (Optional Enhancements):

1. Add **Realtime Subscriptions** for order status updates
2. Implement **Row Level Security** policies for admin features
3. Add **Storage** bucket for product images
4. Enable **Email Templates** in Supabase dashboard
5. Set up **Webhook** for order notifications

---

## Files Structure After Integration:

```
src/
├── lib/
│   └── supabase.ts          # Supabase client setup
├── services/
│   ├── productService.ts     # Product CRUD
│   ├── orderService.ts      # Order management
│   └── wishlistService.ts   # Wishlist operations
├── context/
│   └── AuthContext.tsx      # Auth with Supabase
├── pages/
│   ├── HomePage.tsx         # Uses productService
│   ├── ProductsPage.tsx    # Uses productService
│   └── ...                 # Other pages
└── App.tsx                 # Uses AuthContext
```

---

## Supabase Dashboard Resources:

- **Project URL**: https://supabase.com/dashboard/project/lkceazxyrtnxytvtjzas
- **Documentation**: https://supabase.com/docs
- **API Reference**: https://supabase.com/docs/reference

---

## Need Help?

If you encounter any issues:
1. Check Supabase logs in Dashboard → Logs
2. Verify RLS policies are correct
3. Check browser console for errors
4. Verify your API keys are correct

Good luck with your Supabase integration! 🎉
