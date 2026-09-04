defmodule JurlWeb.Plugs.AnonymousUser do
  import Plug.Conn
  require Logger

  @session_key "anonymous_user_id"
  @cookie_name "sl_anon_id"
  @cookie_max_age 365 * 24 * 60 * 60  # 1 year

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)
    case get_anonymous_id(conn) do
      nil ->
        new_id = generate_anonymous_id()
        Logger.debug("Creating new anonymous session: #{String.slice(new_id, 0, 8)}...")

        conn =
          conn
          |> put_session(@session_key, new_id)
          |> put_resp_cookie(@cookie_name, new_id,
              max_age: @cookie_max_age,
              http_only: true,
              secure: conn.scheme == :https,
              same_site: "Lax"
            )

        case conn.assigns[:current_user] do
          nil ->
            assign_identity(conn, :anonymous, new_id, nil)
          user ->
            assign_identity(conn, :authenticated, new_id, user)
        end

      id when is_binary(id) ->
        case conn.assigns[:current_user] do
          nil ->
            assign_identity(conn, :anonymous, id, nil)
          user ->
            assign_identity(conn, :authenticated, id, user)
        end
    end
  end

  defp get_anonymous_id(conn) do
    get_session(conn, @session_key) ||
    conn.cookies[@cookie_name]
  end

  defp generate_anonymous_id do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end

  defp assign_identity(conn, type, anon_id, user) do
    identity = case type do
      :anonymous -> Jurl.Accounts.Identity.new_anonymous(anon_id)
      :authenticated -> Jurl.Accounts.Identity.new_authenticated(user)
    end

    conn
    |> assign(:anonymous_id, anon_id)
    |> assign(:identity, identity)
    |> assign(:is_authenticated, not is_nil(user))
  end
end
