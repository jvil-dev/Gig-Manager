-- Stores gig bookings for the authenticated user
CREATE TABLE gigs(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    location TEXT,
    date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    type VARCHAR(100),
    payment_amount NUMERIC(10, 2),
    payment_status VARCHAR(50) NOT NULL DEFAULT 'UNPAID',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_gigs_user_id ON gigs(user_id);