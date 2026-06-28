-- NetTrack Pro V12.3 Signal Platform database foundation
-- Run in Supabase SQL Editor after reviewing. Signal-only model: users pay subscriptions; users trade on their own broker accounts.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  full_name text,
  phone text,
  role text not null default 'user' check (role in ('user','owner','admin')),
  verification_status text not null default 'basic' check (verification_status in ('basic','partial','verified','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan text not null default 'free_trial' check (plan in ('free_trial','basic','pro','premium')),
  status text not null default 'trialing' check (status in ('trialing','active','past_due','expired','cancelled')),
  trial_started_at timestamptz not null default now(),
  trial_ends_at timestamptz not null default (now() + interval '30 days'),
  current_period_start timestamptz,
  current_period_end timestamptz,
  amount_zar numeric(12,2) not null default 0,
  payment_provider text,
  provider_customer_id text,
  provider_subscription_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  subscription_id uuid references public.subscriptions(id) on delete set null,
  provider text not null,
  provider_reference text unique,
  amount_zar numeric(12,2) not null,
  status text not null default 'pending' check (status in ('pending','paid','failed','cancelled','refunded')),
  raw_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.signals (
  id uuid primary key default gen_random_uuid(),
  symbol text not null,
  timeframe text not null,
  broker_view text,
  direction text not null check (direction in ('BUY','SELL','WAIT','NEUTRAL')),
  confidence int not null default 0 check (confidence between 0 and 100),
  entry numeric(18,8),
  stop_loss numeric(18,8),
  take_profit numeric(18,8),
  grade text,
  reason text,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.signal_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  signal_id uuid references public.signals(id) on delete cascade,
  action text not null default 'viewed' check (action in ('viewed','saved','win','loss','ignored')),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.user_favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  symbol text not null,
  timeframe text not null default '1h',
  broker text default 'Binance',
  created_at timestamptz not null default now(),
  unique(user_id, symbol, timeframe, broker)
);

create table if not exists public.verification_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  document_type text not null check (document_type in ('id_copy','real_id_front','real_id_back','proof_of_address','other')),
  storage_path text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  subject text not null,
  message text not null,
  status text not null default 'open' check (status in ('open','pending','closed')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.subscriptions enable row level security;
alter table public.payments enable row level security;
alter table public.signals enable row level security;
alter table public.signal_history enable row level security;
alter table public.user_favorites enable row level security;
alter table public.verification_documents enable row level security;
alter table public.support_tickets enable row level security;

-- Basic user policies
create policy if not exists "profiles_self_select" on public.profiles for select using (auth.uid() = id);
create policy if not exists "profiles_self_update" on public.profiles for update using (auth.uid() = id);
create policy if not exists "subscriptions_self_select" on public.subscriptions for select using (auth.uid() = user_id);
create policy if not exists "payments_self_select" on public.payments for select using (auth.uid() = user_id);
create policy if not exists "signals_authenticated_select" on public.signals for select to authenticated using (true);
create policy if not exists "signal_history_self_all" on public.signal_history for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy if not exists "favorites_self_all" on public.user_favorites for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy if not exists "docs_self_select" on public.verification_documents for select using (auth.uid() = user_id);
create policy if not exists "docs_self_insert" on public.verification_documents for insert with check (auth.uid() = user_id);
create policy if not exists "tickets_self_all" on public.support_tickets for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Trial helper: create profile and free trial when a Supabase Auth user is created.
create or replace function public.handle_new_user_signal_trial()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;

  insert into public.subscriptions (user_id, plan, status, trial_started_at, trial_ends_at, amount_zar)
  values (new.id, 'free_trial', 'trialing', now(), now() + interval '30 days', 0)
  on conflict do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_signal_trial on auth.users;
create trigger on_auth_user_created_signal_trial
after insert on auth.users
for each row execute function public.handle_new_user_signal_trial();
