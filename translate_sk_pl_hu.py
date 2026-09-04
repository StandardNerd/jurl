import os

translations = {
    "A minimalist URL shortener that resolves instantly and logs analytics in real time.": {
        "sk": "Minimalistický skracovač URL, ktorý rieši okamžite a zaznamenáva analýzy v reálnom čase.",
        "pl": "Minimalistyczny skracacz URL, który rozwiązuje natychmiastowo i rejestruje analitykę w czasie rzeczywistym.",
        "hu": "Minimalista URL-rövidítő, amely azonnal feloldódik és valós időben rögzíti az elemzéseket."
    },
    "Actions": {
        "sk": "Akcie", "pl": "Akcje", "hu": "Műveletek"
    },
    "Attempting to reconnect": {
        "sk": "Pokus o opätovné pripojenie", "pl": "Próba ponownego połączenia", "hu": "Újracsatlakozás megkísérlése"
    },
    "Custom Alias (optional)": {
        "sk": "Vlastný alias (voliteľné)", "pl": "Niestandardowy alias (opcjonalnie)", "hu": "Egyedi álnév (opcionális)"
    },
    "Error!": {
        "sk": "Chyba!", "pl": "Błąd!", "hu": "Hiba!"
    },
    "Hang in there while we get back on track": {
        "sk": "Vydržte, kým sa vrátime na správnu cestu", "pl": "Trzymaj się, póki nie wrócimy na właściwe tory", "hu": "Tarts ki, amíg újra sínre kerülünk"
    },
    "Long URL": {
        "sk": "Dlhá URL", "pl": "Długi URL", "hu": "Hosszú URL"
    },
    "Shorten URL": {
        "sk": "Skrátiť URL", "pl": "Skróć URL", "hu": "URL rövidítése"
    },
    "Shorten your links": {
        "sk": "Skráťte svoje odkazy", "pl": "Skróć swoje linki", "hu": "Rövidítse le linkjeit"
    },
    "Something went wrong!": {
        "sk": "Niečo sa pokazilo!", "pl": "Coś poszło nie tak!", "hu": "Valami elromlott!"
    },
    "Success!": {
        "sk": "Úspech!", "pl": "Sukces!", "hu": "Siker!"
    },
    "We can't find the internet": {
        "sk": "Nemôžeme nájsť internet", "pl": "Nie możemy znaleźć internetu", "hu": "Nem találjuk az internetet"
    },
    "close": {
        "sk": "Zavrieť", "pl": "zamknij", "hu": "bezárás"
    },
    "Choose your language:": {
        "sk": "Vyberte svoj jazyk:", "pl": "Wybierz swój język:", "hu": "Válassza ki a nyelvét:"
    },
    "%{browser} on %{os}": {
        "sk": "%{browser} na %{os}", "pl": "%{browser} w %{os}", "hu": "%{browser} a(z) %{os} rendszeren"
    },
    "%{count} clicks • Created %{time} ago": {
        "sk": "%{count} kliknutí • Vytvorené pred %{time}", "pl": "%{count} kliknięć • Utworzono %{time} temu", "hu": "%{count} kattintás • Létrehozva %{time} ezelőtt"
    },
    "%{count} links remaining this session": {
        "sk": "V tejto relácii zostáva %{count} odkazov", "pl": "W tej sesji pozostało %{count} linków", "hu": "A munkamenetben %{count} link maradt"
    },
    "%{time} ago": {
        "sk": "pred %{time}", "pl": "%{time} temu", "hu": "%{time} ezelőtt"
    },
    "Active Visitors (5m)": {
        "sk": "Aktívni návštevníci (5m)", "pl": "Aktywni goście (5m)", "hu": "Aktív látogatók (5p)"
    },
    "Back to Dashboard": {
        "sk": "Späť na Dashboard", "pl": "Wróć do Dashboardu", "hu": "Vissza az Irányítópultra"
    },
    "Browsers": {
        "sk": "Prehliadače", "pl": "Przeglądarki", "hu": "Böngészők"
    },
    "Click on /%{code}": {
        "sk": "Kliknite na /%{code}", "pl": "Kliknij w /%{code}", "hu": "Kattintás a /%{code} linkre"
    },
    "Clicks": {
        "sk": "Kliknutia", "pl": "Kliknięcia", "hu": "Kattintások"
    },
    "Copy": {
        "sk": "Kopírovať", "pl": "Kopiuj", "hu": "Másolás"
    },
    "Copy to Clipboard": {
        "sk": "Kopírovať do schránky", "pl": "Kopiuj do schowka", "hu": "Vágólapra másolás"
    },
    "Create Free Account": {
        "sk": "Vytvoriť bezplatný účet", "pl": "Utwórz darmowe konto", "hu": "Ingyenes fiók létrehozása"
    },
    "Created %{time} ago": {
        "sk": "Vytvorené pred %{time}", "pl": "Utworzono %{time} temu", "hu": "Létrehozva %{time} ezelőtt"
    },
    "Creating Links Anonymously": {
        "sk": "Vytváranie odkazov anonymne", "pl": "Anonimowe tworzenie linków", "hu": "Linkek névtelen létrehozása"
    },
    "Details": {
        "sk": "Podrobnosti", "pl": "Szczegóły", "hu": "Részletek"
    },
    "Devices": {
        "sk": "Zariadenia", "pl": "Urządzenia", "hu": "Eszközök"
    },
    "Devices & Operating Systems": {
        "sk": "Zariadenia a operačné systémy", "pl": "Urządzenia i systemy operacyjne", "hu": "Eszközök és operációs rendszerek"
    },
    "Expires: %{time}": {
        "sk": "Vyprší: %{time}", "pl": "Wygasa: %{time}", "hu": "Lejárat: %{time}"
    },
    "Export CSV": {
        "sk": "Exportovať CSV", "pl": "Eksportuj CSV", "hu": "CSV exportálása"
    },
    "Geographic Locations": {
        "sk": "Geografické lokality", "pl": "Lokalizacje geograficzne", "hu": "Földrajzi helyek"
    },
    "Go to Dashboard": {
        "sk": "Prejsť na Dashboard", "pl": "Przejdź do Dashboardu", "hu": "Ugrás az Irányítópultra"
    },
    "Live Click Stream": {
        "sk": "Živý prúd kliknutí", "pl": "Strumień kliknięć na żywo", "hu": "Élő kattintás-folyam"
    },
    "Log Out": {
        "sk": "Odhlásiť sa", "pl": "Wyloguj się", "hu": "Kijelentkezés"
    },
    "Log in": {
        "sk": "Prihlásiť sa", "pl": "Zaloguj się", "hu": "Bejelentkezés"
    },
    "Log out": {
        "sk": "Odhlásiť sa", "pl": "Wyloguj", "hu": "Kijelentkezés"
    },
    "Logged in as %{email} • Live stream enabled": {
        "sk": "Prihlásený ako %{email} • Živé streamovanie povolené", "pl": "Zalogowany jako %{email} • Strumień na żywo włączony", "hu": "Bejelentkezve mint %{email} • Élő közvetítés engedélyezve"
    },
    "No browser data yet.": {
        "sk": "Zatiaľ žiadne údaje prehliadača.", "pl": "Brak danych przeglądarki.", "hu": "Még nincsenek böngészőadatok."
    },
    "No data.": {
        "sk": "Žiadne údaje.", "pl": "Brak danych.", "hu": "Nincs adat."
    },
    "No links created yet.": {
        "sk": "Zatiaľ neboli vytvorené žiadne odkazy.", "pl": "Jeszcze nie utworzono żadnych linków.", "hu": "Még nincsenek linkek létrehozva."
    },
    "No links created yet. Create your first shortened URL above!": {
        "sk": "Zatiaľ neboli vytvorené žiadne odkazy. Vytvorte si prvú skrátenú URL vyššie!", "pl": "Jeszcze nie utworzono żadnych linków. Utwórz swój pierwszy skrócony URL powyżej!", "hu": "Még nincsenek linkek létrehozva. Hozd létre az első rövidített URL-edet fent!"
    },
    "No location data yet.": {
        "sk": "Zatiaľ žiadne údaje o polohe.", "pl": "Brak danych o lokalizacji.", "hu": "Még nincsenek helyadatok."
    },
    "No referrer data yet.": {
        "sk": "Zatiaľ žiadne údaje o sprostredkovateľovi.", "pl": "Brak danych odsyłaczy.", "hu": "Még nincsenek hivatkozási adatok."
    },
    "OS": {
        "sk": "OS", "pl": "System operacyjny", "hu": "OS"
    },
    "Original URL": {
        "sk": "Pôvodná URL", "pl": "Oryginalny URL", "hu": "Eredeti URL"
    },
    "Real-time analytics": {
        "sk": "Analytika v reálnom čase", "pl": "Analityka w czasie rzeczywistym", "hu": "Valós idejű elemzés"
    },
    "Register": {
        "sk": "Registrovať sa", "pl": "Zarejestruj się", "hu": "Regisztráció"
    },
    "Settings": {
        "sk": "Nastavenia", "pl": "Ustawienia", "hu": "Beállítások"
    },
    "Short Code": {
        "sk": "Krátky kód", "pl": "Krótki kod", "hu": "Rövid kód"
    },
    "Short URL:": {
        "sk": "Krátka URL:", "pl": "Krótki URL:", "hu": "Rövid URL:"
    },
    "Shorten New URL": {
        "sk": "Skrátiť novú URL", "pl": "Skróć nowy URL", "hu": "Új URL rövidítése"
    },
    "Shorten your first URL": {
        "sk": "Skráťte svoju prvú URL", "pl": "Skróć swój pierwszy URL", "hu": "Rövidítse le az első URL-jét"
    },
    "Sign In": {
        "sk": "Prihlásiť sa", "pl": "Zaloguj się", "hu": "Bejelentkezés"
    },
    "Sign Up Free": {
        "sk": "Zaregistrovať sa zadarmo", "pl": "Zarejestruj się za darmo", "hu": "Ingyenes regisztráció"
    },
    "Signed in as %{email}": {
        "sk": "Prihlásený ako %{email}", "pl": "Zalogowany jako %{email}", "hu": "Bejelentkezve mint %{email}"
    },
    "Temporary session links • Live stream enabled": {
        "sk": "Dočasné odkazy relácie • Živý stream povolený", "pl": "Tymczasowe linki sesji • Strumień na żywo włączony", "hu": "Ideiglenes munkamenet-linkek • Élő közvetítés engedélyezve"
    },
    "Total Clicks": {
        "sk": "Celkové kliknutia", "pl": "Całkowita liczba kliknięć", "hu": "Összes kattintás"
    },
    "Total Links": {
        "sk": "Celkové odkazy", "pl": "Całkowita liczba linków", "hu": "Összes link"
    },
    "Traffic Sources": {
        "sk": "Zdroje návštevnosti", "pl": "Źródła ruchu", "hu": "Forgalom forrásai"
    },
    "Unique Visitors (IPs)": {
        "sk": "Unikátni návštevníci (IP)", "pl": "Unikalni użytkownicy (IP)", "hu": "Egyedi látogatók (IP-k)"
    },
    "Unlimited links available": {
        "sk": "K dispozícii je neobmedzený počet odkazov", "pl": "Dostępna nieograniczona liczba linków", "hu": "Korlátlan link elérhető"
    },
    "Unlock More Features": {
        "sk": "Odomknúť ďalšie funkcie", "pl": "Odblokuj więcej funkcji", "hu": "További funkciók feloldása"
    },
    "View Analytics": {
        "sk": "Zobraziť analýzu", "pl": "Zobacz analitykę", "hu": "Elemzések megtekintése"
    },
    "View Analytics →": {
        "sk": "Zobraziť analýzu →", "pl": "Zobacz analitykę →", "hu": "Elemzések megtekintése →"
    },
    "Waiting for clicks... share your links to watch live traffic stream in.": {
        "sk": "Čaká sa na kliknutia... zdieľajte svoje odkazy, aby ste mohli sledovať živý prúd návštevnosti.", "pl": "Oczekiwanie na kliknięcia... udostępnij swoje linki, aby oglądać strumień ruchu na żywo.", "hu": "Kattintásokra várva... oszd meg a linkjeidet, hogy élőben tudd nézni a forgalmat."
    },
    "Your Recent Links": {
        "sk": "Vaše nedávne odkazy", "pl": "Twoje ostatnie linki", "hu": "Legutóbbi linkjeid"
    },
    "Your Shortened Links": {
        "sk": "Vaše skrátené odkazy", "pl": "Twoje skrócone linki", "hu": "Rövidített linkjeid"
    },
    "Your Shortened URL": {
        "sk": "Vaša skrátená URL", "pl": "Twój skrócony URL", "hu": "Rövidített URL-ed"
    },
    "to see analytics.": {
        "sk": "aby ste videli analýzu.", "pl": "aby zobaczyć analitykę.", "hu": "az elemzések megtekintéséhez."
    }
}

for lang in ["sk", "pl", "hu"]:
    path = f"priv/gettext/{lang}/LC_MESSAGES/default.po"
    with open(path, "r") as f:
        content = f.read()

    for en, translated_dict in translations.items():
        translated = translated_dict.get(lang)
        if translated:
            old_str = f'msgid "{en}"\nmsgstr ""'
            new_str = f'msgid "{en}"\nmsgstr "{translated}"'
            content = content.replace(old_str, new_str)
            
    with open(path, "w") as f:
        f.write(content)
    print(f"Updated {lang}")
