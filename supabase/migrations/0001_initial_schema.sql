-- Ubaidah Attendance App — initial relational model
-- PostgreSQL / Supabase
-- Run this migration once in the Supabase SQL Editor.

create extension if not exists "pgcrypto";

-- ---------- Enums ----------
create type public.attendance_status as enum ('present', 'absent', 'not_concerned');
create type public.attendance_channel_type as enum ('registered', 'public');
create type public.custom_field_type as enum ('text', 'number', 'date', 'boolean', 'select');

-- ---------- Core people ----------
create table public.person_types (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  icon text,
  color text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (owner_id, name)
);

create table public.people (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  first_name text not null,
  last_name text not null,
  display_name text,
  date_of_birth date,
  gender text,
  email text,
  phone text,
  address text,
  postal_code text,
  city text,
  country text,
  membership_number text,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, membership_number)
);

create table public.person_person_types (
  person_id uuid not null references public.people(id) on delete cascade,
  person_type_id uuid not null references public.person_types(id) on delete cascade,
  primary key (person_id, person_type_id)
);

-- ---------- Groups ----------
create table public.groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  icon text,
  color text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (owner_id, name)
);

create table public.person_groups (
  person_id uuid not null references public.people(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (person_id, group_id)
);

-- ---------- Custom fields for people ----------
create table public.person_custom_fields (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  field_key text not null,
  field_type public.custom_field_type not null,
  options jsonb not null default '[]'::jsonb,
  is_required boolean not null default false,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (owner_id, field_key),
  unique (owner_id, name)
);

create table public.person_custom_values (
  person_id uuid not null references public.people(id) on delete cascade,
  field_id uuid not null references public.person_custom_fields(id) on delete cascade,
  value jsonb not null default 'null'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (person_id, field_id)
);

-- ---------- Activities ----------
create table public.activity_types (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  icon text,
  color text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (owner_id, name)
);

create table public.activities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  activity_type_id uuid references public.activity_types(id) on delete set null,
  name text not null,
  starts_at timestamptz not null,
  ends_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or ends_at >= starts_at)
);

create table public.activity_people (
  activity_id uuid not null references public.activities(id) on delete cascade,
  person_id uuid not null references public.people(id) on delete cascade,
  primary key (activity_id, person_id)
);

