-- ============================================
-- NovaDrop - Reviews Table Setup SQL
-- Add this to your Supabase SQL Editor
-- ============================================

-- ============================================
-- STEP 1: Create reviews table
-- ============================================

CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL, -- Changed to TEXT to support local product IDs like '1', '2', etc.
  reviewer_name TEXT NOT NULL DEFAULT 'Customer',
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_verified BOOLEAN DEFAULT false, -- For verified purchases
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Anyone can view approved reviews
CREATE POLICY "Anyone can view approved reviews"
  ON public.reviews FOR SELECT USING (
    status = 'approved' OR auth.uid() = user_id
  );

-- Authenticated users can create reviews
CREATE POLICY "Users can create reviews"
  ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own reviews
CREATE POLICY "Users can update own reviews"
  ON public.reviews FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own reviews
CREATE POLICY "Users can delete own reviews"
  ON public.reviews FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- STEP 2: Add index for faster queries
-- ============================================

CREATE INDEX IF NOT EXISTS idx_reviews_product_id 
  ON public.reviews(product_id);

CREATE INDEX IF NOT EXISTS idx_reviews_status 
  ON public.reviews(status) WHERE status = 'approved';

ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS reviewer_name TEXT NOT NULL DEFAULT 'Customer';

-- ============================================
-- DONE!
-- ============================================

SELECT 'Reviews table setup complete!' AS status;

-- Check the table:
-- SELECT * FROM public.reviews ORDER BY created_at DESC;
