-- Diario caffè · Community: archivio su Supabase.
-- Incolla tutto in Supabase → SQL Editor → New query, poi premi "Run".
-- Si può rieseguire: le tabelle esistenti non vengono toccate, le regole vengono ricreate.
--
-- Cosa è condiviso e cosa no:
--   catalog   schede dei caffè (nome, torrefazione, origine, foto…): le vedono tutti i membri,
--             le modifica solo chi le ha create.
--   coffees   le confezioni nella dispensa di ciascuno (data di tostatura, peso, prezzo, terminato):
--             private.
--   brews     le estrazioni: private.
--   grinders  i macinini di ciascuno: privati.
--   profiles  il nome con cui ognuno compare nel catalogo: visibile ai membri.

-- ---------- tabelle ----------
create table if not exists public.profiles (
  id uuid primary key default auth.uid() references auth.users on delete cascade,
  name text not null default '' check (char_length(name) <= 40),
  updated_at timestamptz not null default now()
);

create table if not exists public.catalog (
  id text primary key,
  -- se l'account di chi ha creato la scheda viene eliminato, la scheda resta nel catalogo
  created_by uuid default auth.uid() references auth.users on delete set null,
  data jsonb not null check (coalesce(data->>'name', '') <> ''),
  updated_at timestamptz not null default now()
);

create table if not exists public.coffees (
  id text primary key,
  owner uuid not null default auth.uid() references auth.users on delete cascade,
  -- una scheda del catalogo non si può eliminare finché qualcuno la ha in dispensa
  catalog_id text not null references public.catalog (id) on delete restrict,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.brews (
  id text primary key,
  owner uuid not null default auth.uid() references auth.users on delete cascade,
  coffee_id text not null,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.grinders (
  id text primary key,
  owner uuid not null default auth.uid() references auth.users on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create index if not exists coffees_catalog_idx on public.coffees (catalog_id);
create index if not exists coffees_owner_idx on public.coffees (owner);
create index if not exists brews_coffee_idx on public.brews (coffee_id);
create index if not exists brews_owner_idx on public.brews (owner);
create index if not exists grinders_owner_idx on public.grinders (owner);
create index if not exists catalog_created_by_idx on public.catalog (created_by);

-- ---------- regole di sicurezza ----------
alter table public.profiles enable row level security;
alter table public.catalog  enable row level security;
alter table public.coffees  enable row level security;
alter table public.brews    enable row level security;
alter table public.grinders enable row level security;

-- profili: tutti i membri leggono, ognuno scrive solo il proprio
drop policy if exists "profiles: lettura membri" on public.profiles;
create policy "profiles: lettura membri" on public.profiles
  for select to authenticated using (true);
drop policy if exists "profiles: inserimento proprio" on public.profiles;
create policy "profiles: inserimento proprio" on public.profiles
  for insert to authenticated with check (id = (select auth.uid()));
drop policy if exists "profiles: modifica propria" on public.profiles;
create policy "profiles: modifica propria" on public.profiles
  for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- catalogo: tutti i membri leggono e aggiungono, modifica ed eliminazione solo a chi ha creato la scheda
drop policy if exists "catalog: lettura membri" on public.catalog;
create policy "catalog: lettura membri" on public.catalog
  for select to authenticated using (true);
drop policy if exists "catalog: inserimento" on public.catalog;
create policy "catalog: inserimento" on public.catalog
  for insert to authenticated with check (created_by = (select auth.uid()));
drop policy if exists "catalog: modifica autore" on public.catalog;
create policy "catalog: modifica autore" on public.catalog
  for update to authenticated using (created_by = (select auth.uid())) with check (created_by = (select auth.uid()));
drop policy if exists "catalog: eliminazione autore" on public.catalog;
create policy "catalog: eliminazione autore" on public.catalog
  for delete to authenticated using (created_by = (select auth.uid()));

-- dati personali: ognuno vede e modifica solo i propri
drop policy if exists "coffees: solo il proprietario" on public.coffees;
create policy "coffees: solo il proprietario" on public.coffees
  for all to authenticated using (owner = (select auth.uid())) with check (owner = (select auth.uid()));
drop policy if exists "brews: solo il proprietario" on public.brews;
create policy "brews: solo il proprietario" on public.brews
  for all to authenticated using (owner = (select auth.uid())) with check (owner = (select auth.uid()));
drop policy if exists "grinders: solo il proprietario" on public.grinders;
create policy "grinders: solo il proprietario" on public.grinders
  for all to authenticated using (owner = (select auth.uid())) with check (owner = (select auth.uid()));

-- Quanti membri hanno ogni caffè in dispensa (solo il numero, non chi).
create or replace function public.catalog_counts()
returns table (catalog_id text, members bigint)
language sql stable security definer set search_path = public
as $$ select c.catalog_id, count(distinct c.owner) from public.coffees c group by c.catalog_id $$;
revoke execute on function public.catalog_counts() from public, anon;
grant execute on function public.catalog_counts() to authenticated;

-- ---------- aggiornamenti in tempo reale ----------
do $$
declare t text;
begin
  foreach t in array array['profiles','catalog','coffees','brews','grinders'] loop
    if not exists (select 1 from pg_publication_tables
                   where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- ---------- foto ----------
-- Cartella "photos" leggibile tramite link (così le foto del catalogo si vedono da tutti i membri);
-- ognuno carica ed elimina solo nella propria sottocartella.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 5242880, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "photos: lettura propria" on storage.objects;
create policy "photos: lettura propria" on storage.objects
  for select to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "photos: caricamento" on storage.objects;
create policy "photos: caricamento" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "photos: eliminazione" on storage.objects;
create policy "photos: eliminazione" on storage.objects
  for delete to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
