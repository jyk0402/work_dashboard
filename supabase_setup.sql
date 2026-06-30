-- 업무보고 공동 대시보드 초기 설치 SQL
-- Supabase SQL Editor에서 전체 실행하세요.

create extension if not exists pgcrypto;

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner text not null default '',
  description text not null default '',
  start_date date not null,
  end_date date not null,
  status text not null default '예정'
    check (status in ('예정','진행중','보류','완료')),
  progress_method text not null default 'count'
    check (progress_method in ('count','weight')),
  auto_complete boolean not null default false,
  deleted_at timestamptz,
  created_by text not null default '',
  updated_by text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id),
  work_date date not null default current_date,
  phase text not null default '',
  title text not null,
  detail text not null default '',
  owner text not null default '',
  status text not null default '예정'
    check (status in ('예정','진행중','검토중','보완필요','완료','보류')),
  start_date date not null,
  due_date date not null,
  progress_apply boolean not null default true,
  required_task boolean not null default false,
  weight integer not null default 1 check (weight >= 1),
  reference_link text not null default '',
  completed_at timestamptz,
  deleted_at timestamptz,
  created_by text not null default '',
  updated_by text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.issues (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id),
  registered_date date not null default current_date,
  priority text not null default '일반'
    check (priority in ('일반','중요','긴급')),
  detail text not null,
  response_detail text not null default '',
  decision_request text not null default '',
  result_detail text not null default '',
  owner text not null default '',
  due_date date not null,
  status text not null default '등록'
    check (status in ('등록','검토중','대응중','결정대기','완료','보류')),
  deleted_at timestamptz,
  created_by text not null default '',
  updated_by text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.qna (
  id uuid primary key default gen_random_uuid(),
  registered_date date not null default current_date,
  category text not null default '기타',
  question text not null,
  answer text not null default '',
  answer_status text not null default '미답변'
    check (answer_status in ('미답변','답변중','답변완료')),
  important boolean not null default false,
  reference_link text not null default '',
  deleted_at timestamptz,
  created_by text not null default '',
  updated_by text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_tasks_project_id on public.tasks(project_id);
create index if not exists idx_issues_project_id on public.issues(project_id);
create index if not exists idx_tasks_due_date on public.tasks(due_date);
create index if not exists idx_issues_due_date on public.issues(due_date);

-- updated_at 자동 갱신
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_projects_updated_at on public.projects;
create trigger trg_projects_updated_at before update on public.projects
for each row execute function public.set_updated_at();

drop trigger if exists trg_tasks_updated_at on public.tasks;
create trigger trg_tasks_updated_at before update on public.tasks
for each row execute function public.set_updated_at();

drop trigger if exists trg_issues_updated_at on public.issues;
create trigger trg_issues_updated_at before update on public.issues
for each row execute function public.set_updated_at();

drop trigger if exists trg_qna_updated_at on public.qna;
create trigger trg_qna_updated_at before update on public.qna
for each row execute function public.set_updated_at();

-- RLS 활성화
alter table public.projects enable row level security;
alter table public.tasks enable row level security;
alter table public.issues enable row level security;
alter table public.qna enable row level security;

-- 주의: 로그인 없는 링크 공동사용을 위해 anon 역할에 CRUD를 허용합니다.
-- 링크와 key를 아는 사람은 데이터를 읽고 수정할 수 있습니다.
drop policy if exists "public projects select" on public.projects;
drop policy if exists "public projects insert" on public.projects;
drop policy if exists "public projects update" on public.projects;
create policy "public projects select" on public.projects for select to anon using (true);
create policy "public projects insert" on public.projects for insert to anon with check (true);
create policy "public projects update" on public.projects for update to anon using (true) with check (true);

drop policy if exists "public tasks select" on public.tasks;
drop policy if exists "public tasks insert" on public.tasks;
drop policy if exists "public tasks update" on public.tasks;
create policy "public tasks select" on public.tasks for select to anon using (true);
create policy "public tasks insert" on public.tasks for insert to anon with check (true);
create policy "public tasks update" on public.tasks for update to anon using (true) with check (true);

drop policy if exists "public issues select" on public.issues;
drop policy if exists "public issues insert" on public.issues;
drop policy if exists "public issues update" on public.issues;
create policy "public issues select" on public.issues for select to anon using (true);
create policy "public issues insert" on public.issues for insert to anon with check (true);
create policy "public issues update" on public.issues for update to anon using (true) with check (true);

drop policy if exists "public qna select" on public.qna;
drop policy if exists "public qna insert" on public.qna;
drop policy if exists "public qna update" on public.qna;
create policy "public qna select" on public.qna for select to anon using (true);
create policy "public qna insert" on public.qna for insert to anon with check (true);
create policy "public qna update" on public.qna for update to anon using (true) with check (true);

grant select, insert, update on public.projects to anon;
grant select, insert, update on public.tasks to anon;
grant select, insert, update on public.issues to anon;
grant select, insert, update on public.qna to anon;

-- Realtime publication에 테이블 추가
do $$
begin
  begin alter publication supabase_realtime add table public.projects; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.tasks; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.issues; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.qna; exception when duplicate_object then null; end;
end $$;
