-- Links a user to one or more sign-in methods (email/password, Apple, Google)
CREATE TABLE auth_providers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(20) NOT NULL CHECK (provider IN ('EMAIL', 'APPLE', 'GOOGLE')),
    provider_user_id VARCHAR(255),
    password_hash VARCHAR(255),
    CONSTRAINT uq_provider_user UNIQUE (provider, provider_user_id)
);