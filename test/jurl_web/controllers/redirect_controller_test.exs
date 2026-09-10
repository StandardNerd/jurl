defmodule JurlWeb.RedirectControllerTest do
  use JurlWeb.ConnCase
  
  alias Jurl.Shortener.Link
  
  setup do
    link = %Link{original_url: "https://example.com/target", short_code: "redir123"}
           |> Jurl.Repo.insert!()
    {:ok, link: link}
  end

  test "redirects to original url", %{conn: conn, link: link} do
    conn = get(conn, ~p"/#{link.short_code}")
    assert redirected_to(conn) == "https://example.com/target"
  end

  test "returns 404 for unknown short code", %{conn: conn} do
    conn = get(conn, ~p"/unknown_code")
    assert json_response(conn, 404)["error"] == "Link not found"
  end

  test "returns 410 for expired short code", %{conn: conn} do
    expired_date = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.truncate(:second)
    expired_link = %Link{original_url: "https://example.com/expired", short_code: "exp123", expires_at: expired_date}
                   |> Jurl.Repo.insert!()

    conn = get(conn, ~p"/#{expired_link.short_code}")
    assert json_response(conn, 410)["error"] == "Link has expired"
  end

  test "redirects custom codes case-insensitively", %{conn: conn} do
    conn = get(conn, ~p"/REDIR123")
    assert redirected_to(conn) == "https://example.com/target"
  end
end
