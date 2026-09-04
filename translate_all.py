import os

translations = {
    "A minimalist URL shortener that resolves instantly and logs analytics in real time.": {
        "de": "Ein minimalistischer URL-Shortener, der sofort auflöst und Analysen in Echtzeit protokolliert.",
        "fr": "Un raccourcisseur d'URL minimaliste qui se résout instantanément et enregistre les analyses en temps réel.",
        "it": "Un accorciatore di URL minimalista che si risolve istantaneamente e registra le analisi in tempo reale.",
        "es": "Un acortador de URL minimalista que se resuelve al instante y registra análisis en tiempo real.",
        "ar": "مختصر روابط بسيط يعمل على الفور ويسجل التحليلات في الوقت الفعلي."
    },
    "Actions": {
        "de": "Aktionen", "fr": "Actions", "it": "Azioni", "es": "Acciones", "ar": "إجراءات"
    },
    "Attempting to reconnect": {
        "de": "Verbindungsversuch", "fr": "Tentative de reconnexion", "it": "Tentativo di riconnessione", "es": "Intentando reconectar", "ar": "محاولة إعادة الاتصال"
    },
    "Custom Alias (optional)": {
        "de": "Benutzerdefinierter Alias (optional)", "fr": "Alias personnalisé (optionnel)", "it": "Alias personalizzato (opzionale)", "es": "Alias personalizado (opcional)", "ar": "اسم مستعار مخصص (اختياري)"
    },
    "Error!": {
        "de": "Fehler!", "fr": "Erreur !", "it": "Errore!", "es": "¡Error!", "ar": "خطأ!"
    },
    "Hang in there while we get back on track": {
        "de": "Halten Sie durch, während wir uns wieder auf den Weg machen", "fr": "Tenez bon pendant que nous nous remettons sur la bonne voie", "it": "Tieni duro mentre torniamo in carreggiata", "es": "Aguanta mientras volvemos a la normalidad", "ar": "تحلى بالصبر بينما نعود إلى المسار الصحيح"
    },
    "Long URL": {
        "de": "Lange URL", "fr": "URL longue", "it": "URL lungo", "es": "URL larga", "ar": "رابط طويل"
    },
    "Shorten URL": {
        "de": "URL kürzen", "fr": "Raccourcir l'URL", "it": "Accorcia URL", "es": "Acortar URL", "ar": "اختصار الرابط"
    },
    "Shorten your links": {
        "de": "Kürzen Sie Ihre Links", "fr": "Raccourcissez vos liens", "it": "Accorcia i tuoi link", "es": "Acorta tus enlaces", "ar": "اختصر روابطك"
    },
    "Something went wrong!": {
        "de": "Etwas ist schief gelaufen!", "fr": "Quelque chose a mal tourné !", "it": "Qualcosa è andato storto!", "es": "¡Algo salió mal!", "ar": "حدث خطأ ما!"
    },
    "Success!": {
        "de": "Erfolg!", "fr": "Succès !", "it": "Successo!", "es": "¡Éxito!", "ar": "نجاح!"
    },
    "We can't find the internet": {
        "de": "Wir können das Internet nicht finden", "fr": "Nous ne pouvons pas trouver internet", "it": "Non riusciamo a trovare internet", "es": "No podemos encontrar internet", "ar": "لا يمكننا العثور على الإنترنت"
    },
    "close": {
        "de": "schließen", "fr": "fermer", "it": "chiudi", "es": "cerrar", "ar": "إغلاق"
    },
    "Choose your language:": {
        "de": "Wählen Sie Ihre Sprache:", "fr": "Choisissez votre langue :", "it": "Scegli la tua lingua:", "es": "Elige tu idioma:", "ar": "اختر لغتك:"
    },
    "%{browser} on %{os}": {
        "de": "%{browser} auf %{os}", "fr": "%{browser} sur %{os}", "it": "%{browser} su %{os}", "es": "%{browser} en %{os}", "ar": "%{browser} على %{os}"
    },
    "%{count} clicks • Created %{time} ago": {
        "de": "%{count} Klicks • Erstellt vor %{time}", "fr": "%{count} clics • Créé il y a %{time}", "it": "%{count} clic • Creato %{time} fa", "es": "%{count} clics • Creado hace %{time}", "ar": "%{count} نقرات • تم الإنشاء منذ %{time}"
    },
    "%{count} links remaining this session": {
        "de": "%{count} Links in dieser Sitzung verbleibend", "fr": "%{count} liens restants pour cette session", "it": "%{count} link rimanenti in questa sessione", "es": "%{count} enlaces restantes en esta sesión", "ar": "%{count} روابط متبقية في هذه الجلسة"
    },
    "%{time} ago": {
        "de": "vor %{time}", "fr": "il y a %{time}", "it": "%{time} fa", "es": "hace %{time}", "ar": "منذ %{time}"
    },
    "Active Visitors (5m)": {
        "de": "Aktive Besucher (5m)", "fr": "Visiteurs actifs (5m)", "it": "Visitatori attivi (5m)", "es": "Visitantes activos (5m)", "ar": "الزوار النشطون (5 دقائق)"
    },
    "Back to Dashboard": {
        "de": "Zurück zum Dashboard", "fr": "Retour au tableau de bord", "it": "Torna alla Dashboard", "es": "Volver al Dashboard", "ar": "العودة إلى لوحة القيادة"
    },
    "Browsers": {
        "de": "Browser", "fr": "Navigateurs", "it": "Browser", "es": "Navegadores", "ar": "المتصفحات"
    },
    "Click on /%{code}": {
        "de": "Klick auf /%{code}", "fr": "Clic sur /%{code}", "it": "Clic su /%{code}", "es": "Clic en /%{code}", "ar": "نقرة على /%{code}"
    },
    "Clicks": {
        "de": "Klicks", "fr": "Clics", "it": "Clic", "es": "Clics", "ar": "النقرات"
    },
    "Copy": {
        "de": "Kopieren", "fr": "Copier", "it": "Copia", "es": "Copiar", "ar": "نسخ"
    },
    "Copy to Clipboard": {
        "de": "In die Zwischenablage kopieren", "fr": "Copier dans le presse-papiers", "it": "Copia negli appunti", "es": "Copiar al portapapeles", "ar": "نسخ إلى الحافظة"
    },
    "Create Free Account": {
        "de": "Kostenloses Konto erstellen", "fr": "Créer un compte gratuit", "it": "Crea un account gratuito", "es": "Crear cuenta gratuita", "ar": "إنشاء حساب مجاني"
    },
    "Created %{time} ago": {
        "de": "Erstellt vor %{time}", "fr": "Créé il y a %{time}", "it": "Creato %{time} fa", "es": "Creado hace %{time}", "ar": "تم الإنشاء منذ %{time}"
    },
    "Creating Links Anonymously": {
        "de": "Links anonym erstellen", "fr": "Création de liens de manière anonyme", "it": "Creazione di link in modo anonimo", "es": "Creando enlaces de forma anónima", "ar": "إنشاء روابط بشكل مجهول"
    },
    "Details": {
        "de": "Details", "fr": "Détails", "it": "Dettagli", "es": "Detalles", "ar": "تفاصيل"
    },
    "Devices": {
        "de": "Geräte", "fr": "Appareils", "it": "Dispositivi", "es": "Dispositivos", "ar": "الأجهزة"
    },
    "Devices & Operating Systems": {
        "de": "Geräte & Betriebssysteme", "fr": "Appareils et systèmes d'exploitation", "it": "Dispositivi e sistemi operativi", "es": "Dispositivos y sistemas operativos", "ar": "الأجهزة وأنظمة التشغيل"
    },
    "Expires: %{time}": {
        "de": "Läuft ab: %{time}", "fr": "Expire : %{time}", "it": "Scade: %{time}", "es": "Expira: %{time}", "ar": "ينتهي: %{time}"
    },
    "Export CSV": {
        "de": "CSV exportieren", "fr": "Exporter en CSV", "it": "Esporta CSV", "es": "Exportar CSV", "ar": "تصدير CSV"
    },
    "Geographic Locations": {
        "de": "Geografische Standorte", "fr": "Emplacements géographiques", "it": "Posizioni geografiche", "es": "Ubicaciones geográficas", "ar": "المواقع الجغرافية"
    },
    "Go to Dashboard": {
        "de": "Zum Dashboard", "fr": "Aller au tableau de bord", "it": "Vai alla Dashboard", "es": "Ir al Dashboard", "ar": "الذهاب إلى لوحة القيادة"
    },
    "Live Click Stream": {
        "de": "Live-Klick-Stream", "fr": "Flux de clics en direct", "it": "Flusso di clic dal vivo", "es": "Flujo de clics en vivo", "ar": "بث النقرات المباشر"
    },
    "Log Out": {
        "de": "Abmelden", "fr": "Se déconnecter", "it": "Disconnetti", "es": "Cerrar sesión", "ar": "تسجيل الخروج"
    },
    "Log in": {
        "de": "Einloggen", "fr": "Se connecter", "it": "Accedi", "es": "Iniciar sesión", "ar": "تسجيل الدخول"
    },
    "Log out": {
        "de": "Ausloggen", "fr": "Déconnexion", "it": "Esci", "es": "Cerrar sesión", "ar": "تسجيل خروج"
    },
    "Logged in as %{email} • Live stream enabled": {
        "de": "Angemeldet als %{email} • Live-Stream aktiviert", "fr": "Connecté en tant que %{email} • Flux en direct activé", "it": "Accesso effettuato come %{email} • Streaming dal vivo abilitato", "es": "Inició sesión como %{email} • Transmisión en vivo habilitada", "ar": "تم تسجيل الدخول كـ %{email} • تم تمكين البث المباشر"
    },
    "No browser data yet.": {
        "de": "Noch keine Browser-Daten.", "fr": "Aucune donnée de navigateur pour le moment.", "it": "Ancora nessun dato del browser.", "es": "Aún no hay datos del navegador.", "ar": "لا توجد بيانات متصفح بعد."
    },
    "No data.": {
        "de": "Keine Daten.", "fr": "Aucune donnée.", "it": "Nessun dato.", "es": "Sin datos.", "ar": "لايوجد بيانات."
    },
    "No links created yet.": {
        "de": "Noch keine Links erstellt.", "fr": "Aucun lien créé pour le moment.", "it": "Ancora nessun link creato.", "es": "Aún no se han creado enlaces.", "ar": "لم يتم إنشاء روابط بعد."
    },
    "No links created yet. Create your first shortened URL above!": {
        "de": "Noch keine Links erstellt. Erstellen Sie oben Ihre erste gekürzte URL!", "fr": "Aucun lien créé pour le moment. Créez votre première URL raccourcie ci-dessus !", "it": "Ancora nessun link creato. Crea il tuo primo URL accorciato qui sopra!", "es": "Aún no hay enlaces creados. ¡Crea tu primera URL acortada arriba!", "ar": "لم يتم إنشاء روابط بعد. قم بإنشاء أول رابط مختصر لك أعلاه!"
    },
    "No location data yet.": {
        "de": "Noch keine Standortdaten.", "fr": "Aucune donnée de localisation pour le moment.", "it": "Ancora nessun dato sulla posizione.", "es": "Aún no hay datos de ubicación.", "ar": "لا توجد بيانات موقع بعد."
    },
    "No referrer data yet.": {
        "de": "Noch keine Verweisdaten.", "fr": "Aucune donnée de parrain pour le moment.", "it": "Ancora nessun dato sui referrer.", "es": "Aún no hay datos de referencias.", "ar": "لا توجد بيانات مصدر بعد."
    },
    "OS": {
        "de": "Betriebssystem", "fr": "OS", "it": "SO", "es": "SO", "ar": "نظام التشغيل"
    },
    "Original URL": {
        "de": "Ursprüngliche URL", "fr": "URL d'origine", "it": "URL originale", "es": "URL original", "ar": "الرابط الأصلي"
    },
    "Real-time analytics": {
        "de": "Echtzeitanalysen", "fr": "Analyses en temps réel", "it": "Analisi in tempo reale", "es": "Análisis en tiempo real", "ar": "تحليلات في الوقت الفعلي"
    },
    "Register": {
        "de": "Registrieren", "fr": "S'inscrire", "it": "Registrati", "es": "Registrarse", "ar": "تسجيل"
    },
    "Settings": {
        "de": "Einstellungen", "fr": "Paramètres", "it": "Impostazioni", "es": "Configuración", "ar": "إعدادات"
    },
    "Short Code": {
        "de": "Kurzcode", "fr": "Code court", "it": "Codice corto", "es": "Código corto", "ar": "رمز قصير"
    },
    "Short URL:": {
        "de": "Kurze URL:", "fr": "URL courte :", "it": "URL corto:", "es": "URL corta:", "ar": "رابط قصير:"
    },
    "Shorten New URL": {
        "de": "Neue URL kürzen", "fr": "Raccourcir une nouvelle URL", "it": "Accorcia nuovo URL", "es": "Acortar nueva URL", "ar": "اختصار رابط جديد"
    },
    "Shorten your first URL": {
        "de": "Kürzen Sie Ihre erste URL", "fr": "Raccourcissez votre première URL", "it": "Accorcia il tuo primo URL", "es": "Acorta tu primera URL", "ar": "اختصر رابطك الأول"
    },
    "Sign In": {
        "de": "Anmelden", "fr": "Se connecter", "it": "Accedi", "es": "Iniciar sesión", "ar": "تسجيل الدخول"
    },
    "Sign Up Free": {
        "de": "Kostenlos anmelden", "fr": "Inscrivez-vous gratuitement", "it": "Iscriviti gratis", "es": "Regístrate gratis", "ar": "سجل مجانا"
    },
    "Signed in as %{email}": {
        "de": "Angemeldet als %{email}", "fr": "Connecté en tant que %{email}", "it": "Accesso effettuato come %{email}", "es": "Inició sesión como %{email}", "ar": "تم تسجيل الدخول كـ %{email}"
    },
    "Temporary session links • Live stream enabled": {
        "de": "Temporäre Sitzungslinks • Live-Stream aktiviert", "fr": "Liens de session temporaires • Flux en direct activé", "it": "Link di sessione temporanei • Streaming dal vivo abilitato", "es": "Enlaces de sesión temporal • Transmisión en vivo habilitada", "ar": "روابط جلسة مؤقتة • تم تمكين البث المباشر"
    },
    "Total Clicks": {
        "de": "Gesamtklicks", "fr": "Total des clics", "it": "Clic totali", "es": "Clics totales", "ar": "إجمالي النقرات"
    },
    "Total Links": {
        "de": "Gesamtlinks", "fr": "Total des liens", "it": "Link totali", "es": "Enlaces totales", "ar": "إجمالي الروابط"
    },
    "Traffic Sources": {
        "de": "Traffic-Quellen", "fr": "Sources de trafic", "it": "Fonti di traffico", "es": "Fuentes de tráfico", "ar": "مصادر الزيارات"
    },
    "Unique Visitors (IPs)": {
        "de": "Eindeutige Besucher (IPs)", "fr": "Visiteurs uniques (IP)", "it": "Visitatori unici (IP)", "es": "Visitantes únicos (IP)", "ar": "زوار فريدون (عناوين IP)"
    },
    "Unlimited links available": {
        "de": "Unbegrenzte Links verfügbar", "fr": "Liens illimités disponibles", "it": "Link illimitati disponibili", "es": "Enlaces ilimitados disponibles", "ar": "روابط غير محدودة متاحة"
    },
    "Unlock More Features": {
        "de": "Mehr Funktionen freischalten", "fr": "Débloquez plus de fonctionnalités", "it": "Sblocca altre funzionalità", "es": "Desbloquear más funciones", "ar": "افتح المزيد من الميزات"
    },
    "View Analytics": {
        "de": "Analysen ansehen", "fr": "Voir les analyses", "it": "Visualizza Analisi", "es": "Ver analíticas", "ar": "عرض التحليلات"
    },
    "View Analytics →": {
        "de": "Analysen ansehen →", "fr": "Voir les analyses →", "it": "Visualizza Analisi →", "es": "Ver analíticas →", "ar": "عرض التحليلات →"
    },
    "Waiting for clicks... share your links to watch live traffic stream in.": {
        "de": "Warten auf Klicks... Teilen Sie Ihre Links, um Live-Traffic zu beobachten.", "fr": "En attente de clics... partagez vos liens pour voir le trafic affluer en direct.", "it": "In attesa di clic... condividi i tuoi link per guardare il traffico dal vivo in arrivo.", "es": "Esperando clics... comparte tus enlaces para ver la transmisión de tráfico en vivo.", "ar": "في انتظار النقرات... شارك روابطك لمشاهدة بث الزيارات المباشر."
    },
    "Your Recent Links": {
        "de": "Ihre aktuellen Links", "fr": "Vos liens récents", "it": "I tuoi link recenti", "es": "Tus enlaces recientes", "ar": "روابطك الأخيرة"
    },
    "Your Shortened Links": {
        "de": "Ihre gekürzten Links", "fr": "Vos liens raccourcis", "it": "I tuoi link accorciati", "es": "Tus enlaces acortados", "ar": "روابطك المختصرة"
    },
    "Your Shortened URL": {
        "de": "Ihre gekürzte URL", "fr": "Votre URL raccourcie", "it": "Il tuo URL accorciato", "es": "Tu URL acortada", "ar": "رابطك المختصر"
    },
    "to see analytics.": {
        "de": "um Analysen zu sehen.", "fr": "pour voir les analyses.", "it": "per vedere le analisi.", "es": "para ver analíticas.", "ar": "لرؤية التحليلات."
    }
}

for lang in ["de", "fr", "it", "es", "ar"]:
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
