-- Supabase setup for Chat Vista Alegre (Supabase Auth with anonymous sign-in)
-- Project: ujlxgjaqklfxgiigzkid

-- 1) Table
create table if not exists public.chat_messages (
  id text primary key,
  created_at timestamptz not null default now(),
  user_id text not null,
  username text not null,
  text text,
  type text not null default 'text' check (type in ('text', 'audio')),
  audio_url text,
  emoji text,
  avatar_type text,
  avatar_image text,
  color text
);

create index if not exists idx_chat_messages_created_at on public.chat_messages (created_at desc);

-- 2) Realtime
alter table public.chat_messages replica identity full;

-- 3) RLS
alter table public.chat_messages enable row level security;

-- Remove old policies if they exist

drop policy if exists "chat_read_all" on public.chat_messages;
drop policy if exists "chat_insert_all" on public.chat_messages;
drop policy if exists "chat_update_none" on public.chat_messages;
drop policy if exists "chat_delete_none" on public.chat_messages;

drop policy if exists "Qualquer usuário autenticado pode ler" on public.chat_messages;
drop policy if exists "Usuário autenticado pode inserir" on public.chat_messages;
drop policy if exists "Usuário autenticado pode deletar suas mensagens" on public.chat_messages;
drop policy if exists "Usuário autenticado pode atualizar suas mensagens" on public.chat_messages;

-- Read for authenticated users (includes anonymous sign-in users)
create policy "chat_read_all"
on public.chat_messages
for select
to authenticated
using (true);

-- Insert for authenticated users (includes anonymous sign-in users)
create policy "chat_insert_all"
on public.chat_messages
for insert
to authenticated
with check (
  length(coalesce(user_id, '')) > 0
  and length(coalesce(username, '')) > 0
  and type in ('text', 'audio')
);

-- Explicitly block update/delete in public mode
create policy "chat_update_none"
on public.chat_messages
for update
to authenticated
using (false)
with check (false);

create policy "chat_delete_none"
on public.chat_messages
for delete
to authenticated
using (false);

-- 4) Storage bucket for audios/files
insert into storage.buckets (id, name, public)
values ('chat-audios', 'chat-audios', true)
on conflict (id) do update set public = excluded.public;

-- Remove old storage policies

drop policy if exists "chat_audios_public_read" on storage.objects;
drop policy if exists "chat_audios_public_insert" on storage.objects;

-- Public read
create policy "chat_audios_public_read"
on storage.objects
for select
to authenticated
using (bucket_id = 'chat-audios');

-- Public insert
create policy "chat_audios_public_insert"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'chat-audios');

-- Optional: allow updates/deletes on objects (disabled by default for safer behavior)
-- create policy "chat_audios_public_update"
-- on storage.objects
-- for update
-- to anon, authenticated
-- using (bucket_id = 'chat-audios')
-- with check (bucket_id = 'chat-audios');
--
-- create policy "chat_audios_public_delete"
-- on storage.objects
-- for delete
-- to anon, authenticated
-- using (bucket_id = 'chat-audios');

-- 5) Helpful grants (usually already present)
grant usage on schema public to anon, authenticated;
grant select, insert on public.chat_messages to authenticated;
