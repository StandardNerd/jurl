defmodule Jurl.Accounts.Identity do
  @moduledoc """
  Virtual schema representing the current user identity.
  Can be either anonymous or authenticated.
  """

  use Ecto.Schema

  @type t :: %__MODULE__{
    type: :anonymous | :authenticated,
    anonymous_id: String.t() | nil,
    user_id: any() | nil,
    user: Jurl.Accounts.User.t() | nil
  }

  embedded_schema do
    field :type, Ecto.Enum, values: [:anonymous, :authenticated]
    field :anonymous_id, :string
    field :user_id, :binary_id
    field :user, :any, virtual: true
  end

  def new_anonymous(anonymous_id) do
    %__MODULE__{
      type: :anonymous,
      anonymous_id: anonymous_id,
      user_id: nil,
      user: nil
    }
  end

  def new_authenticated(user) do
    %__MODULE__{
      type: :authenticated,
      anonymous_id: nil,
      user_id: user.id,
      user: user
    }
  end
end
