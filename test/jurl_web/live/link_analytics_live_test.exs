defmodule JurlWeb.LinkAnalyticsLiveTest do
  use JurlWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Jurl.Shortener.Link
  alias Jurl.Analytics.Click

  setup do
    user = Jurl.AccountsFixtures.user_fixture()
    link = Jurl.Repo.insert!(%Link{original_url: "https://bar.com", short_code: "bar123", user_id: user.id})
    Jurl.Repo.insert!(%Click{link_id: link.id, ip_address: "1.1.1.1", browser: "Firefox", operating_system: "Windows", referrer: "google.com", country: "US", device_type: "Desktop"})
    
    %{user: user, link: link}
  end

  test "renders analytics for owner", %{conn: conn, user: user, link: link} do
    conn = log_in_user(conn, user)
    res = live(conn, ~p"/links/#{link.short_code}")
    {:ok, _view, html} = res
    
    assert html =~ link.original_url
    assert html =~ "Total Clicks"
    assert html =~ "Unique Visitors"
    assert html =~ "google.com" # referrer
    assert html =~ "Firefox"
    assert html =~ "Windows"
    assert html =~ "US"
  end

  test "redirects to home when unauthorized", %{conn: conn, link: link} do
    # anon user
    {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/links/#{link.short_code}")
  end
end
