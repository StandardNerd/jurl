defmodule Jurl.Analytics.UserAgentParser do
  def parse(nil), do: %{browser: "Unknown", os: "Unknown", device: "Desktop"}
  def parse(ua) do
    ua_string = String.downcase(ua)

    device =
      cond do
        String.contains?(ua_string, ["ipad", "tablet"]) -> "Tablet"
        String.contains?(ua_string, ["mobile", "iphone", "android"]) -> "Mobile"
        true -> "Desktop"
      end

    browser =
      cond do
        String.contains?(ua_string, "chrome") and not String.contains?(ua_string, "chromeframe") -> "Chrome"
        String.contains?(ua_string, "firefox") -> "Firefox"
        String.contains?(ua_string, "safari") and not String.contains?(ua_string, "chrome") -> "Safari"
        String.contains?(ua_string, "msie") or String.contains?(ua_string, "trident") -> "IE"
        String.contains?(ua_string, "edge") -> "Edge"
        true -> "Other"
      end

    os =
      cond do
        String.contains?(ua_string, "windows") -> "Windows"
        String.contains?(ua_string, "iphone") or String.contains?(ua_string, "ipad") -> "iOS"
        String.contains?(ua_string, "macintosh") or String.contains?(ua_string, "mac os") -> "macOS"
        String.contains?(ua_string, "android") -> "Android"
        String.contains?(ua_string, "linux") -> "Linux"
        true -> "Other"
      end

    %{browser: browser, os: os, device: device}
  end
end

defmodule Jurl.Analytics.ClickProcessor do
  use GenServer
  import Ecto.Query
  require Logger

  @flush_interval 5_000  # 5 seconds
  @batch_size 100

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def clear_state do
    GenServer.call(__MODULE__, :clear_state)
  end

  @impl true
  def init(_opts) do
    timer = Process.send_after(self(), :flush, @flush_interval)
    {:ok, %{buffer: [], timer: timer}}
  end

  def track_click(link_id, click_data) do
    GenServer.cast(__MODULE__, {:track_click, link_id, click_data})
  end

  @impl true
  def handle_cast({:track_click, link_id, click_data}, state) do
    new_buffer = [{link_id, click_data} | state.buffer]

    if length(new_buffer) >= @batch_size do
      flush_buffer(new_buffer)
      {:noreply, %{state | buffer: []}}
    else
      {:noreply, %{state | buffer: new_buffer}}
    end
  end

  @impl true
  def handle_call(:clear_state, _from, state) do
    {:reply, :ok, %{state | buffer: []}}
  end

  @impl true
  def handle_info(:flush, state) do
    if state.timer, do: Process.cancel_timer(state.timer)
    flush_buffer(state.buffer)
    timer = Process.send_after(self(), :flush, @flush_interval)
    {:noreply, %{state | buffer: [], timer: timer}}
  end

  defp flush_buffer([]), do: :ok
  defp flush_buffer(buffer) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    clicks = Enum.map(buffer, fn {link_id, data} ->
      ua_info = Jurl.Analytics.UserAgentParser.parse(data.user_agent)

      {country, city} =
        if data.ip in ["127.0.0.1", "::1", "localhost"] do
          {"Local", "Localhost"}
        else
          {"United States", "New York"}
        end

      uuid = Ecto.UUID.generate()

      %{
        id: uuid,
        link_id: link_id,
        ip_address: data.ip,
        user_agent: data.user_agent,
        referrer: data.referrer || "Direct",
        country: country,
        city: city,
        region: "Unknown",
        device_type: ua_info.device,
        browser: ua_info.browser,
        operating_system: ua_info.os,
        is_unique: true,
        inserted_at: now
      }
    end)

    try do
      # Insert into db
      Jurl.Repo.insert_all(Jurl.Analytics.Click, clicks)

      # Increment click_count on links table
      # We group clicks by link_id to do it in fewer queries
      link_counts = Enum.reduce(buffer, %{}, fn {link_id, _}, acc ->
        Map.update(acc, link_id, 1, &(&1 + 1))
      end)

      Enum.each(link_counts, fn {link_id, count} ->
        import Ecto.Query
        Jurl.Repo.update_all(
          from(l in Jurl.Shortener.Link, where: l.id == ^link_id),
          inc: [click_count: count]
        )
      end)

      # Broadcast to pubsub for real-time updates
      # Fetch link ownership to broadcast to user/anon channels
      link_ids = Enum.map(buffer, fn {link_id, _} -> link_id end) |> Enum.uniq()
      links_by_id = Jurl.Repo.all(from l in Jurl.Shortener.Link, where: l.id in ^link_ids)
      |> Map.new(fn l -> {l.id, l} end)

      Enum.each(clicks, fn click ->
        link = Map.get(links_by_id, click.link_id)

        # Broadcast to link-specific channel
        Phoenix.PubSub.broadcast(
          Jurl.PubSub,
          "analytics:#{click.link_id}",
          {:new_click, click}
        )

        if link do
          if link.user_id do
            Phoenix.PubSub.broadcast(
              Jurl.PubSub,
              "analytics:user:#{link.user_id}",
              {:new_click, click}
            )
          end

          if link.anonymous_id do
            Phoenix.PubSub.broadcast(
              Jurl.PubSub,
              "analytics:anon:#{link.anonymous_id}",
              {:new_click, click}
            )
          end
        end
      end)
    rescue
      e ->
        Logger.error("Failed to flush click buffer: #{inspect(e)}")
    end

    :ok
  end
end
