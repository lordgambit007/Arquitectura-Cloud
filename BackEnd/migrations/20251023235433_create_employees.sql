CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS employees (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  role        text NOT NULL,
  email       text UNIQUE,
  salary      numeric(12,2),
  avatar_url  text,
  created_at  timestamptz NOT NULL DEFAULT now()
);
