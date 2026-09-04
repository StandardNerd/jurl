defmodule JurlWeb.DashboardLiveTest do
  use JurlWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Jurl.AccountsFixtures
  alias Jurl.Shortener.Link
  alias Jurl.Analytics.Click

  setup do
    user = AccountsFixtures.user_fixture()
    link = Jurl.Repo.insert!(%Link{original_url: "https://foo.com", short_code: "foo123", user_id: user.id})
    Jurl.Repo.insert!(%Click{link_id: link.id, ip_address: "1.2.3.4", browser: "Chrome", operating_system: "Linux"})
    
    %{user: user, link: link}
  end

  test "renders dashboard for anonymous user", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/dashboard/live")
    assert html =~ "Real-time analytics"
    assert html =~ "Temporary session links"
  end

  test "renders dashboard for authenticated user", %{conn: conn, user: user} do
    conn = log_in_user(conn, user)
    {:ok, _view, html} = live(conn, ~p"/dashboard/live")
    
    assert html =~ "Real-time analytics"
    assert html =~ "Logged in as #{user.email}"
    
    # Should see the link we created in setup
    assert html =~ "foo123"
  end
end
