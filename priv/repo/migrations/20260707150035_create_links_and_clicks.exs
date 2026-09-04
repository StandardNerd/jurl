defmodule Jurl.Repo.Migrations.CreateLinksAndClicks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :original_url, :text, null: false
      add :short_code, :string, null: false
      add :custom_alias, :string
      add :title, :string
      add :description, :text
      add :og_image_url, :string
      add :password_hash, :string
      add :expires_at, :utc_datetime
      add :is_active, :boolean, default: true, null: false
      add :click_count, :integer, default: 0

      # Ownership fields
      add :anonymous_id, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    # Indexes for efficient lookups
    create unique_index(:links, [:short_code])
    create unique_index(:links, [:custom_alias])
    create index(:links, [:anonymous_id])
    create index(:links, [:user_id])
    create index(:links, [:anonymous_id, :user_id])
    create index(:links, [:expires_at])
    create index(:links, [:inserted_at])

    create table(:clicks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :link_id, references(:links, on_delete: :delete_all, type: :binary_id), null: false

      add :ip_address, :string
      add :user_agent, :text
      add :referrer, :text
      add :country, :string
      add :city, :string
      add :region, :string
      add :device_type, :string
      add :browser, :string
      add :operating_system, :string
      add :is_unique, :boolean, default: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:clicks, [:link_id, :inserted_at])
    create index(:clicks, [:country, :inserted_at])
    create index(:clicks, [:inserted_at])
  end
end
