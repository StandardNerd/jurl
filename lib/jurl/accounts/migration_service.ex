defmodule Jurl.Accounts.MigrationService do
  @moduledoc """
  Handles migration of anonymous links to authenticated user accounts.
  Triggered automatically after registration or login.
  """

  import Ecto.Query
  require Logger
  alias Jurl.Repo
  alias Jurl.Shortener.Link
  alias Jurl.Accounts.User

  @doc """
  Claims all anonymous links for a newly registered/logged in user.
  Updates the user record to track the migration.
  """
  def claim_anonymous_links(nil, _user), do: {:ok, %{links_migrated: 0}}
  def claim_anonymous_links(anonymous_id, %User{} = user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update_all(
      :claim_links,
      from(l in Link,
        where: l.anonymous_id == ^anonymous_id,
        where: l.is_active == true
      ),
      set: [
        user_id: user.id,
        anonymous_id: nil
      ]
    )
    |> Ecto.Multi.update(
      :update_user,
      User.changeset(user, %{migrated_anonymous_id: anonymous_id})
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{claim_links: {count, _}, update_user: updated_user}} ->
        Logger.info(
          "Migrated #{count} links from anonymous session #{String.slice(anonymous_id, 0, 8)}... " <>
          "to user #{user.id} (#{user.email})"
        )

        # Clear anonymous session data
        Jurl.Anonymous.SessionStore.clear_session(anonymous_id)

        {:ok, %{links_migrated: count, user: updated_user}}

      {:error, name, error, _} ->
        Logger.error("Failed to migrate anonymous links (at #{name}): #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Merges anonymous links when logging into an existing account.
  """
  def merge_anonymous_links(nil, _user), do: {:ok, %{links_migrated: 0}}
  def merge_anonymous_links(anonymous_id, %User{} = user) do
    # Check if this anonymous ID was already migrated
    if user.migrated_anonymous_id == anonymous_id do
      {:ok, %{links_migrated: 0, message: "Already migrated"}}
    else
      claim_anonymous_links(anonymous_id, user)
    end
  end

  @doc """
  Finds links that can be migrated for an anonymous session.
  Returns count and preview of links to be migrated.
  """
  def preview_migration(anonymous_id) do
    links = Repo.all(
      from l in Link,
      where: l.anonymous_id == ^anonymous_id,
      where: l.is_active == true,
      select: %{short_code: l.short_code, original_url: l.original_url},
      limit: 5
    )

    total_count = Repo.aggregate(
      from(l in Link,
        where: l.anonymous_id == ^anonymous_id,
        where: l.is_active == true
      ),
      :count
    )

    %{
      total_links: total_count,
      preview: links
    }
  end
end
