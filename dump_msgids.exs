content = File.read!("priv/gettext/en/LC_MESSAGES/default.po")
regex = ~r/msgid "(.*)"/
matches = Regex.scan(regex, content)
|> Enum.map(fn [_, msgid] -> msgid end)
|> Enum.reject(&(&1 == ""))
|> Enum.uniq()

for match <- matches do
  IO.puts(match)
end
