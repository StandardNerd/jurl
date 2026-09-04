defmodule Jurl.Shortener do
  import Ecto.Query
  alias Jurl.Repo
  alias Jurl.Shortener.Link
  alias Jurl.Anonymous.Limiter
  alias Jurl.Anonymous.SessionStore

  # Overload to get identity from plug conn, liveview socket, or directly
  defp get_identity(%Plug.Conn{assigns: %{identity: %Jurl.Accounts.Identity{} = identity}}), do: identity
  defp get_identity(%Plug.Conn{assigns: %{current_user: %Jurl.Accounts.User{} = user}}), do: Jurl.Accounts.Identity.new_authenticated(user)
  defp get_identity(%Plug.Conn{} = conn) do
    anon_id = Plug.Conn.get_session(conn, "anonymous_user_id") || "anonymous_conn"
    Jurl.Accounts.Identity.new_anonymous(anon_id)
  end

  defp get_identity(%Phoenix.LiveView.Socket{assigns: %{identity: %Jurl.Accounts.Identity{} = identity}}), do: identity
  defp get_identity(%Phoenix.LiveView.Socket{assigns: %{current_user: %Jurl.Accounts.User{} = user}}), do: Jurl.Accounts.Identity.new_authenticated(user)
  defp get_identity(%Phoenix.LiveView.Socket{assigns: assigns}) do
    case Map.get(assigns, :identity) do
      %Jurl.Accounts.Identity{} = identity ->
        identity
      _ ->
        case Map.get(assigns, :current_user) do
          %Jurl.Accounts.User{} = user -> Jurl.Accounts.Identity.new_authenticated(user)
          _ -> Jurl.Accounts.Identity.new_anonymous(Map.get(assigns, :anonymous_id) || "anonymous_socket")
        end
    end
  end

  defp get_identity(%Jurl.Accounts.Identity{} = identity), do: identity
  defp get_identity(_), do: %Jurl.Accounts.Identity{type: :anonymous, anonymous_id: "system", user_id: nil}

  def create_link(context, attrs) do
    identity = get_identity(context)

    cond do
      identity.type == :authenticated and not is_nil(identity.user_id) ->
        create_user_link(identity.user_id, attrs)

      identity.type == :anonymous and not is_nil(identity.anonymous_id) ->
        with :ok <- Limiter.check_limits(identity.anonymous_id) do
          create_anonymous_link(identity.anonymous_id, attrs)
        end

      true ->
        {:error, :unauthorized}
    end
  end

  def create_anonymous_link(anonymous_id, attrs) do
    attrs = attrs
    |> Map.put(:anonymous_id, anonymous_id)
    |> Map.put(:owner_type, "anonymous")

    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, link} ->
        broadcast_link_created(link)
        Limiter.increment_link_count(anonymous_id)
        SessionStore.add_link(anonymous_id, link.short_code)
        {:ok, link}
      error -> error
    end
  end

  def create_user_link(user_id, attrs) do
    attrs = attrs
    |> Map.put(:user_id, user_id)
    |> Map.put(:owner_type, "authenticated")

    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, link} ->
        broadcast_link_created(link)
        {:ok, link}
      error -> error
    end
  end

  def list_links_for_identity(context, params \\ %{}) do
    identity = get_identity(context)

    base_query = from l in Link,
      where: l.is_active == true,
      order_by: [desc: l.inserted_at]

    query = case identity.type do
      :anonymous ->
        if identity.anonymous_id do
          from l in base_query, where: l.anonymous_id == ^identity.anonymous_id
        else
          from l in base_query, where: false
        end

      :authenticated ->
        if identity.user_id do
          from l in base_query, where: l.user_id == ^identity.user_id
        else
          from l in base_query, where: false
        end
    end

    page = Map.get(params, :page, 1)
    page_size = Map.get(params, :page_size, 20)
    offset = (page - 1) * page_size

    entries = query
    |> limit(^page_size)
    |> offset(^offset)
    |> Repo.all()

    %{
      entries: entries,
      page_number: page,
      page_size: page_size
    }
  end

  def owned_by?(link, context) do
    identity = get_identity(context)
    case identity.type do
      :anonymous -> not is_nil(identity.anonymous_id) and link.anonymous_id == identity.anonymous_id
      :authenticated -> not is_nil(identity.user_id) and link.user_id == identity.user_id
    end
  end

  def get_link_for_identity(short_code, context) do
    link = Repo.get_by(Link, short_code: short_code)

    if link && owned_by?(link, context) do
      {:ok, link}
    else
      {:error, :not_found}
    end
  end

  def deactivate_link(link) do
    link
    |> Link.changeset(%{is_active: false})
    |> Repo.update()
  end

  defp broadcast_link_created(link) do
    Phoenix.PubSub.broadcast(
      Jurl.PubSub,
      "links:created",
      {:link_created, link}
    )
  end
end
