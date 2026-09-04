defmodule JurlWeb.PrintControllerTest do
  use JurlWeb.ConnCase

  alias Jurl.Shortener.Link

  setup do
    link =
      %Link{original_url: "https://example.com/target", short_code: "print123"}
      |> Jurl.Repo.insert!()

    {:ok, link: link}
  end

  test "renders 20x3 grid print page with short URL and website fonts", %{conn: conn, link: link} do
    conn = get(conn, ~p"/links/#{link.short_code}/print")
    html = html_response(conn, 200)

    assert html =~ "Print Slips Grid (20 × 3)"
    assert html =~ "print123"
    assert html =~ "Instrument Serif"
    assert html =~ "Inter"
    assert html =~ "grid-template-columns: repeat(3, 1fr)"
    assert html =~ "grid-template-rows: repeat(20, 1fr)"
  end
end
