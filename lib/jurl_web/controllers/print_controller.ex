defmodule JurlWeb.PrintController do
  use JurlWeb, :controller

  def show(conn, %{"short_code" => short_code}) do
    short_url = "#{JurlWeb.Endpoint.url()}/#{short_code}"

    conn
    |> put_layout(false)
    |> render(:show, short_code: short_code, short_url: short_url)
  end
end
