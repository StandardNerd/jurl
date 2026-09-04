defmodule Jurl.Anonymous.Limiter do
  @moduledoc """
  Manages rate limits and restrictions for anonymous users.
  Provides clear upgrade paths to premium features.
  """

  use GenServer

  # Limits configuration
  @max_links_per_session 50
  @max_rate_per_minute 10

  # Allowed and restricted features
  @allowed_features [
    :basic_shorten,
    :custom_alias,
    :qr_code,
    :basic_analytics
  ]

  @restricted_features [
    :advanced_analytics,
    :analytics_export,
    :team_collaboration,
    :api_access,
    :bulk_shorten,
    :password_protected_links,
    :link_retargeting,
    :white_label_domains
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    :ets.new(:anon_rate_limits, [
      :named_table,
      :public,
      :set,
      read_concurrency: true,
      write_concurrency: true
    ])

    :ets.new(:anon_link_counts, [
      :named_table,
      :public,
      :set,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, %{}}
  end

  @doc """
  Check if anonymous user has exceeded any limits.
  Returns :ok or {:error, reason} with upgrade message.
  """
  def check_limits(nil), do: :ok
  def check_limits(anonymous_id) do
    with :ok <- check_link_count(anonymous_id),
         :ok <- check_rate_limit(anonymous_id) do
      :ok
    end
  end

  def check_link_count(nil), do: :ok
  def check_link_count(anonymous_id) do
    count = get_link_count(anonymous_id)
    if count >= @max_links_per_session do
      {:error, :max_links}
    else
      :ok
    end
  end

  def check_rate_limit(nil), do: :ok
  def check_rate_limit(anonymous_id) do
    current_minute = System.system_time(:second) |> div(60)
    key = {anonymous_id, current_minute}
    # {key, value} default with value=0, then we increment value (index 2) by 1
    count = :ets.update_counter(:anon_rate_limits, key, {2, 1}, {key, 0})

    if count > @max_rate_per_minute do
      {:error, :rate_limit}
    else
      :ok
    end
  end

  def increment_link_count(nil), do: :ok
  def increment_link_count(anonymous_id) do
    :ets.update_counter(:anon_link_counts, anonymous_id, {2, 1}, {anonymous_id, 0})
  end

  @doc """
  Returns a user-friendly upgrade message based on the limit reached.
  """
  def upgrade_prompt(:max_links) do
    """
    You've reached the limit of #{@max_links_per_session} anonymous links.
    Create a free account to create unlimited links and unlock advanced features!
    """
  end

  def upgrade_prompt(:rate_limit) do
    """
    You're creating links too quickly.
    Sign up for higher rate limits and API access!
    """
  end

  def upgrade_prompt(:feature_restricted) do
    """
    This feature requires an account.
    Sign up to access advanced analytics, team collaboration, and more!
    """
  end

  def get_link_count(nil), do: 0
  def get_link_count(anonymous_id) do
    case :ets.lookup(:anon_link_counts, anonymous_id) do
      [{^anonymous_id, count}] -> count
      [] -> 0
    end
  end

  def allowed_features, do: @allowed_features
  def restricted_features, do: @restricted_features
end
