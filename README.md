# 업무보고 실시간 공동 대시보드

## 무엇이 달라졌나
- 여러 사람이 같은 링크로 접속해 같은 데이터를 조회·수정합니다.
- 다른 사람이 업무를 완료하면 프로젝트 진척도가 실시간으로 갱신됩니다.
- 로그인은 없습니다.
- 사용자가 상단에 자기 이름을 입력하면 최근 수정자에 기록됩니다.
- 삭제는 실제 삭제가 아니라 `deleted_at`을 기록하는 휴지통 방식입니다.

## 준비물
1. Supabase 프로젝트 1개
2. 정적 웹 호스팅 1개
3. 이 폴더의 파일 3개
   - index.html
   - config.js
   - supabase_setup.sql

## 1단계: Supabase DB 만들기
1. Supabase에서 새 프로젝트를 만듭니다.
2. SQL Editor를 엽니다.
3. `supabase_setup.sql`의 전체 내용을 붙여넣고 실행합니다.
4. Project Settings 또는 Connect 화면에서 다음 값을 확인합니다.
   - Project URL
   - Publishable key 또는 anon key
5. `config.js`를 메모장으로 열어 두 값을 입력합니다.
6. `service_role` 키는 절대 입력하지 마세요.

예:
window.APP_CONFIG = {
  SUPABASE_URL: "https://xxxx.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_xxxx",
  APP_TITLE: "수출지원센터 업무보고 대시보드"
};

## 2단계: 먼저 로컬에서 확인
`index.html`을 더블클릭합니다.
상단에 `● 실시간 연결됨`이 나오면 정상입니다.

## 3단계: 링크로 배포
정적 사이트 호스팅 서비스에 `index.html`과 `config.js`를 같은 폴더 구조로 올립니다.
호스팅 후 생성된 URL을 사용자들에게 공유합니다.

사용할 수 있는 배포 방식의 예:
- 회사 내부 웹서버
- Microsoft Azure Static Web Apps
- Cloudflare Pages
- Netlify
- Vercel
- GitHub Pages

사내 업무자료라면 회사에서 허용한 서비스만 사용하세요.

## 보안상 중요한 사실
이 버전은 로그인 없이 anon 사용자에게 조회·등록·수정 권한을 줍니다.
따라서 링크와 Supabase 공개 키를 아는 사람은 데이터에 접근할 수 있습니다.
공개 키는 브라우저에서 숨길 수 없으며, service_role 키만 절대 노출하지 않으면 됩니다.
민감정보·개인정보·계약 비밀을 입력하기 전에는 사내 보안 담당자의 승인을 받는 것이 맞습니다.

## 파일 동작
웹앱은 사용자의 기존 로컬 파일이나 서버 파일을 수정·삭제하지 않습니다.
Supabase의 프로젝트·업무·이슈·Q&A 테이블만 읽고 수정합니다.
화면의 휴지통 버튼도 행을 물리적으로 삭제하지 않고 `deleted_at`만 기록합니다.
