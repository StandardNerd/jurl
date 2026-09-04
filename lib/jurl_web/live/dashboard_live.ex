defmodule JurlWeb.DashboardLive do
  use JurlWeb, :live_view

  alias Jurl.Shortener
  alias Jurl.Analytics

  @impl true
  def mount(_params, _session, socket) do
    identity = socket.assigns.identity

    if connected?(socket) do
      case identity.type do
        :anonymous ->
          Analytics.subscribe_to_anonymous_links(identity.anonymous_id)
        :authenticated ->
          Analytics.subscribe_to_user_links(identity.user_id)
      end
      # Also subscribe to links created during this session
      Phoenix.PubSub.subscribe(Jurl.PubSub, "links:created")
    end

    links = Shortener.list_links_for_identity(socket, %{page: 1, page_size: 100}).entries
    total_clicks = Enum.reduce(links, 0, fn l, acc -> acc + l.click_count end)
    active_visitors = Analytics.get_active_visitors(identity)
    click_history = Analytics.get_click_history(identity)

    socket =
      socket
      |> assign(:links, links)
      |> assign(:total_clicks, total_clicks)
      |> assign(:active_visitors, active_visitors)
      |> assign(:click_history, click_history)
      |> assign(:is_anonymous, identity.type == :anonymous)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="py-6 px-4 sm:px-6 lg:px-8">
      <div class="max-w-6xl mx-auto">
        <% # Header / Title %>
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-10">
          <div>
            <h1 class="text-4xl font-serif font-bold text-ink tracking-tight sm:text-5xl">
              <%= gettext("Real-time analytics") %><span class="text-accent">.</span>
            </h1>
            <p class="mt-1 text-xs text-faded uppercase tracking-wider font-semibold">
              <%= if @is_anonymous do %>
                <%= gettext("Temporary session links • Live stream enabled") %>
              <% else %>
                <%= gettext("Logged in as %{email} • Live stream enabled", email: @current_user.email) %>
              <% end %>
            </p>
          </div>
          <div class="flex gap-3">
            <a
              href={~p"/"}
              class="inline-flex items-center px-4 py-2.5 border border-transparent rounded-md text-xs font-bold uppercase tracking-wider text-base bg-ink hover:bg-accent transition-colors"
            >
              <%= gettext("Shorten New URL") %>
            </a>
          </div>
        </div>

        <% # Stats Grid %>
        <div class="grid grid-cols-1 gap-6 sm:grid-cols-3 mb-10">
          <div class="bg-paper border border-line rounded-lg p-6 relative overflow-hidden">
            <div class="absolute top-0 left-0 right-0 h-[2px] bg-accent/40"></div>
            <dt class="text-xs font-bold uppercase tracking-wider text-faded"><%= gettext("Total Links") %></dt>
            <dd class="mt-2 text-4xl font-serif font-bold text-ink"><%= length(@links) %></dd>
          </div>

          <div class="bg-paper border border-line rounded-lg p-6 relative overflow-hidden">
            <div class="absolute top-0 left-0 right-0 h-[2px] bg-accent/70"></div>
            <dt class="text-xs font-bold uppercase tracking-wider text-faded"><%= gettext("Total Clicks") %></dt>
            <dd class="mt-2 text-4xl font-serif font-bold text-ink"><%= @total_clicks %></dd>
          </div>

          <div class="bg-paper border border-line rounded-lg p-6 relative overflow-hidden">
            <div class="absolute top-0 left-0 right-0 h-[2px] bg-accent"></div>
            <dt class="text-xs font-bold uppercase tracking-wider text-faded"><%= gettext("Active Visitors (5m)") %></dt>
            <dd class="mt-2 text-4xl font-serif font-bold text-ink"><%= @active_visitors %></dd>
          </div>
        </div>

        <div class="grid grid-cols-1 gap-8 lg:grid-cols-3">
          <% # Links List (Left/Middle) %>
          <div class="bg-paper border border-line rounded-lg p-6 lg:col-span-2">
            <h3 class="font-serif text-2xl font-bold text-ink mb-4"><%= gettext("Your Shortened Links") %></h3>
            <%= if @links == [] do %>
              <div class="text-center py-12 text-faded text-sm">
                <%= gettext("No links created yet.") %> <a href={~p"/"} class="text-accent hover:underline font-bold"><%= gettext("Shorten your first URL") %></a> <%= gettext("to see analytics.") %>
              </div>
            <% else %>
              <div class="overflow-x-auto">
                <table class="min-w-full">
                  <thead>
                    <tr class="border-b border-line">
                      <th class="px-4 py-3 text-left text-xs font-bold uppercase tracking-wider text-ink bg-base rounded-l-md"><%= gettext("Original URL") %></th>
                      <th class="px-4 py-3 text-left text-xs font-bold uppercase tracking-wider text-ink bg-base"><%= gettext("Short Code") %></th>
                      <th class="px-4 py-3 text-left text-xs font-bold uppercase tracking-wider text-ink bg-base"><%= gettext("Clicks") %></th>
                      <th class="px-4 py-3 text-right text-xs font-bold uppercase tracking-wider text-ink bg-base rounded-r-md"><%= gettext("Actions") %></th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-line/30">
                    <%= for link <- @links do %>
                      <tr>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-ink max-w-xs truncate" title={link.original_url}>
                          <%= link.original_url %>
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm font-mono text-accent">
                          <a href={~p"/#{link.short_code}"} target="_blank" class="hover:underline">
                            <%= link.short_code %>
                          </a>
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-ink">
                          <%= link.click_count %>
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-right text-xs font-bold uppercase tracking-wider space-x-3">
                          <a href={~p"/links/#{link.short_code}/print?auto=true"} target="_blank" class="text-ink hover:text-accent">
                            🖨 <%= gettext("Print PDF") %>
                          </a>
                          <a href={~p"/links/#{link.short_code}"} class="text-accent hover:text-ink">
                            <%= gettext("Details") %>
                          </a>
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>
            <% end %>
          </div>

          <% # Live Clicks Feed (Right) %>
          <div class="bg-paper border border-line rounded-lg p-6">
            <h3 class="font-serif text-2xl font-bold text-ink mb-4 flex items-center gap-2">
              <span class="flex h-2 w-2 relative">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-accent/75"></span>
                <span class="relative inline-flex rounded-full h-2 w-2 bg-accent"></span>
              </span>
              <%= gettext("Live Click Stream") %>
            </h3>
            <%= if @click_history == [] do %>
              <div class="text-center py-12 text-faded text-xs">
                <%= gettext("Waiting for clicks... share your links to watch live traffic stream in.") %>
              </div>
            <% else %>
              <div class="overflow-y-auto max-h-[450px] pr-1 space-y-3">
                <%= for click <- @click_history do %>
                  <div class="border border-line rounded-lg bg-base p-4 hover:border-accent transition-all duration-300">
                    <div class="flex items-start justify-between gap-2">
                      <div class="flex items-center gap-2">
                        <span class="text-lg">
                          <%= case click.device_type do
                            "Mobile" -> "📱"
                            "Tablet" -> "📟"
                            _ -> "💻"
                          end %>
                        </span>
                        <div>
                          <p class="text-[10px] text-faded uppercase tracking-wider font-mono">
                            <%= gettext("Click on /%{code}", code: click.link && click.link.short_code) %>
                          </p>
                          <p class="text-xs font-semibold text-ink mt-0.5">
                            <%= click.country %><%= if click.city, do: ", #{click.city}" %>
                          </p>
                        </div>
                      </div>
                      <span class="text-[9px] text-faded uppercase tracking-wider">
                        <%= gettext("%{time} ago", time: time_ago_in_words(click.inserted_at)) %>
                      </span>
                    </div>
                    <div class="border-t border-line/10 mt-2 pt-2 flex items-center justify-between text-[10px] text-faded">
                      <span><%= gettext("%{browser} on %{os}", browser: click.browser, os: click.operating_system) %></span>
                      <%= if click.referrer != "Direct" do %>
                        <span class="truncate max-w-[100px]" title={click.referrer}><%= click.referrer %></span>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:new_click, click_data}, socket) do
    # click_data is the Click schema struct, preloaded with link or we can load it
    click = if Ecto.assoc_loaded?(click_data.link) do
      click_data
    else
      Jurl.Repo.preload(click_data, :link)
    end

    # Increment total clicks
    socket = socket |> update(:total_clicks, &(&1 + 1))

    # Append to history
    socket = socket |> update(:click_history, fn history ->
      [click | history] |> Enum.take(100)
    end)

    # Recalculate active visitors
    socket = socket |> assign(:active_visitors, Analytics.get_active_visitors(socket.assigns.identity))

    # Update click counts in links list
    socket = socket |> update(:links, fn links ->
      Enum.map(links, fn link ->
        if link.id == click.link_id do
          %{link | click_count: link.click_count + 1}
        else
          link
        end
      end)
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:link_created, link}, socket) do
    # Check if this link belongs to this identity
    identity = socket.assigns.identity
    belongs? = case identity.type do
      :anonymous -> link.anonymous_id == identity.anonymous_id
      :authenticated -> link.user_id == identity.user_id
    end

    socket = if belongs? do
      socket |> update(:links, fn links -> [link | links] end)
    else
      socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("export_csv", _params, socket) do
    if socket.assigns.identity.type == :authenticated do
      csv_data = Analytics.export_csv(socket.assigns.links)
      {:noreply, push_event(socket, "download", %{data: csv_data, filename: "analytics.csv"})}
    else
      {:noreply,
       socket
       |> put_flash(:info, "Create an account to export analytics!")
       |> redirect(to: ~p"/users/register")}
    end
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
