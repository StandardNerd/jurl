defmodule Jurl.Repo.Migrations.LinksShortCodeCaseInsensitive do
  use Ecto.Migration

  def change do
    # short_code is copied from custom_alias verbatim, so a case-insensitive
    # unique index on short_code also covers every custom code. That makes the
    # separate unique index on custom_alias redundant.
    drop index(:links, [:custom_alias])
    drop index(:links, [:short_code])

    create unique_index(
             :links,
             ["lower(short_code)"],
             name: :links_short_code_lower_unique_index
           )
  end
end
