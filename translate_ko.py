import os

translations = {
    "A minimalist URL shortener that resolves instantly and logs analytics in real time.": "즉시 해결되고 실시간으로 분석을 기록하는 미니멀한 URL 단축기입니다.",
    "Actions": "작업",
    "Attempting to reconnect": "재연결 시도 중",
    "Custom Alias (optional)": "사용자 지정 별칭 (선택 사항)",
    "Error!": "오류!",
    "Hang in there while we get back on track": "정상화될 때까지 잠시 기다려 주세요",
    "Long URL": "긴 URL",
    "Shorten URL": "URL 단축",
    "Shorten your links": "링크를 단축하세요",
    "Something went wrong!": "문제가 발생했습니다!",
    "Success!": "성공!",
    "We can't find the internet": "인터넷을 찾을 수 없습니다",
    "close": "닫기",
    "Choose your language:": "언어를 선택하세요:",
    "%{browser} on %{os}": "%{os}의 %{browser}",
    "%{count} clicks • Created %{time} ago": "조회수 %{count}회 • %{time} 전에 생성됨",
    "%{count} links remaining this session": "이번 세션에 남은 링크: %{count}개",
    "%{time} ago": "%{time} 전",
    "Active Visitors (5m)": "활성 방문자 (5분)",
    "Back to Dashboard": "대시보드로 돌아가기",
    "Browsers": "브라우저",
    "Click on /%{code}": "/%{code} 클릭",
    "Clicks": "클릭",
    "Copy": "복사",
    "Copy to Clipboard": "클립보드에 복사",
    "Create Free Account": "무료 계정 만들기",
    "Created %{time} ago": "%{time} 전에 생성됨",
    "Creating Links Anonymously": "익명으로 링크 생성 중",
    "Details": "세부 정보",
    "Devices": "기기",
    "Devices & Operating Systems": "기기 및 운영 체제",
    "Expires: %{time}": "만료일: %{time}",
    "Export CSV": "CSV 내보내기",
    "Geographic Locations": "지리적 위치",
    "Go to Dashboard": "대시보드로 이동",
    "Live Click Stream": "실시간 클릭 스트림",
    "Log Out": "로그아웃",
    "Log in": "로그인",
    "Log out": "로그아웃",
    "Logged in as %{email} • Live stream enabled": "%{email}님으로 로그인됨 • 라이브 스트림 활성화됨",
    "No browser data yet.": "아직 브라우저 데이터가 없습니다.",
    "No data.": "데이터가 없습니다.",
    "No links created yet.": "아직 생성된 링크가 없습니다.",
    "No links created yet. Create your first shortened URL above!": "아직 생성된 링크가 없습니다. 위에서 첫 번째 단축 URL을 만들어 보세요!",
    "No location data yet.": "아직 위치 데이터가 없습니다.",
    "No referrer data yet.": "아직 리퍼러 데이터가 없습니다.",
    "OS": "운영 체제",
    "Original URL": "원래 URL",
    "Real-time analytics": "실시간 분석",
    "Register": "가입하기",
    "Settings": "설정",
    "Short Code": "단축 코드",
    "Short URL:": "단축 URL:",
    "Shorten New URL": "새 URL 단축하기",
    "Shorten your first URL": "첫 번째 URL을 단축하세요",
    "Sign In": "로그인",
    "Sign Up Free": "무료로 가입하기",
    "Signed in as %{email}": "%{email}님으로 로그인됨",
    "Temporary session links • Live stream enabled": "임시 세션 링크 • 라이브 스트림 활성화됨",
    "Total Clicks": "총 클릭수",
    "Total Links": "총 링크수",
    "Traffic Sources": "트래픽 소스",
    "Unique Visitors (IPs)": "고유 방문자 (IP)",
    "Unlimited links available": "무제한 링크 사용 가능",
    "Unlock More Features": "더 많은 기능 잠금 해제",
    "View Analytics": "분석 보기",
    "View Analytics →": "분석 보기 →",
    "Waiting for clicks... share your links to watch live traffic stream in.": "클릭을 기다리는 중... 라이브 트래픽 스트림을 보려면 링크를 공유하세요.",
    "Your Recent Links": "최근 링크",
    "Your Shortened Links": "단축된 링크",
    "Your Shortened URL": "단축된 URL",
    "to see analytics.": "분석을 확인하세요."
}

path = "priv/gettext/ko/LC_MESSAGES/default.po"
with open(path, "r") as f:
    content = f.read()

for en, translated in translations.items():
    old_str = f'msgid "{en}"\nmsgstr ""'
    new_str = f'msgid "{en}"\nmsgstr "{translated}"'
    content = content.replace(old_str, new_str)
        
with open(path, "w") as f:
    f.write(content)
print("Updated ko")
