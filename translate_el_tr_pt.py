import os

translations = {
    "A minimalist URL shortener that resolves instantly and logs analytics in real time.": {
        "el": "Ένα μινιμαλιστικό εργαλείο συντόμευσης URL που επιλύεται άμεσα και καταγράφει αναλυτικά στοιχεία σε πραγματικό χρόνο.",
        "tr": "Anında çözümlenen ve gerçek zamanlı analizleri kaydeden minimalist bir URL kısaltıcı.",
        "pt": "Um encurtador de URL minimalista que resolve instantaneamente e registra análises em tempo real."
    },
    "Actions": {
        "el": "Ενέργειες", "tr": "İşlemler", "pt": "Ações"
    },
    "Attempting to reconnect": {
        "el": "Προσπάθεια επανασύνδεσης", "tr": "Yeniden bağlanmaya çalışılıyor", "pt": "Tentando reconectar"
    },
    "Custom Alias (optional)": {
        "el": "Προσαρμοσμένο ψευδώνυμο (προαιρετικό)", "tr": "Özel Kısaltma (isteğe bağlı)", "pt": "Alias personalizado (opcional)"
    },
    "Error!": {
        "el": "Σφάλμα!", "tr": "Hata!", "pt": "Erro!"
    },
    "Hang in there while we get back on track": {
        "el": "Κάντε υπομονή μέχρι να επανέλθουμε", "tr": "İşleri yoluna koyarken lütfen bekleyin", "pt": "Aguarde enquanto voltamos aos trilhos"
    },
    "Long URL": {
        "el": "Μεγάλο URL", "tr": "Uzun URL", "pt": "URL longo"
    },
    "Shorten URL": {
        "el": "Συντόμευση URL", "tr": "URL Kısalt", "pt": "Encurtar URL"
    },
    "Shorten your links": {
        "el": "Συντομεύστε τους συνδέσμους σας", "tr": "Bağlantılarınızı kısaltın", "pt": "Encurte seus links"
    },
    "Something went wrong!": {
        "el": "Κάτι πήγε στραβά!", "tr": "Bir şeyler ters gitti!", "pt": "Algo deu errado!"
    },
    "Success!": {
        "el": "Επιτυχία!", "tr": "Başarılı!", "pt": "Sucesso!"
    },
    "We can't find the internet": {
        "el": "Δεν μπορούμε να βρούμε το διαδίκτυο", "tr": "İnternet bulunamıyor", "pt": "Não conseguimos encontrar a internet"
    },
    "close": {
        "el": "κλείσιμο", "tr": "kapat", "pt": "fechar"
    },
    "Choose your language:": {
        "el": "Επιλέξτε τη γλώσσα σας:", "tr": "Dilinizi seçin:", "pt": "Escolha seu idioma:"
    },
    "%{browser} on %{os}": {
        "el": "%{browser} σε %{os}", "tr": "%{os} üzerinde %{browser}", "pt": "%{browser} no %{os}"
    },
    "%{count} clicks • Created %{time} ago": {
        "el": "%{count} κλικ • Δημιουργήθηκε πριν από %{time}", "tr": "%{count} tıklama • %{time} önce oluşturuldu", "pt": "%{count} cliques • Criado há %{time}"
    },
    "%{count} links remaining this session": {
        "el": "Απομένουν %{count} σύνδεσμοι σε αυτήν τη συνεδρία", "tr": "Bu oturumda kalan %{count} bağlantı", "pt": "%{count} links restantes nesta sessão"
    },
    "%{time} ago": {
        "el": "πριν από %{time}", "tr": "%{time} önce", "pt": "há %{time}"
    },
    "Active Visitors (5m)": {
        "el": "Ενεργοί Επισκέπτες (5λ)", "tr": "Aktif Ziyaretçiler (5dk)", "pt": "Visitantes Ativos (5m)"
    },
    "Back to Dashboard": {
        "el": "Επιστροφή στον Πίνακα Ελέγχου", "tr": "Kontrol Paneline Dön", "pt": "Voltar ao Dashboard"
    },
    "Browsers": {
        "el": "Προγράμματα περιήγησης", "tr": "Tarayıcılar", "pt": "Navegadores"
    },
    "Click on /%{code}": {
        "el": "Κλικ στο /%{code}", "tr": "/%{code} tıklandı", "pt": "Clique em /%{code}"
    },
    "Clicks": {
        "el": "Κλικ", "tr": "Tıklamalar", "pt": "Cliques"
    },
    "Copy": {
        "el": "Αντιγραφή", "tr": "Kopyala", "pt": "Copiar"
    },
    "Copy to Clipboard": {
        "el": "Αντιγραφή στο πρόχειρο", "tr": "Panoya Kopyala", "pt": "Copiar para a Área de Transferência"
    },
    "Create Free Account": {
        "el": "Δημιουργία Δωρεάν Λογαριασμού", "tr": "Ücretsiz Hesap Oluştur", "pt": "Criar Conta Grátis"
    },
    "Created %{time} ago": {
        "el": "Δημιουργήθηκε πριν από %{time}", "tr": "%{time} önce oluşturuldu", "pt": "Criado há %{time}"
    },
    "Creating Links Anonymously": {
        "el": "Ανώνυμη Δημιουργία Συνδέσμων", "tr": "Anonim Olarak Bağlantı Oluşturuluyor", "pt": "Criando Links Anonimamente"
    },
    "Details": {
        "el": "Λεπτομέρειες", "tr": "Detaylar", "pt": "Detalhes"
    },
    "Devices": {
        "el": "Συσκευές", "tr": "Cihazlar", "pt": "Dispositivos"
    },
    "Devices & Operating Systems": {
        "el": "Συσκευές & Λειτουργικά Συστήματα", "tr": "Cihazlar ve İşletim Sistemleri", "pt": "Dispositivos e Sistemas Operacionais"
    },
    "Expires: %{time}": {
        "el": "Λήγει: %{time}", "tr": "Bitiş Tarihi: %{time}", "pt": "Expira: %{time}"
    },
    "Export CSV": {
        "el": "Εξαγωγή CSV", "tr": "CSV Dışa Aktar", "pt": "Exportar CSV"
    },
    "Geographic Locations": {
        "el": "Γεωγραφικές Τοποθεσίες", "tr": "Coğrafi Konumlar", "pt": "Localizações Geográficas"
    },
    "Go to Dashboard": {
        "el": "Μετάβαση στον Πίνακα Ελέγχου", "tr": "Kontrol Paneline Git", "pt": "Ir para o Dashboard"
    },
    "Live Click Stream": {
        "el": "Ζωντανή Ροή Κλικ", "tr": "Canlı Tıklama Akışı", "pt": "Fluxo de Cliques ao Vivo"
    },
    "Log Out": {
        "el": "Αποσύνδεση", "tr": "Çıkış Yap", "pt": "Sair"
    },
    "Log in": {
        "el": "Σύνδεση", "tr": "Giriş Yap", "pt": "Entrar"
    },
    "Log out": {
        "el": "Αποσύνδεση", "tr": "Çıkış yap", "pt": "Sair"
    },
    "Logged in as %{email} • Live stream enabled": {
        "el": "Συνδεδεμένος ως %{email} • Η ζωντανή ροή ενεργοποιήθηκε", "tr": "%{email} olarak giriş yapıldı • Canlı yayın etkin", "pt": "Logado como %{email} • Fluxo ao vivo ativado"
    },
    "No browser data yet.": {
        "el": "Δεν υπάρχουν δεδομένα προγράμματος περιήγησης ακόμα.", "tr": "Henüz tarayıcı verisi yok.", "pt": "Sem dados de navegador ainda."
    },
    "No data.": {
        "el": "Δεν υπάρχουν δεδομένα.", "tr": "Veri yok.", "pt": "Sem dados."
    },
    "No links created yet.": {
        "el": "Δεν έχουν δημιουργηθεί συνδέσμοι ακόμα.", "tr": "Henüz bağlantı oluşturulmadı.", "pt": "Nenhum link criado ainda."
    },
    "No links created yet. Create your first shortened URL above!": {
        "el": "Δεν έχουν δημιουργηθεί συνδέσμοι ακόμα. Δημιουργήστε το πρώτο σας συντομευμένο URL παραπάνω!", "tr": "Henüz bağlantı oluşturulmadı. Yukarıdan ilk kısa URL'nizi oluşturun!", "pt": "Nenhum link criado ainda. Crie seu primeiro URL encurtado acima!"
    },
    "No location data yet.": {
        "el": "Δεν υπάρχουν δεδομένα τοποθεσίας ακόμα.", "tr": "Henüz konum verisi yok.", "pt": "Sem dados de localização ainda."
    },
    "No referrer data yet.": {
        "el": "Δεν υπάρχουν δεδομένα παραπομπής ακόμα.", "tr": "Henüz yönlendiren verisi yok.", "pt": "Sem dados de referência ainda."
    },
    "OS": {
        "el": "Λειτουργικό Σύστημα", "tr": "İşletim Sistemi", "pt": "SO"
    },
    "Original URL": {
        "el": "Αρχικό URL", "tr": "Orijinal URL", "pt": "URL Original"
    },
    "Real-time analytics": {
        "el": "Αναλυτικά στοιχεία σε πραγματικό χρόνο", "tr": "Gerçek zamanlı analiz", "pt": "Análises em tempo real"
    },
    "Register": {
        "el": "Εγγραφή", "tr": "Kayıt Ol", "pt": "Registrar-se"
    },
    "Settings": {
        "el": "Ρυθμίσεις", "tr": "Ayarlar", "pt": "Configurações"
    },
    "Short Code": {
        "el": "Σύντομος Κωδικός", "tr": "Kısa Kod", "pt": "Código Curto"
    },
    "Short URL:": {
        "el": "Σύντομο URL:", "tr": "Kısa URL:", "pt": "URL Curto:"
    },
    "Shorten New URL": {
        "el": "Συντόμευση Νέου URL", "tr": "Yeni URL Kısalt", "pt": "Encurtar Novo URL"
    },
    "Shorten your first URL": {
        "el": "Συντομεύστε το πρώτο σας URL", "tr": "İlk URL'nizi kısaltın", "pt": "Encurte seu primeiro URL"
    },
    "Sign In": {
        "el": "Σύνδεση", "tr": "Giriş Yap", "pt": "Entrar"
    },
    "Sign Up Free": {
        "el": "Δωρεάν Εγγραφή", "tr": "Ücretsiz Kayıt Ol", "pt": "Inscreva-se Grátis"
    },
    "Signed in as %{email}": {
        "el": "Συνδεδεμένος ως %{email}", "tr": "%{email} olarak giriş yapıldı", "pt": "Logado como %{email}"
    },
    "Temporary session links • Live stream enabled": {
        "el": "Σύνδεσμοι προσωρινής συνεδρίας • Η ζωντανή ροή ενεργοποιήθηκε", "tr": "Geçici oturum bağlantıları • Canlı akış etkin", "pt": "Links de sessão temporária • Fluxo ao vivo ativado"
    },
    "Total Clicks": {
        "el": "Συνολικά Κλικ", "tr": "Toplam Tıklama", "pt": "Total de Cliques"
    },
    "Total Links": {
        "el": "Συνολικοί Σύνδεσμοι", "tr": "Toplam Bağlantı", "pt": "Total de Links"
    },
    "Traffic Sources": {
        "el": "Πηγές Επισκεψιμότητας", "tr": "Trafik Kaynakları", "pt": "Fontes de Tráfego"
    },
    "Unique Visitors (IPs)": {
        "el": "Μοναδικοί Επισκέπτες (IP)", "tr": "Tekil Ziyaretçiler (IP'ler)", "pt": "Visitantes Únicos (IPs)"
    },
    "Unlimited links available": {
        "el": "Απεριόριστοι σύνδεσμοι διαθέσιμοι", "tr": "Sınırsız bağlantı mevcut", "pt": "Links ilimitados disponíveis"
    },
    "Unlock More Features": {
        "el": "Ξεκλείδωμα Περισσότερων Δυνατοτήτων", "tr": "Daha Fazla Özelliği Aç", "pt": "Desbloquear Mais Recursos"
    },
    "View Analytics": {
        "el": "Προβολή Αναλυτικών Στοιχείων", "tr": "Analizleri Görüntüle", "pt": "Ver Análises"
    },
    "View Analytics →": {
        "el": "Προβολή Αναλυτικών Στοιχείων →", "tr": "Analizleri Görüntüle →", "pt": "Ver Análises →"
    },
    "Waiting for clicks... share your links to watch live traffic stream in.": {
        "el": "Αναμονή για κλικ... μοιραστείτε τους συνδέσμους σας για να παρακολουθήσετε τη ζωντανή ροή επισκεψιμότητας.", "tr": "Tıklamalar bekleniyor... canlı trafik akışını izlemek için bağlantılarınızı paylaşın.", "pt": "Aguardando cliques... compartilhe seus links para assistir ao fluxo de tráfego ao vivo."
    },
    "Your Recent Links": {
        "el": "Οι Πρόσφατοι Σύνδεσμοί Σας", "tr": "Son Bağlantılarınız", "pt": "Seus Links Recentes"
    },
    "Your Shortened Links": {
        "el": "Οι Συντομευμένοι Σύνδεσμοί Σας", "tr": "Kısaltılmış Bağlantılarınız", "pt": "Seus Links Encurtados"
    },
    "Your Shortened URL": {
        "el": "Το Συντομευμένο URL σας", "tr": "Kısaltılmış URL'niz", "pt": "Seu URL Encurtado"
    },
    "to see analytics.": {
        "el": "για να δείτε αναλυτικά στοιχεία.", "tr": "analizleri görmek için.", "pt": "para ver análises."
    }
}

for lang in ["el", "tr", "pt"]:
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