create table public.activity_groups (
  activity_id uuid not null references public.activities(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  primary key (activity_id, group_id)
);

-- ---------- Attendance channels ----------
create table public.attendance_channels (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.activities(id) on delete cascade,
  name text not null,
  channel_type public.attendance_channel_type not null,
  registration_opens_at timestamptz,
  registration_closes_at timestamptz,
  qr_token text not null unique default encode(gen_random_bytes(24), 'hex'),
  direct_token text not null unique default encode(gen_random_bytes(24), 'hex'),
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  check (
    registration_closes_at is null
    or registration_opens_at is null
    or registration_closes_at > registration_opens_at
  )
);

-- ---------- Registered-person attendance ----------
create table public.attendance (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.activities(id) on delete cascade,
  person_id uuid not null references public.people(id) on delete restrict,
  channel_id uuid references public.attendance_channels(id) on delete set null,
  status public.attendance_status not null,
  recorded_at timestamptz not null default now(),
  unique (activity_id, person_id)
);

-- ---------- Public attendance / registration ----------
-- These rows are intentionally NOT linked to public.people.
create table public.public_registrations (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.activities(id) on delete cascade,
  channel_id uuid not null references public.attendance_channels(id) on delete cascade,
  submitted_at timestamptz not null default now(),
  data jsonb not null default '{}'::jsonb
);

-- ---------- Indexes ----------
create index people_owner_idx on public.people(owner_id);
create index people_active_idx on public.people(owner_id, is_active);
create index groups_owner_idx on public.groups(owner_id);
create index activity_types_owner_idx on public.activity_types(owner_id);
create index activities_owner_idx on public.activities(owner_id);
create index activities_starts_at_idx on public.activities(owner_id, starts_at desc);
create index activity_people_person_idx on public.activity_people(person_id);
create index activity_groups_group_idx on public.activity_groups(group_id);
create index attendance_activity_idx on public.attendance(activity_id);
create index attendance_person_idx on public.attendance(person_id);
create index public_registrations_activity_idx on public.public_registrations(activity_id);
create index public_registrations_channel_idx on public.public_registrations(channel_id);

-- ---------- Updated-at trigger ----------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger people_set_updated_at
before update on public.people
for each row execute function public.set_updated_at();

create trigger activities_set_updated_at
before update on public.activities
for each row execute function public.set_updated_at();

create trigger person_custom_values_set_updated_at
before update on public.person_custom_values
for each row execute function public.set_updated_at();

-- ---------- RLS ----------
alter table public.person_types enable row level security;
alter table public.people enable row level security;
alter table public.person_person_types enable row level security;
alter table public.groups enable row level security;
alter table public.person_groups enable row level security;
alter table public.person_custom_fields enable row level security;
alter table public.person_custom_values enable row level security;
alter table public.activity_types enable row level security;
alter table public.activities enable row level security;
alter table public.activity_people enable row level security;
alter table public.activity_groups enable row level security;
alter table public.attendance_channels enable row level security;
alter table public.attendance enable row level security;
alter table public.public_registrations enable row level security;

create policy "person types owner access" on public.person_types
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "people owner access" on public.people
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "person type links owner access" on public.person_person_types
for all using (
  exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
  and exists (select 1 from public.person_types pt where pt.id = person_type_id and pt.owner_id = auth.uid())
) with check (
  exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
  and exists (select 1 from public.person_types pt where pt.id = person_type_id and pt.owner_id = auth.uid())
);

create policy "groups owner access" on public.groups
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "group links owner access" on public.person_groups
for all using (
  exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
  and exists (select 1 from public.groups g where g.id = group_id and g.owner_id = auth.uid())
) with check (
  exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
  and exists (select 1 from public.groups g where g.id = group_id and g.owner_id = auth.uid())
);

create policy "custom fields owner access" on public.person_custom_fields
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "custom values owner access" on public.person_custom_values
for all using (
  exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
  and exists (select 1 from public.person_custom_fields f where f.id = field_id and f.owner_id = auth.uid())
) with check (
  exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
  and exists (select 1 from public.person_custom_fields f where f.id = field_id and f.owner_id = auth.uid())
);

create policy "activity types owner access" on public.activity_types
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "activities owner access" on public.activities
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "activity people owner access" on public.activity_people
for all using (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
  and exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
) with check (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
  and exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
);

create policy "activity groups owner access" on public.activity_groups
for all using (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
  and exists (select 1 from public.groups g where g.id = group_id and g.owner_id = auth.uid())
) with check (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
  and exists (select 1 from public.groups g where g.id = group_id and g.owner_id = auth.uid())
);

create policy "channels owner access" on public.attendance_channels
for all using (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
) with check (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
);

create policy "attendance owner access" on public.attendance
for all using (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
  and exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
) with check (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
  and exists (select 1 from public.people p where p.id = person_id and p.owner_id = auth.uid())
);

-- Public registrations are intentionally not readable/writable directly by anonymous clients.
-- They are inserted through the controlled RPC below and read by the owner only.
create policy "public registrations owner read" on public.public_registrations
for select using (
  exists (select 1 from public.activities a where a.id = activity_id and a.owner_id = auth.uid())
);

-- ---------- Controlled public submission ----------
-- The public QR/link exposes only a random channel token.
-- This function validates the channel, its type, and its registration window,
-- then inserts a registration without exposing table INSERT privileges to anon users.
create or replace function public.submit_public_registration(
  p_channel_token text,
  p_data jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_channel public.attendance_channels%rowtype;
  v_registration_id uuid;
begin
  select * into v_channel
  from public.attendance_channels
  where channel_type = 'public'
    and (qr_token = p_channel_token or direct_token = p_channel_token)
  limit 1;

  if not found then
    raise exception 'Invalid or unknown registration channel';
  end if;

  if v_channel.registration_opens_at is not null and now() < v_channel.registration_opens_at then
    raise exception 'Registration has not opened yet';
  end if;

  if v_channel.registration_closes_at is not null and now() > v_channel.registration_closes_at then
    raise exception 'Registration is closed';
  end if;

  insert into public.public_registrations (activity_id, channel_id, data)
  values (v_channel.activity_id, v_channel.id, coalesce(p_data, '{}'::jsonb))
  returning id into v_registration_id;

  return v_registration_id;
end;
$$;

revoke all on function public.submit_public_registration(text, jsonb) from public;
grant execute on function public.submit_public_registration(text, jsonb) to anon, authenticated;

-- No direct INSERT/UPDATE/DELETE policies are created for public_registrations.
-- The RPC above is the intended public submission path.
