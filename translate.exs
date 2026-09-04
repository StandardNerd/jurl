defmodule Translator do
  @translations %{
    "de" => %{
      "Shorten your links" => "Kürzen Sie Ihre Links",
      "A minimalist URL shortener." => "Ein minimalistischer URL-Kürzer.",
      "Long URL" => "Lange URL",
      "Custom Alias (optional)" => "Benutzerdefinierter Alias (optional)",
      "Shorten URL" => "URL kürzen"
    },
    "fr" => %{
      "Shorten your links" => "Raccourcissez vos liens",
      "A minimalist URL shortener." => "Un raccourcisseur d'URL minimaliste.",
      "Long URL" => "URL longue",
      "Custom Alias (optional)" => "Alias personnalisé (optionnel)",
      "Shorten URL" => "Raccourcir l'URL"
    },
    "it" => %{
      "Shorten your links" => "Abbrevia i tuoi link",
      "A minimalist URL shortener." => "Un abbrevia URL minimalista.",
      "Long URL" => "URL lungo",
      "Custom Alias (optional)" => "Alias personalizzato (opzionale)",
      "Shorten URL" => "Abbrevia URL"
    },
    "es" => %{
      "Shorten your links" => "Acorta tus enlaces",
      "A minimalist URL shortener." => "Un acortador de URL minimalista.",
      "Long URL" => "URL larga",
      "Custom Alias (optional)" => "Alias personalizado (opcional)",
      "Shorten URL" => "Acortar URL"
    },
    "ar" => %{
      "Shorten your links" => "اختصر روابطك",
      "A minimalist URL shortener." => "مختصر روابط بسيط.",
      "Long URL" => "رابط طويل",
      "Custom Alias (optional)" => "اسم مستعار مخصص (اختياري)",
      "Shorten URL" => "اختصر الرابط"
    }
  }

  def run do
    for {lang, trans} <- @translations do
      path = "priv/gettext/#{lang}/LC_MESSAGES/default.po"
      content = File.read!(path)

      new_content = Enum.reduce(trans, content, fn {en, translated}, acc ->
        # We find `msgid "en"\nmsgstr ""` and replace it with `msgid "en"\nmsgstr "translated"`
        String.replace(acc, "msgid \"#{en}\"\nmsgstr \"\"", "msgid \"#{en}\"\nmsgstr \"#{translated}\"")
      end)

      File.write!(path, new_content)
      IO.puts("Translated #{lang}")
    end
  end
end

Translator.run()
