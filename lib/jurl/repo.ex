defmodule Jurl.Repo do
  use Ecto.Repo,
    otp_app: :jurl,
    adapter: Ecto.Adapters.Postgres
end
