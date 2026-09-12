-- Query/URL discovery and connection checks. Run once in Supabase SQL Editor.
-- Standalone: does not require the earlier design-only MVP_schema.sql.
-- No extension, destructive reset, public signup policy or client-write policy.
begin;

create table if not exists public.core_discovery_runs (
  id uuid primary key,
  owner_id uuid not null references auth.users(id),
  kind text not null check (kind in ('serp','ranked')),
  state text not null check (state in ('started','complete','failed','unknown_outcome')),
  input_json jsonb not null,
  input_sha256 text not null,
  endpoint text not null,
  request_json jsonb not null check (jsonb_typeof(request_json)='array' and jsonb_array_length(request_json)=1),
  scope_json jsonb not null,
  config_json jsonb not null,
  catalogue_json jsonb not null,
  result_json jsonb,
  actual_cost numeric,
  cost_pointer text,
  failure text,
  started_at timestamptz not null,
  finished_at timestamptz,
  unique (id, owner_id)
);

create table if not exists public.core_discovery_raw (
  run_id uuid primary key,
  owner_id uuid not null,
  http_status integer not null,
  body_base64 text not null,
  body_sha256 text not null,
  parsed_json jsonb,
  received_at timestamptz not null,
  foreign key (run_id, owner_id) references public.core_discovery_runs(id, owner_id)
);

create table if not exists public.core_connection_checks (
  id uuid primary key,
  owner_id uuid not null references auth.users(id),
  checked_at timestamptz not null
);

alter table public.core_discovery_runs enable row level security;
alter table public.core_discovery_raw enable row level security;
alter table public.core_connection_checks enable row level security;
revoke all on public.core_discovery_runs, public.core_discovery_raw, public.core_connection_checks from anon, authenticated;
grant select on public.core_discovery_runs, public.core_discovery_raw, public.core_connection_checks to authenticated;
grant all on public.core_discovery_runs, public.core_discovery_raw, public.core_connection_checks to service_role;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='core_discovery_runs' and policyname='discovery_owner_read') then
    create policy discovery_owner_read on public.core_discovery_runs for select to authenticated using (owner_id=(select auth.uid()));
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='core_discovery_raw' and policyname='discovery_raw_owner_read') then
    create policy discovery_raw_owner_read on public.core_discovery_raw for select to authenticated using (owner_id=(select auth.uid()));
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='core_connection_checks' and policyname='connection_owner_read') then
    create policy connection_owner_read on public.core_connection_checks for select to authenticated using (owner_id=(select auth.uid()));
  end if;
end $$;
create index if not exists discovery_owner_date on public.core_discovery_runs(owner_id, started_at desc);
commit;
