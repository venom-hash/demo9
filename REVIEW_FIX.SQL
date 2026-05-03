-- ============================================
-- REVIEW TABLE FIX - Run this in Supabase SQL Editor
-- Fixes: invalid input syntax for type uuid: "10"
-- ============================================

-- Step 1: Drop existing reviews table 
-- (Warning: This will delete any existing reviews)
DROP TABLE IF EXISTS public.reviews;

-- Step 2: Create new reviews table with TEXT product_id
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL, -- Changed from UUID to TEXT for local IDs
  reviewer_name TEXT NOT NULL DEFAULT 'Customer',
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_verified BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 3: Enable Row Level Security
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Step 4: Create policies
CREATE POLICY "Anyone can view approved reviews"
  ON public.reviews FOR SELECT USING (
    status = 'approved' OR auth.uid() = user_id
  );

CREATE POLICY "Users can create reviews"
  ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
  ON public.reviews FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews"
  ON public.reviews FOR DELETE USING (auth.uid() = user_id);

-- Step 5: Create indexes
CREATE INDEX IF NOT EXISTS idx_reviews_product_id 
  ON public.reviews(product_id);

CREATE INDEX IF NOT EXISTS idx_reviews_status 
  ON public.reviews(status) WHERE status = 'approved';

-- Done
SELECT 'Reviews table fixed!' AS status;
