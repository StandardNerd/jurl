defmodule Jurl.Analytics do
  import Ecto.Query
  alias Jurl.Repo
  alias Jurl.Analytics.Click

  def subscribe_to_anonymous_links(anonymous_id) do
    Phoenix.PubSub.subscribe(Jurl.PubSub, "analytics:anon:#{anonymous_id}")
  end

  def subscribe_to_user_links(user_id) do
    Phoenix.PubSub.subscribe(Jurl.PubSub, "analytics:user:#{user_id}")
  end

  def subscribe_to_link(link_id) do
    Phoenix.PubSub.subscribe(Jurl.PubSub, "analytics:#{link_id}")
  end

  def get_active_visitors(identity) do
    # Returns count of unique visitors (IPs) in the last 5 minutes
    five_mins_ago = DateTime.utc_now() |> DateTime.add(-300, :second)
    
    query = case identity.type do
      :anonymous ->
        if identity.anonymous_id do
          from c in Click,
            join: l in assoc(c, :link),
            where: l.anonymous_id == ^identity.anonymous_id and c.inserted_at >= ^five_mins_ago,
            select: count(c.ip_address, :distinct)
        else
          nil
        end

      :authenticated ->
        if identity.user_id do
          from c in Click,
            join: l in assoc(c, :link),
            where: l.user_id == ^identity.user_id and c.inserted_at >= ^five_mins_ago,
            select: count(c.ip_address, :distinct)
        else
          nil
        end
    end

    if query do
      Repo.one(query) || 0
    else
      0
    end
  end

  def get_link_analytics(link_id) do
    # Fetch clicks for this link
    Repo.all(from c in Click, where: c.link_id == ^link_id, order_by: [desc: c.inserted_at], limit: 100)
  end

  def get_detailed_stats(link) do
    # Group clicks by country, browser, device, OS, referrer
    clicks = Repo.all(from c in Click, where: c.link_id == ^link.id)

    total_clicks = length(clicks)
    unique_visitors = clicks |> Enum.map(& &1.ip_address) |> Enum.uniq() |> length()

    clicks_by_country = clicks |> Enum.group_by(& &1.country) |> Enum.map(fn {k, v} -> %{country: k, count: length(v)} end)
    clicks_by_device = clicks |> Enum.group_by(& &1.device_type) |> Enum.map(fn {k, v} -> %{device_type: k, count: length(v)} end)
    clicks_by_browser = clicks |> Enum.group_by(& &1.browser) |> Enum.map(fn {k, v} -> %{browser: k, count: length(v)} end)
    clicks_by_os = clicks |> Enum.group_by(& &1.operating_system) |> Enum.map(fn {k, v} -> %{os: k, count: length(v)} end)
    clicks_by_referrer = clicks |> Enum.group_by(& &1.referrer) |> Enum.map(fn {k, v} -> %{referrer: k, count: length(v)} end)

    %{
      total_clicks: total_clicks,
      unique_visitors: unique_visitors,
      clicks_by_country: clicks_by_country,
      clicks_by_device: clicks_by_device,
      clicks_by_browser: clicks_by_browser,
      clicks_by_os: clicks_by_os,
      clicks_by_referrer: clicks_by_referrer
    }
  end

  def get_click_history(identity) do
    # Fetch clicks for all links owned by this identity, ordered by time desc
    query = case identity.type do
      :anonymous ->
        if identity.anonymous_id do
          from c in Click,
            join: l in assoc(c, :link),
            where: l.anonymous_id == ^identity.anonymous_id,
            order_by: [desc: c.inserted_at],
            limit: 100
        else
          nil
        end

      :authenticated ->
        if identity.user_id do
          from c in Click,
            join: l in assoc(c, :link),
            where: l.user_id == ^identity.user_id,
            order_by: [desc: c.inserted_at],
            limit: 100
        else
          nil
        end
    end

    if query do
      Repo.all(query)
      |> Repo.preload(:link)
    else
      []
    end
  end

  def export_csv(links) do
    # Generate CSV header and entries
    header = "original_url,short_code,click_count,inserted_at\n"
    rows = Enum.map(links, fn link ->
      "#{link.original_url},#{link.short_code},#{link.click_count},#{link.inserted_at}\n"
    end)
    [header | rows] |> IO.iodata_to_binary()
  end
end
