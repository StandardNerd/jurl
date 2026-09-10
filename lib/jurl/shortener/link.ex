defmodule Jurl.Shortener.Link do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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

  @custom_code_format ~r/^[a-zA-Z0-9_-]+$/

  # Short codes live at the root path (/:short_code), so a custom code must
  # never shadow an existing app route.
  @reserved_codes ~w[
    admin api new login logout register dashboard links users user
    dev graphql health healthz status metrics assets images static
    settings account sessions session
  ]

  def changeset(link, attrs) do
    link
    |> cast(attrs, @required_fields ++ @optional_fields ++ [:anonymous_id, :user_id, :is_active, :click_count, :owner_type])
    |> validate_required(@required_fields)
    |> validate_url(:original_url)
    |> normalize_custom_alias()
    |> validate_format(:custom_alias, @custom_code_format,
      message: "may only contain letters, numbers, hyphens and underscores"
    )
    |> validate_length(:custom_alias, min: 3, max: 32)
    |> validate_exclusion(:custom_alias, @reserved_codes, message: "is reserved")
    |> generate_short_code()
    |> validate_unique_short_code()
    |> hash_password()
    |> validate_expiry()
    |> unique_constraint(:short_code,
      name: "links_short_code_lower_unique_index",
      message: "has already been taken"
    )
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, url ->
      case URI.parse(url) do
        %URI{scheme: scheme} when scheme in ["http", "https"] -> []
        _ -> [{field, "Must be a valid HTTP or HTTPS URL"}]
      end
    end)
  end

  defp normalize_custom_alias(changeset) do
    case get_change(changeset, :custom_alias) do
      code when is_binary(code) ->
        code = code |> String.trim() |> String.downcase()
        put_change(changeset, :custom_alias, if(code == "", do: nil, else: code))

      _ ->
        changeset
    end
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

  # Codes are unique case-insensitively: stored short codes are always
  # lowercase (the generator only emits lowercase and custom codes are
  # downcased above), so compare lower(short_code) to the downcased change.
  defp validate_unique_short_code(changeset) do
    case get_change(changeset, :short_code) do
      code when is_binary(code) ->
        unsafe_validate_unique(changeset, [:short_code], Jurl.Repo,
          query:
            from(l in __MODULE__,
              where: fragment("lower(?)", l.short_code) == ^String.downcase(code)
            ),
          message: "has already been taken"
        )

      _ ->
        changeset
    end
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
