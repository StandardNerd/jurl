defmodule Jurl.Analytics.Click do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clicks" do
    field :ip_address, :string
    field :user_agent, :string
    field :referrer, :string
    field :country, :string
    field :city, :string
    field :region, :string
    field :device_type, :string
    field :browser, :string
    field :operating_system, :string
    field :is_unique, :boolean, default: false

    belongs_to :link, Jurl.Shortener.Link

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(click, attrs) do
    click
    |> cast(attrs, [:ip_address, :user_agent, :referrer, :country, :city, :region, :device_type, :browser, :operating_system, :is_unique, :link_id])
    |> validate_required([:link_id])
  end
end
