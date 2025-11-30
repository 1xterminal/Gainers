-- =============================================================================
-- 0. RESET / CLEAN SLATE (TEARDOWN)
-- Menghapus tabel lama agar tidak error "already exists"
-- CASCADE akan otomatis menghapus tabel anak (logs) yang terhubung
-- =============================================================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Menghapus tabel profiles beserta semua tabel yang mereferensikannya (CASCADE)
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Hapus tabel lain untuk memastikan bersih (jika tidak terhapus cascade)
DROP TABLE IF EXISTS public.daily_steps CASCADE;
DROP TABLE IF EXISTS public.food_logs CASCADE;
DROP TABLE IF EXISTS public.water_logs CASCADE;
DROP TABLE IF EXISTS public.sleep_logs CASCADE;
DROP TABLE IF EXISTS public.weight_logs CASCADE;
DROP TABLE IF EXISTS public.workout_sessions CASCADE;
DROP TABLE IF EXISTS public.user_badges CASCADE;
DROP TABLE IF EXISTS public.badges CASCADE;
DROP TABLE IF EXISTS public.challenges CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;


-- =============================================================================
-- 1. TABLES & STRUCTURE (DDL)
-- =============================================================================

-- 1.1. Profiles (Parent Table)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  display_name text,
  avatar_url text,
  gender text,
  date_of_birth date,
  height_cm int,
  weight_kg numeric(6,2),
  activity_goal text,
  unit_preference text default 'metric',
  hydration_target int default 2000,
  created_at timestamptz default now()
);

-- 1.2. Daily Steps
create table public.daily_steps (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  date date not null,
  step_count int not null default 0,
  distance_meters int default 0,
  active_calories int default 0,
  created_at timestamptz default now(),
  unique(user_id, date)
);

-- 1.3. Food logs
create table public.food_logs (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  food_name text not null,
  calories int not null,
  protein_g int default 0,
  carbs_g int default 0,
  fat_g int default 0,
  meal_type text not null
);

-- 1.4. Hydration
create table public.water_logs (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  amount_ml int not null
);

-- 1.5. Sleep
create table public.sleep_logs (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  start_time timestamptz not null,
  end_time timestamptz not null,
  duration_minutes int not null,
  created_at timestamptz default now()
);

-- 1.6. Weight logs
create table public.weight_logs (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  weight_kg numeric(6,2) not null,
  skeletal_muscle numeric(6,2),
  body_fat numeric(6,2),
  notes text
);

-- 1.7. Workout sessions
create table public.workout_sessions (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  type text,
  duration_seconds int,
  calories_burned int,
  details jsonb,
  created_at timestamptz default now()
);

-- 1.8. Badges
create table public.badges (
  id bigserial primary key,
  key text unique,
  title text,
  description text,
  icon_url text
);

-- 1.9. User badges (unlock)
create table public.user_badges (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  badge_id int references public.badges(id),
  unlocked_at timestamptz default now(),
  unique(user_id, badge_id)
);

-- 1.10. Challenges
create table public.challenges (
  id bigserial primary key,
  creator_id uuid references public.profiles(id),
  title text,
  description text,
  type text,
  target_value int,
  start_date date,
  end_date date,
  created_at timestamptz default now()
);

-- 1.11. Notifications
create table public.notifications (
  id bigserial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  title text,
  body text,
  delivered boolean default false,
  scheduled_at timestamptz,
  created_at timestamptz default now()
);

-- =============================================================================
-- 2. INDEXES (PERFORMANCE)
-- =============================================================================
create index if not exists idx_daily_steps_user_date on public.daily_steps (user_id, date desc);
create index if not exists idx_water_logs_user_created on public.water_logs (user_id, created_at desc);
create index if not exists idx_sleep_logs_user_created on public.sleep_logs (user_id, created_at desc);
create index if not exists idx_weight_logs_user_created on public.weight_logs (user_id, created_at desc);
create index if not exists idx_food_logs_user_created on public.food_logs (user_id, created_at desc);

-- =============================================================================
-- 3. FUNCTIONS & TRIGGERS (AUTOMATION)
-- =============================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data ->> 'username');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- =============================================================================
-- 4. ROW LEVEL SECURITY (RLS) & POLICIES (OPTIMIZED)
-- =============================================================================

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.water_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Policies (Using Optimized SELECT AUTH.UID())

