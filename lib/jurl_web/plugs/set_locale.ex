defmodule JurlWeb.Plugs.SetLocale do
  import Plug.Conn

  @supported_locales ~w(en de fr it es ar ko sk pl hu el tr pt)

  def init(_opts), do: nil

  def call(conn, _opts) do
    locale =
      conn.params["locale"] ||
        get_session(conn, :locale) ||
        extract_accept_language(conn) ||
        "en"

    locale = if locale in @supported_locales, do: locale, else: "en"

    Gettext.put_locale(JurlWeb.Gettext, locale)

    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end

  defp extract_accept_language(conn) do
    case get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_q/1)
        |> Enum.sort_by(&elem(&1, 1), :desc)
        |> Enum.map(&elem(&1, 0))
        |> Enum.find(&(&1 in @supported_locales))

      _ ->
        nil
    end
  end

  defp parse_language_q(lang) do
    case String.split(lang, ";q=") do
      [l, q] ->
        {String.split(l, "-") |> List.first(), Float.parse(q) |> elem(0)}

      [l] ->
        {String.split(l, "-") |> List.first(), 1.0}
    end
  end
end
