defmodule JurlWeb.RedirectController do
  use JurlWeb, :controller
  import Phoenix.Controller, except: [redirect: 2]
  import Ecto.Query, only: [from: 2]

  alias Jurl.Repo
  alias Jurl.Shortener.Link
  alias Jurl.Cache.URLCache
  alias Jurl.Analytics.ClickProcessor

  def redirect(conn, %{"short_code" => short_code}) do
    # Stored codes are always lowercase; normalize so custom codes resolve
    # regardless of how the visitor typed them.
    case resolve_url(String.downcase(short_code)) do
      {:ok, url, link} ->
        # Fire-and-forget click tracking
        track_click_async(link, conn)

        conn
        |> put_status(:found)
        |> Phoenix.Controller.redirect(external: url)

      {:error, :expired} ->
        conn
        |> put_status(:gone)
        |> json(%{error: "Link has expired"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Link not found"})
    end
  end

  defp resolve_url(short_code) do
    # Tiered cache lookup
    case URLCache.get_url(short_code) do
      {:ok, url, link_id} ->
        # ETS cache hit - sub-millisecond
        {:ok, url, %{id: link_id}}

      {:error, :not_found} ->
        # Cache miss - check database (case-insensitive, matches the
        # lower(short_code) unique index)
        case Repo.one(from l in Link,
               where: fragment("lower(?)", l.short_code) == ^short_code and l.is_active == true
             ) do
          %Link{expires_at: expires} = link when not is_nil(expires) ->
            if DateTime.compare(expires, DateTime.utc_now()) == :gt do
              URLCache.put_url(short_code, link.original_url, link.id)
              {:ok, link.original_url, link}
            else
              {:error, :expired}
            end

          %Link{} = link ->
            URLCache.put_url(short_code, link.original_url, link.id)
            {:ok, link.original_url, link}

          nil ->
            {:error, :not_found}
        end
    end
  end

  defp track_click_async(link, conn) do
    # remote_ip is a tuple, e.g. {127, 0, 0, 1}. :inet.ntoa converts to charlist, e.g. '127.0.0.1'.
    ip_str = conn.remote_ip |> :inet.ntoa() |> to_string()

    click_data = %{
      ip: ip_str,
      user_agent: get_req_header(conn, "user-agent") |> List.first(),
      referrer: get_req_header(conn, "referer") |> List.first()
    }

    ClickProcessor.track_click(link.id, click_data)
  end
end