-- 1. Profiles
create policy "Profiles: allow read for all" on public.profiles for select to public using (true);
create policy "Profiles: user can update own" on public.profiles for update to authenticated using ((select auth.uid()) = id);
create policy "Profiles: user can insert own" on public.profiles for insert to authenticated with check ((select auth.uid()) = id);

-- 2. Daily Steps
create policy "Steps: select own" on public.daily_steps for select using ((select auth.uid()) = user_id);
create policy "Steps: insert own" on public.daily_steps for insert with check ((select auth.uid()) = user_id);
create policy "Steps: update own" on public.daily_steps for update using ((select auth.uid()) = user_id);
create policy "Steps: delete own" on public.daily_steps for delete using ((select auth.uid()) = user_id);

-- 3. Food Logs
create policy "Food: select own" on public.food_logs for select using ((select auth.uid()) = user_id);
create policy "Food: insert own" on public.food_logs for insert with check ((select auth.uid()) = user_id);
create policy "Food: update own" on public.food_logs for update using ((select auth.uid()) = user_id);
create policy "Food: delete own" on public.food_logs for delete using ((select auth.uid()) = user_id);

-- 4. Water Logs
create policy "Water: select own" on public.water_logs for select using ((select auth.uid()) = user_id);
create policy "Water: insert own" on public.water_logs for insert with check ((select auth.uid()) = user_id);
create policy "Water: update own" on public.water_logs for update using ((select auth.uid()) = user_id);
create policy "Water: delete own" on public.water_logs for delete using ((select auth.uid()) = user_id);

-- 5. Sleep Logs
create policy "Sleep: select own" on public.sleep_logs for select using ((select auth.uid()) = user_id);
create policy "Sleep: insert own" on public.sleep_logs for insert with check ((select auth.uid()) = user_id);
create policy "Sleep: update own" on public.sleep_logs for update using ((select auth.uid()) = user_id);
create policy "Sleep: delete own" on public.sleep_logs for delete using ((select auth.uid()) = user_id);

-- 6. Weight Logs
create policy "Weight: select own" on public.weight_logs for select using ((select auth.uid()) = user_id);
create policy "Weight: insert own" on public.weight_logs for insert with check ((select auth.uid()) = user_id);
create policy "Weight: update own" on public.weight_logs for update using ((select auth.uid()) = user_id);
create policy "Weight: delete own" on public.weight_logs for delete using ((select auth.uid()) = user_id);

-- 7. Workout Sessions
create policy "Workout: select own" on public.workout_sessions for select using ((select auth.uid()) = user_id);
create policy "Workout: insert own" on public.workout_sessions for insert with check ((select auth.uid()) = user_id);
create policy "Workout: update own" on public.workout_sessions for update using ((select auth.uid()) = user_id);
create policy "Workout: delete own" on public.workout_sessions for delete using ((select auth.uid()) = user_id);

-- 8. Badges
create policy "Badges: readable for all" on public.badges for select to public using (true);

-- 9. User Badges
create policy "UserBadges: select own" on public.user_badges for select using ((select auth.uid()) = user_id);
create policy "UserBadges: insert own" on public.user_badges for insert with check ((select auth.uid()) = user_id);

-- 10. Challenges
create policy "Challenges: select all" on public.challenges for select using (true);
create policy "Challenges: insert creator" on public.challenges for insert with check ((select auth.uid()) = creator_id);
create policy "Challenges: update creator" on public.challenges for update using ((select auth.uid()) = creator_id);

-- 11. Notifications
create policy "Notif: select own" on public.notifications for select using ((select auth.uid()) = user_id);
create policy "Notif: insert own" on public.notifications for insert with check ((select auth.uid()) = user_id);
create policy "Notif: update own" on public.notifications for update using ((select auth.uid()) = user_id);

-- =============================================================================
-- 5. RPC FUNCTION: DELETE OWN ACCOUNT
-- Fungsi ini dipanggil dari Flutter untuk user menghapus akunnya sendiri
-- =============================================================================

create or replace function public.delete_user_account()
returns void
language plpgsql
security definer -- PENTING: Jalan dengan hak akses admin (bypass RLS)
as $$
begin
  -- Menghapus user dari tabel auth.users
  -- Karena CASCADE, ini otomatis menghapus profiles & logs juga.
  delete from auth.users
  where id = auth.uid();
end;
$$;
