defmodule Translator2 do
  @translations %{
    "de" => %{
      "Choose your language:" => "Wählen Sie Ihre Sprache:"
    },
    "fr" => %{
      "Choose your language:" => "Choisissez votre langue :"
    },
    "it" => %{
      "Choose your language:" => "Scegli la tua lingua:"
    },
    "es" => %{
      "Choose your language:" => "Elige tu idioma:"
    },
    "ar" => %{
      "Choose your language:" => "اختر لغتك:"
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

Translator2.run()
