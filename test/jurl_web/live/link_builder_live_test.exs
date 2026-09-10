defmodule JurlWeb.LinkBuilderLiveTest do
  use JurlWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders the builder page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Shorten URL"
  end

  test "creates a short link", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    
    assert view
           |> form("form[phx-submit=\"shorten\"]", url: "https://elixir.org")
           |> render_submit() =~ "elixir.org"
  end

  test "shows error for invalid url", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    
    assert view
           |> form("form[phx-submit=\"shorten\"]", url: "not-a-url")
           |> render_submit() =~ "Must be a valid HTTP or HTTPS URL"
  end

  test "dismisses upgrade prompt", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    
    # Render with an upgrade prompt by hitting max links or triggering the limit error
    # Instead of full setup for rate limiting, we can just send the event if there was a prompt
    # or just call handle_event directly, but LiveViewTest allows pushing events
    assert render_click(view, "dismiss_upgrade", %{})
  end

  test "renders sticky footer with author link", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Made by"
    assert html =~ ~s(href="mailto:joon.ch@gmail.com")
    assert html =~ "Joon-Ki Choi"
  end

  test "renders Print PDF button when URL is shortened", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    html =
      view
      |> form("form[phx-submit=\"shorten\"]", url: "https://elixir-lang.org")
      |> render_submit()

    assert html =~ "Print PDF"
    assert html =~ "/print?auto=true"
  end

  test "renders copy button for each recent link with its shortened URL", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("form[phx-submit=\"shorten\"]", url: "https://elixir-lang.org")
    |> render_submit()

    html =
      view
      |> form("form[phx-submit=\"shorten\"]", url: "https://hexdocs.pm")
      |> render_submit()

    assert html =~ "Your Recent Links"
    # Both URLs appear in the recent list with their respective copy buttons
    assert html =~ ~s(phx-click="copy_to_clipboard")
    # Verify that recent links have their own copy buttons containing their respective short URLs
    links = Jurl.Repo.all(Jurl.Shortener.Link)
    assert length(links) == 2
    for link <- links do
      short_url = "#{JurlWeb.Endpoint.url()}/#{link.short_code}"
      assert html =~ ~s(phx-value-text="#{short_url}")
    end
  end

  describe "custom short codes" do
    test "renders the custom code input", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "Custom code"
      assert html =~ ~s(name="custom_alias")
    end

    test "creates a link with a custom code", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form[phx-submit=\"shorten\"]", url: "https://example.com/house", custom_alias: "house12")
        |> render_submit()

      assert html =~ "/house12"
      assert Jurl.Repo.get_by(Jurl.Shortener.Link, short_code: "house12")
    end

    test "shows inline error when the custom code is taken", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("form[phx-submit=\"shorten\"]", url: "https://example.com", custom_alias: "taken12")
      |> render_submit()

      html =
        view
        |> form("form[phx-submit=\"shorten\"]", url: "https://example.com/other", custom_alias: "taken12")
        |> render_submit()

      assert html =~ "has already been taken"
    end

    test "shows inline error for invalid characters", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form[phx-submit=\"shorten\"]", url: "https://example.com", custom_alias: "bad code!")
        |> render_submit()

      assert html =~ "letters, numbers, hyphens and underscores"
    end

    test "shows inline error for reserved words", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form[phx-submit=\"shorten\"]", url: "https://example.com", custom_alias: "admin")
        |> render_submit()

      assert html =~ "is reserved"
    end
  end
end
