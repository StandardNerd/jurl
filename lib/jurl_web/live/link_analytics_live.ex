defmodule JurlWeb.LinkAnalyticsLive do
  use JurlWeb, :live_view

  alias Jurl.Shortener
  alias Jurl.Analytics

  @impl true
  def mount(%{"short_code" => short_code}, _session, socket) do
    # Load link and verify ownership
    case Shortener.get_link_for_identity(short_code, socket) do
      {:ok, link} ->
        if connected?(socket) do
          Analytics.subscribe_to_link(link.id)
        end

        stats = Analytics.get_detailed_stats(link)

        socket =
          socket
          |> assign(:link, link)
          |> assign(:stats, stats)

        {:ok, socket}

      {:error, :not_found} ->
        socket =
          socket
          |> put_flash(:error, "Link not found or access denied.")
          |> redirect(to: ~p"/")

        {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="py-6 px-4 sm:px-6 lg:px-8">
      <div class="max-w-5xl mx-auto">

        <% # Link Details Header %>
        <div class="bg-paper border border-line rounded-lg p-6 mb-8 relative overflow-hidden">
          <div class="absolute top-0 left-0 right-0 h-[2px] bg-accent"></div>
          <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div class="overflow-hidden">
              <h2 class="font-serif text-3xl font-bold text-ink mb-3 truncate" title={@link.original_url}>
                <%= @link.original_url %>
              </h2>
              <div class="flex flex-wrap items-center gap-4 text-xs text-faded uppercase tracking-wider font-semibold">
                <div>
                  <%= gettext("Short URL:") %>
                  <a href={"#{JurlWeb.Endpoint.url()}/#{@link.short_code}"} target="_blank" class="text-accent hover:underline font-mono ml-1 font-bold">
                    <%= JurlWeb.Endpoint.url() %>/<%= @link.short_code %>
                  </a>
                </div>
                <div>•</div>
                <div><%= gettext("Created %{time} ago", time: time_ago_in_words(@link.inserted_at)) %></div>
                <%= if @link.expires_at do %>
                  <div>•</div>
                  <div class="text-red-600 font-bold"><%= gettext("Expires: %{time}", time: Calendar.strftime(@link.expires_at, "%Y-%m-%d %H:%M:%S")) %></div>
                <% end %>
              </div>
            </div>
            <div>
              <a
                href={~p"/links/#{@link.short_code}/print?auto=true"}
                target="_blank"
                class="inline-flex items-center px-4 py-2 border border-line rounded-md shadow-sm text-xs font-bold uppercase tracking-wider text-base bg-ink hover:bg-accent transition-colors gap-1"
              >
                🖨 <%= gettext("Print PDF") %>
              </a>
            </div>
          </div>
        </div>

        <% # Key Metrics %>
        <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 mb-10">
          <div class="bg-paper border border-line rounded-lg p-6 relative overflow-hidden">
            <div class="absolute top-0 left-0 right-0 h-[2px] bg-accent/40"></div>
            <dt class="text-xs font-bold uppercase tracking-wider text-faded"><%= gettext("Total Clicks") %></dt>
            <dd class="mt-2 text-4xl font-serif font-bold text-ink"><%= @stats.total_clicks %></dd>
          </div>

          <div class="bg-paper border border-line rounded-lg p-6 relative overflow-hidden">
            <div class="absolute top-0 left-0 right-0 h-[2px] bg-accent/70"></div>
            <dt class="text-xs font-bold uppercase tracking-wider text-faded"><%= gettext("Unique Visitors (IPs)") %></dt>
            <dd class="mt-2 text-4xl font-serif font-bold text-ink"><%= @stats.unique_visitors %></dd>
          </div>
        </div>

        <% # Breakdown Grid %>
        <div class="grid grid-cols-1 gap-8 md:grid-cols-2">
          <% # Referrers %>
          <div class="bg-paper border border-line rounded-lg p-6">
            <h3 class="font-serif text-2xl font-bold text-ink mb-4"><%= gettext("Traffic Sources") %></h3>
            <%= if @stats.clicks_by_referrer == [] do %>
              <p class="text-faded text-center py-6 text-xs"><%= gettext("No referrer data yet.") %></p>
            <% else %>
              <div class="divide-y divide-line/30">
                <%= for item <- Enum.sort_by(@stats.clicks_by_referrer, & &1.count, :desc) do %>
                  <div class="flex items-center justify-between text-sm py-2">
                    <span class="text-faded truncate max-w-xs" title={item.referrer}><%= item.referrer %></span>
                    <span class="font-semibold text-ink"><%= item.count %></span>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <% # Countries %>
          <div class="bg-paper border border-line rounded-lg p-6">
            <h3 class="font-serif text-2xl font-bold text-ink mb-4"><%= gettext("Geographic Locations") %></h3>
            <%= if @stats.clicks_by_country == [] do %>
              <p class="text-faded text-center py-6 text-xs"><%= gettext("No location data yet.") %></p>
            <% else %>
              <div class="divide-y divide-line/30">
                <%= for item <- Enum.sort_by(@stats.clicks_by_country, & &1.count, :desc) do %>
                  <div class="flex items-center justify-between text-sm py-2">
                    <span class="text-faded"><%= item.country %></span>
                    <span class="font-semibold text-ink"><%= item.count %></span>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <% # Browsers %>
          <div class="bg-paper border border-line rounded-lg p-6">
            <h3 class="font-serif text-2xl font-bold text-ink mb-4"><%= gettext("Browsers") %></h3>
            <%= if @stats.clicks_by_browser == [] do %>
              <p class="text-faded text-center py-6 text-xs"><%= gettext("No browser data yet.") %></p>
            <% else %>
              <div class="divide-y divide-line/30">
                <%= for item <- Enum.sort_by(@stats.clicks_by_browser, & &1.count, :desc) do %>
                  <div class="flex items-center justify-between text-sm py-2">
                    <span class="text-faded"><%= item.browser %></span>
                    <span class="font-semibold text-ink"><%= item.count %></span>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <% # Devices & OS %>
          <div class="bg-paper border border-line rounded-lg p-6">
            <h3 class="font-serif text-2xl font-bold text-ink mb-4"><%= gettext("Devices & Operating Systems") %></h3>
            <div class="grid grid-cols-2 gap-6">
              <div>
                <h4 class="text-xs font-bold uppercase tracking-wider text-ink mb-2 border-b border-line pb-1"><%= gettext("Devices") %></h4>
                <%= if @stats.clicks_by_device == [] do %>
                  <p class="text-faded text-xs"><%= gettext("No data.") %></p>
                <% else %>
                  <div class="divide-y divide-line/20">
                    <%= for item <- Enum.sort_by(@stats.clicks_by_device, & &1.count, :desc) do %>
                      <div class="flex items-center justify-between text-xs py-1.5">
                        <span class="text-faded"><%= item.device_type %></span>
                        <span class="font-semibold text-ink"><%= item.count %></span>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>

              <div>
                <h4 class="text-xs font-bold uppercase tracking-wider text-ink mb-2 border-b border-line pb-1"><%= gettext("OS") %></h4>
                <%= if @stats.clicks_by_os == [] do %>
                  <p class="text-faded text-xs"><%= gettext("No data.") %></p>
                <% else %>
                  <div class="divide-y divide-line/20">
                    <%= for item <- Enum.sort_by(@stats.clicks_by_os, & &1.count, :desc) do %>
                      <div class="flex items-center justify-between text-xs py-1.5">
                        <span class="text-faded"><%= item.os %></span>
                        <span class="font-semibold text-ink"><%= item.count %></span>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:new_click, _click_data}, socket) do
    # Recalculate stats in real time
    stats = Analytics.get_detailed_stats(socket.assigns.link)
    {:noreply, assign(socket, :stats, stats)}
  end

  defp time_ago_in_words(datetime) do
    diff = DateTime.diff(DateTime.utc_now(), datetime, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)}m"
      diff < 86400 -> "#{div(diff, 3600)}h"
      true -> "#{div(diff, 86400)}d"
    end
  end
end
