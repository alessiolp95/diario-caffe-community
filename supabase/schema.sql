-- Diario caffè · Community: archivio su Supabase.
-- Incolla tutto in Supabase → SQL Editor → New query, poi premi "Run".
-- Si può rieseguire: le tabelle esistenti non vengono toccate, le regole vengono ricreate.
--
-- Cosa è condiviso e cosa no:
--   catalog   schede dei caffè (nome, torrefazione, origine, foto…): le vedono tutti i membri,
--             le modificano chi le ha create e gli amministratori.
--   coffees   le confezioni nella dispensa di ciascuno (data di tostatura, peso, prezzo, terminato):
--             private.
--   brews     le estrazioni: private, salvo quelle che il proprietario sceglie di condividere
--             nella sezione Community (is_public): quelle le leggono tutti i membri.
--   machines  le macchine espresso di ciascuno: private.
--   grinders  i macinini di ciascuno: privati; grinder_presets() mostra agli altri solo i modelli
--             (marca, modello, macine, scala) senza dire chi li usa.
--   profiles  il nome con cui ognuno compare nel catalogo: visibile ai membri.
--   catalog_pairs  coppie di schede segnalate come doppioni dai membri, o segnate come "non doppioni"
--             dagli amministratori. Ognuno vede le proprie segnalazioni, gli amministratori tutte.
--   merge_catalog()  unisce due schede doppione (solo amministratori): sposta su quella tenuta
--             le confezioni e le estrazioni di tutti i membri ed elimina l'altra.
--   admins    gli amministratori: possono modificare ed eliminare qualsiasi scheda del catalogo
--             (e la sua foto). Si aggiungono solo da qui, mai dall'app:
--             insert into public.admins select id from auth.users where email = 'nome@esempio.it';

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

-- estrazioni condivise nella sezione Community
alter table public.brews add column if not exists is_public boolean not null default false;

