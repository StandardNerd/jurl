defmodule Jurl.Shortener.Link do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "links" do
    field :original_url, :string
    field :short_code, :string
    field :custom_alias, :string
    field :title, :string
    field :description, :string
    field :og_image_url, :string
    field :password_hash, :string
    field :expires_at, :utc_datetime
    field :is_active, :boolean, default: true
    field :click_count, :integer, default: 0

    # Ownership fields
    field :anonymous_id, :string
    belongs_to :user, Jurl.Accounts.User

    # Virtual fields
    field :owner_type, :string, virtual: true

    has_many :clicks, Jurl.Analytics.Click

    timestamps(type: :utc_datetime)
  end

  @required_fields [:original_url]
  @optional_fields [:custom_alias, :password_hash, :expires_at, :title, :description]

  def changeset(link, attrs) do
    link
    |> cast(attrs, @required_fields ++ @optional_fields ++ [:anonymous_id, :user_id, :is_active, :click_count, :owner_type])
    |> validate_required(@required_fields)
    |> validate_url(:original_url)
    |> generate_short_code()
    |> validate_unique_short_code()
    |> hash_password()
    |> validate_expiry()
    |> unique_constraint(:short_code)
    |> unique_constraint(:custom_alias)
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, url ->
      case URI.parse(url) do
        %URI{scheme: scheme} when scheme in ["http", "https"] -> []
        _ -> [{field, "Must be a valid HTTP or HTTPS URL"}]
      end
    end)
  end

  defp generate_short_code(changeset) do
    if get_field(changeset, :custom_alias) do
      # If custom alias is provided, we use it as the short code
      put_change(changeset, :short_code, get_field(changeset, :custom_alias))
    else
      # Only generate code if short_code is not already set
      case get_field(changeset, :short_code) do
        nil ->
          code = Jurl.Shortener.CodeGenerator.generate()
          put_change(changeset, :short_code, code)
        _ ->
          changeset
      end
    end
  end

  defp validate_unique_short_code(changeset) do
    changeset
    |> unsafe_validate_unique(:short_code, Jurl.Repo)
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password_hash) do
      nil -> changeset
      password ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end

  defp validate_expiry(changeset) do
    case get_change(changeset, :expires_at) do
      nil -> changeset
      expiry ->
        if DateTime.compare(expiry, DateTime.utc_now()) == :gt do
          changeset
        else
          add_error(changeset, :expires_at, "must be in the future")
        end
    end
  end
end
