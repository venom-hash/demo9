-- ============================================
-- NovaDrop - Supabase Database Setup SQL
-- Run this in your Supabase SQL Editor
-- ============================================

-- ============================================
-- STEP 1: Create users profile table
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create public profiles table (links to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read profiles
CREATE POLICY "Public profiles are viewable by everyone" 
  ON public.profiles FOR SELECT 
  USING (true);

-- Create policy for users to update their own profile
CREATE POLICY "Users can update own profile" 
  ON public.profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================
-- STEP 2: Create products table
-- ============================================

CREATE TABLE IF NOT EXISTS public.products (
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
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Products are viewable by everyone
CREATE POLICY "Products are viewable by everyone"
  ON public.products FOR SELECT USING (true);

-- Only admins can modify products
CREATE POLICY "Admins can insert products"
  ON public.products FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update products"
  ON public.products FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can delete products"
  ON public.products FOR DELETE USING (auth.role() = 'authenticated');


-- ============================================
-- STEP 3: Create orders table
-- ============================================

CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  items JSONB NOT NULL DEFAULT '[]',
  shipping_address JSONB,
  payment_method TEXT,
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed')),
  order_status TEXT DEFAULT 'processing' CHECK (order_status IN ('processing', 'shipped', 'delivered', 'cancelled')),
  subtotal NUMERIC DEFAULT 0,
  tax NUMERIC DEFAULT 0,
  shipping NUMERIC DEFAULT 0,
  discount NUMERIC DEFAULT 0,
  total NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Users can view their own orders
CREATE POLICY "Users can view their own orders"
  ON public.orders FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own orders
CREATE POLICY "Users can create their own orders"
  ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own orders
CREATE POLICY "Users can update their own orders"
  ON public.orders FOR UPDATE USING (auth.uid() = user_id);


-- ============================================
-- STEP 4: Create wishlist table
-- ============================================

CREATE TABLE IF NOT EXISTS public.wishlist (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;

-- Users can view their own wishlist
CREATE POLICY "Users can view their own wishlist"
  ON public.wishlist FOR SELECT USING (auth.uid() = user_id);

-- Users can add to their own wishlist
CREATE POLICY "Users can add to wishlist"
  ON public.wishlist FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can remove from their own wishlist
CREATE POLICY "Users can remove from wishlist"
  ON public.wishlist FOR DELETE USING (auth.uid() = user_id);


-- ============================================
-- STEP 5: Seed initial products
-- ============================================

INSERT INTO public.products (name, description, price, original_price, images, category, brand, stock, rating, num_reviews, featured, tags, specifications, shipping_fee) VALUES
('Luxe Round Anti-Blue Light Glass', 'Stay comfortable and focused during long screen hours with glasses built to minimize blue light exposure.', 1599, 2500, ARRAY['https://www.image2url.com/r2/default/images/1777469147641-2fb24de9-cdcd-4dc2-b3b1-27c2e4e91f04.png'], 'Eye glasses', 'Anti Blue Ray', 45, 4.8, 234, true, ARRAY['reading-glasses', 'eyewear', 'anti-scratch', 'lightweight'], '{"Size": "Free Size", "Lenses": "Anti Blue Ray", "Quality": "Premium Quality", "Users": "Unisex"}'::jsonb, 0),
('Urban Retro Anti-Blue Light Glass', 'Stay comfortable and focused during long screen hours.', 1899, 2500, ARRAY['https://cdn.corenexis.com/files/c/3751385720.jpg'], 'Eye glasses', 'Anti Blue Ray', 78, 4.6, 189, false, ARRAY['reading-glasses', 'eyewear'], '{"Size": "Free Size", "Lenses": "Anti Blue Ray"}'::jsonb, 0),
('Classic Polygon Anti-Blue Light Glass', 'Designed for modern screen-heavy lifestyles.', 1899, 2500, ARRAY['https://cdn.corenexis.com/files/c/1979259720.jpg'], 'Eye glasses', 'Anti Blue Ray', 23, 4.9, 156, false, ARRAY['reading-glasses', 'eyewear'], '{"Size": "Free Size", "Lenses": "Anti Blue Ray"}'::jsonb, 0),
('Lumi Cat Eye Anti-Blue Light Glass', 'Engineered to support your daily digital routine.', 1799, 2600, ARRAY['https://cdn.corenexis.com/files/c/8336955720.jpg'], 'Eye glasses', 'OptiVision', 150, 4.7, 412, false, ARRAY['reading-glasses', 'eyewear'], '{"Size": "Free Size", "Lenses": "Anti Blue Ray"}'::jsonb, 0),
('2 in 1 Vintage Photochromic Glass', 'Built for a dynamic lifestyle with adaptive lenses.', 1999, 3000, ARRAY['https://cdn.corenexis.com/files/c/4599955720.webp'], 'Eye glasses', 'Photochromic', 34, 4.8, 89, false, ARRAY['sunglasses', 'photochromic'], '{"Lenses": "Anti Blue Ray, Photochromic"}'::jsonb, 0),
('2 in 1 Icon Square Photochromic Glass', 'Engineered for modern routines.', 1799, 2700, ARRAY['https://cdn.corenexis.com/files/c/3165389720.jpg'], 'Eye glasses', 'Photochromic', 12, 4.9, 67, false, ARRAY['sunglasses', 'photochromic'], '{"Lenses": "Anti Blue Ray, Photochromic"}'::jsonb, 0),
('Semi Rimless Anti Blue Light Glass', 'Stay comfortable during long screen hours.', 1699, 2999, ARRAY['https://img.drz.lazcdn.com/static/lk/p/3d4767e23ffb94c23d3e85bf03c4c594.jpg_960x960q80.jpg_.webp'], 'Eye glasses', 'Anti Blue Ray', 156, 4.4, 189, false, ARRAY['reading-glasses'], '{"Lenses": "Anti Blue Ray"}'::jsonb, 0);

-- ============================================
-- DONE!
-- ============================================

SELECT 'Database setup complete!' AS status;