create table if not exists public.machines (
  id text primary key,
  owner uuid not null default auth.uid() references auth.users on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.grinders (
  id text primary key,
  owner uuid not null default auth.uid() references auth.users on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.admins (
  user_id uuid primary key references auth.users on delete cascade
);

-- true se chi fa la richiesta è un amministratore
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;
revoke execute on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

create table if not exists public.catalog_pairs (
  a text not null references public.catalog (id) on delete cascade,
  b text not null references public.catalog (id) on delete cascade,
  status text not null default 'reported' check (status in ('reported', 'dismissed')),
  reported_by uuid default auth.uid() references auth.users on delete set null,
  created_at timestamptz not null default now(),
  primary key (a, b),
  check (a < b)
);

create index if not exists coffees_catalog_idx on public.coffees (catalog_id);
create index if not exists coffees_owner_idx on public.coffees (owner);
create index if not exists brews_coffee_idx on public.brews (coffee_id);
create index if not exists brews_owner_idx on public.brews (owner);
create index if not exists grinders_owner_idx on public.grinders (owner);
create index if not exists machines_owner_idx on public.machines (owner);
create index if not exists brews_public_idx on public.brews (is_public) where is_public;
create index if not exists catalog_created_by_idx on public.catalog (created_by);

-- ---------- regole di sicurezza ----------
alter table public.profiles enable row level security;
alter table public.catalog  enable row level security;
alter table public.coffees  enable row level security;
alter table public.brews    enable row level security;
alter table public.grinders enable row level security;
alter table public.admins   enable row level security;
alter table public.machines enable row level security;
alter table public.catalog_pairs enable row level security;

-- amministratori: ognuno vede solo se lo è lui; nessuna scrittura dall'app
drop policy if exists "admins: lettura propria" on public.admins;
create policy "admins: lettura propria" on public.admins
  for select to authenticated using (user_id = (select auth.uid()));

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

-- catalogo: tutti i membri leggono e aggiungono, modifica ed eliminazione a chi ha creato la scheda e agli amministratori
drop policy if exists "catalog: lettura membri" on public.catalog;
create policy "catalog: lettura membri" on public.catalog
  for select to authenticated using (true);
drop policy if exists "catalog: inserimento" on public.catalog;
create policy "catalog: inserimento" on public.catalog
  for insert to authenticated with check (created_by = (select auth.uid()));
drop policy if exists "catalog: modifica autore" on public.catalog;
create policy "catalog: modifica autore" on public.catalog
  for update to authenticated
  using (created_by = (select auth.uid()) or (select public.is_admin()))
  with check (created_by = (select auth.uid()) or (select public.is_admin()));
drop policy if exists "catalog: eliminazione autore" on public.catalog;
create policy "catalog: eliminazione autore" on public.catalog
  for delete to authenticated using (created_by = (select auth.uid()) or (select public.is_admin()));

-- dati personali: ognuno vede e modifica solo i propri
drop policy if exists "coffees: solo il proprietario" on public.coffees;
create policy "coffees: solo il proprietario" on public.coffees
  for all to authenticated using (owner = (select auth.uid())) with check (owner = (select auth.uid()));
-- estrazioni: le proprie sempre, quelle degli altri solo se condivise; si modificano solo le proprie
drop policy if exists "brews: solo il proprietario" on public.brews;
drop policy if exists "brews: lettura" on public.brews;
create policy "brews: lettura" on public.brews
  for select to authenticated using (owner = (select auth.uid()) or is_public);
drop policy if exists "brews: inserimento" on public.brews;
create policy "brews: inserimento" on public.brews
  for insert to authenticated with check (owner = (select auth.uid()));
drop policy if exists "brews: modifica" on public.brews;
create policy "brews: modifica" on public.brews
  for update to authenticated using (owner = (select auth.uid())) with check (owner = (select auth.uid()));
drop policy if exists "brews: eliminazione" on public.brews;
create policy "brews: eliminazione" on public.brews
  for delete to authenticated using (owner = (select auth.uid()));
drop policy if exists "machines: solo il proprietario" on public.machines;
create policy "machines: solo il proprietario" on public.machines
  for all to authenticated using (owner = (select auth.uid())) with check (owner = (select auth.uid()));
drop policy if exists "grinders: solo il proprietario" on public.grinders;
create policy "grinders: solo il proprietario" on public.grinders
  for all to authenticated using (owner = (select auth.uid())) with check (owner = (select auth.uid()));

-- doppioni: i membri segnalano, gli amministratori vedono tutto e decidono
drop policy if exists "pairs: lettura" on public.catalog_pairs;
create policy "pairs: lettura" on public.catalog_pairs
  for select to authenticated using (reported_by = (select auth.uid()) or (select public.is_admin()));
drop policy if exists "pairs: segnalazione" on public.catalog_pairs;
create policy "pairs: segnalazione" on public.catalog_pairs
  for insert to authenticated
  with check ((status = 'reported' and reported_by = (select auth.uid())) or (select public.is_admin()));
drop policy if exists "pairs: gestione admin" on public.catalog_pairs;
create policy "pairs: gestione admin" on public.catalog_pairs
  for update to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
drop policy if exists "pairs: eliminazione admin" on public.catalog_pairs;
create policy "pairs: eliminazione admin" on public.catalog_pairs
  for delete to authenticated using ((select public.is_admin()));

-- Unisce due schede doppione: tiene keep_id, completa i suoi campi vuoti con quelli di drop_id,
-- sposta su keep_id le confezioni e le estrazioni di tutti i membri ed elimina drop_id.
-- Tutto o niente. Restituisce quante confezioni ed estrazioni sono state spostate e la foto
-- della scheda eliminata (da cancellare dallo spazio foto, se non è stata adottata).
create or replace function public.merge_catalog(keep_id text, drop_id text)
returns jsonb
language plpgsql security definer set search_path = public
as $$
declare
  k public.catalog; d public.catalog;
  merged jsonb; key text; val jsonb; nb int; nbr int; drop_photo text;
begin
  if not public.is_admin() then
    raise exception 'Solo gli amministratori possono unire le schede' using errcode = '42501';
  end if;
  if keep_id = drop_id then raise exception 'Le due schede sono la stessa' using errcode = '22023'; end if;
  select * into k from public.catalog where id = keep_id for update;
  if not found then raise exception 'Scheda da tenere non trovata' using errcode = 'P0002'; end if;
  select * into d from public.catalog where id = drop_id for update;
  if not found then raise exception 'Scheda da eliminare non trovata' using errcode = 'P0002'; end if;

  merged := k.data;
  for key, val in select * from jsonb_each(d.data) loop
    if key <> 'createdAt' and (not merged ? key or merged -> key = 'null'::jsonb or merged ->> key = '') then
      merged := merged || jsonb_build_object(key, val);
    end if;
  end loop;

  update public.coffees
     set catalog_id = keep_id, data = jsonb_set(data, '{catalogId}', to_jsonb(keep_id)), updated_at = now()
   where catalog_id = drop_id;
  get diagnostics nb = row_count;
  update public.brews
     set data = jsonb_set(data, '{catalogId}', to_jsonb(keep_id)), updated_at = now()
   where data ->> 'catalogId' = drop_id;
  get diagnostics nbr = row_count;
  update public.catalog set data = merged, updated_at = now() where id = keep_id;
  delete from public.catalog where id = drop_id;

  drop_photo := nullif(d.data ->> 'photo', '');
  if drop_photo is not null and drop_photo = coalesce(merged ->> 'photo', '') then drop_photo := null; end if;
  return jsonb_build_object('bags', nb, 'brews', nbr, 'dropPhoto', drop_photo);
end $$;
revoke execute on function public.merge_catalog(text, text) from public, anon;
grant execute on function public.merge_catalog(text, text) to authenticated;

-- Modelli di macinino usati nella community, da proporre come modelli pronti:
-- solo marca, modello, macine e scala, con il numero di membri che li usano (mai chi).
create or replace function public.grinder_presets()
returns table (brand text, model text, burrs text, min numeric, max numeric, step numeric, members bigint)
language sql stable security definer set search_path = public
as $$
  select coalesce(g.data ->> 'brand', ''), g.data ->> 'model', coalesce(nullif(g.data ->> 'burrs', ''), 'Standard'),
         (g.data ->> 'min')::numeric, (g.data ->> 'max')::numeric, (g.data ->> 'step')::numeric,
         count(distinct g.owner)
    from public.grinders g
   where coalesce(g.data ->> 'model', '') <> ''
     and jsonb_typeof(g.data -> 'min') = 'number'
     and jsonb_typeof(g.data -> 'max') = 'number'
     and jsonb_typeof(g.data -> 'step') = 'number'
   group by 1, 2, 3, 4, 5, 6
$$;
revoke execute on function public.grinder_presets() from public, anon;
grant execute on function public.grinder_presets() to authenticated;

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
  foreach t in array array['profiles','catalog','coffees','brews','grinders','machines'] loop
    if not exists (select 1 from pg_publication_tables
                   where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- ---------- foto ----------
-- Cartella "photos" leggibile tramite link (così le foto del catalogo si vedono da tutti i membri);
-- ognuno carica ed elimina solo nella propria sottocartella; gli amministratori possono eliminare
-- anche le foto vecchie di schede altrui quando le sostituiscono.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 5242880, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "photos: lettura propria" on storage.objects;
create policy "photos: lettura propria" on storage.objects
  for select to authenticated
  using (bucket_id = 'photos' and ((storage.foldername(name))[1] = (select auth.uid())::text or (select public.is_admin())));

drop policy if exists "photos: caricamento" on storage.objects;
create policy "photos: caricamento" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "photos: eliminazione" on storage.objects;
create policy "photos: eliminazione" on storage.objects
  for delete to authenticated
  using (bucket_id = 'photos' and ((storage.foldername(name))[1] = (select auth.uid())::text or (select public.is_admin())));
