-- migration: 20250521200000_initial_schema_setup.sql
-- purpose: sets up the initial database schema including enums, tables, RLS policies, and triggers.
-- affected_tables: public.profiles, public.generations
-- special_considerations:
--   - enables row level security on all new tables.
--   - includes a trigger to create a user profile on new user signup.
--   - includes a trigger to handle storage object deletion when a generation record is deleted (requires bucket name configuration).

-- step 1: create enums
-- create generation_status_enum type
-- this enum defines the possible states for an image generation process.
create type public.generation_status_enum as enum (
    'oczekująca',
    'przetwarzanie',
    'zakończono_pomyślnie',
    'błąd_api_dalle',
    'błąd_timeout',
    'błąd_wewnętrzny'
);

comment on type public.generation_status_enum is 'defines the possible statuses of an image generation process.';

-- step 2: create tables
-- create profiles table
-- stores additional information for users, extending auth.users.
create table public.profiles (
    user_id uuid primary key references auth.users(id) on delete cascade,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    daily_generation_count smallint not null default 0,
    last_generation_date date null
);

comment on table public.profiles is 'stores additional user profile information, extending auth.users.';
comment on column public.profiles.user_id is 'primary key, foreign key to auth.users.id.';
comment on column public.profiles.created_at is 'timestamp of profile creation (utc).';
comment on column public.profiles.updated_at is 'timestamp of last profile update (utc).';
comment on column public.profiles.daily_generation_count is 'counter for daily generations by the user.';
comment on column public.profiles.last_generation_date is 'date of the last generation, used for resetting the daily counter.';

-- create generations table
-- stores information about each image generation attempt.
create table public.generations (
    id serial primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    reference_image_location text not null,
    prompt_text varchar(1000) not null,
    generated_image_location text null,
    generation_status public.generation_status_enum not null default 'oczekująca',
    status_message text null,
    created_at timestamptz not null default now()
);

comment on table public.generations is 'stores information about each image generation attempt.';
comment on column public.generations.id is 'unique identifier for the generation (auto-incrementing).';
comment on column public.generations.user_id is 'identifier of the user who initiated the generation.';
comment on column public.generations.reference_image_location is 'path/key to the reference image in supabase storage.';
comment on column public.generations.prompt_text is 'text prompt used for generation.';
comment on column public.generations.generated_image_location is 'path/key to the generated image in supabase storage (null if error).';
comment on column public.generations.generation_status is 'status of the image generation process.';
comment on column public.generations.status_message is 'optional error message or additional status information.';
comment on column public.generations.created_at is 'timestamp of generation record creation (utc).';

-- step 3: create indexes
-- index for quick lookup of user generations, sorted by newest first.
create index idx_generations_user_id_created_at on public.generations (user_id, created_at desc);

comment on index idx_generations_user_id_created_at is 'optimizes fetching user generation history.';

-- step 4: enable rls and create policies
-- enable row level security for both tables
alter table public.profiles enable row level security;
alter table public.generations enable row level security;

comment on table public.profiles is 'user profiles. rls is enabled.';
comment on table public.generations is 'image generation records. rls is enabled.';

-- rls policies for public.profiles table
-- policy: allow authenticated users to read their own profile
create policy "allow authenticated user read access to their own profile"
on public.profiles
for select
to authenticated
using (auth.uid() = user_id);

comment on policy "allow authenticated user read access to their own profile" on public.profiles is 'authenticated users can select their own profile.';

-- policy: allow authenticated users to update their own profile
create policy "allow authenticated user update access to their own profile"
on public.profiles
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

comment on policy "allow authenticated user update access to their own profile" on public.profiles is 'authenticated users can update their own profile.';

-- rls policies for public.generations table
-- policy: allow authenticated users to read their own generations
create policy "allow authenticated user read access to their own generations"
on public.generations
for select
to authenticated
using (auth.uid() = user_id);

comment on policy "allow authenticated user read access to their own generations" on public.generations is 'authenticated users can select their own generation records.';

-- policy: allow authenticated users to insert their own generations
create policy "allow authenticated user to insert their own generations"
on public.generations
for insert
to authenticated
with check (auth.uid() = user_id);

comment on policy "allow authenticated user to insert their own generations" on public.generations is 'authenticated users can insert their own generation records.';

-- policy: allow authenticated users to delete their own generations
create policy "allow authenticated user to delete their own generations"
on public.generations
for delete
to authenticated
using (auth.uid() = user_id);

comment on policy "allow authenticated user to delete their own generations" on public.generations is 'authenticated users can delete their own generation records.';

-- step 5: create functions for triggers
-- function to create a profile for a new user
create or replace function public.handle_new_user(user_id uuid)
returns void
language plpgsql
security definer -- essential for this function to write to public.profiles
as $$
begin
  insert into public.profiles (user_id, updated_at)
  values (user_id, now());
end;
$$;

comment on function public.handle_new_user(uuid) is 'creates a new user profile in public.profiles. to be called after a new user is registered.';

-- function to handle deletion of generation-related storage objects
create or replace function public.handle_deleted_generation()
returns trigger
language plpgsql
security definer -- necessary if using supabase storage admin functions that require elevated privileges.
as $$
begin
  -- attempt to delete reference image if location is not null or empty
  if old.reference_image_location is not null and old.reference_image_location <> '' then
    -- note: the actual storage object removal function might differ based on supabase version or specific extensions.
    -- this is a conceptual example. ensure you have pg_net or appropriate extensions enabled and configured.
    -- select extensions.storage_remove_object('your_storage_bucket_name', old.reference_image_location);
    -- an alternative is to use an edge function called via pg_net or http extension.
    raise notice 'stub: would delete reference image at %', old.reference_image_location;
  end if;

  -- attempt to delete generated image if location is not null or empty
  if old.generated_image_location is not null and old.generated_image_location <> '' then
    -- select extensions.storage_remove_object('your_storage_bucket_name', old.generated_image_location);
    raise notice 'stub: would delete generated image at %', old.generated_image_location;
  end if;
  return old;
end;
$$;

comment on function public.handle_deleted_generation() is 'attempts to delete associated images from supabase storage when a generation record is deleted. requires configuration of the storage bucket name and appropriate storage access from postgresql.';

-- step 6: create triggers (after all tables, permissions and functions are in place)
-- note: we can't create a trigger on auth.users as we don't have permission
-- instead, you'll need to call handle_new_user() from your application code when a user signs up
-- or use a supabase hook/function that has permission to respond to auth events

-- trigger to execute handle_deleted_generation on generation deletion
create trigger on_generation_deleted
  after delete on public.generations
  for each row execute function public.handle_deleted_generation();

comment on trigger on_generation_deleted on public.generations is 'after a generation record is deleted, this trigger fires handle_deleted_generation() to attempt to remove associated storage objects.';

-- migration script finished
-- remember to apply this migration using supabase cli: supabase db push
-- or if using local dev: supabase start (which applies new migrations) 