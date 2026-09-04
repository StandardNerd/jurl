defmodule JurlWeb.LinkBuilderLive do
  use JurlWeb, :live_view

  alias Jurl.Shortener
  alias Jurl.Anonymous.Limiter

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:url_input, "")
      |> assign(:custom_alias, "")
      |> assign(:shortened_url, nil)
      |> assign(:created_link, nil)
      |> assign(:error, nil)
      |> assign(:links, [])
      |> assign(:upgrade_prompt, nil)
      |> load_existing_links()
      |> assign_limits()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="py-6 px-4 sm:px-6 lg:px-8">
      <div class="max-w-3xl mx-auto">
        <% # Header / Title %>
        <div class="text-center mb-10">
          <h1 class="text-5xl font-serif font-bold text-ink tracking-tight sm:text-6xl">
            <%= gettext("Shorten your links") %><span class="text-accent">.</span>
          </h1>
          <p class="mt-3 text-md text-faded max-w-md mx-auto">
            <%= gettext("A minimalist URL shortener.") %>
          </p>
          <div class="hidden md:block mt-6 max-w-xl mx-auto overflow-hidden rounded-xl border border-line shadow-sm bg-paper">
            <img
              src={~p"/images/hero.png"}
              alt="Visual illustration of long URL shortening to jurl.ch/foo"
              class="w-full h-auto object-cover"
            />
          </div>
        </div>

        <% # URL Input Form %>
        <div class="bg-paper border border-line rounded-lg p-6 mb-8">
          <form phx-submit="shorten" class="space-y-4">
            <div>
              <label for="url" class="block text-xs font-bold uppercase tracking-wider text-ink mb-1">
                <%= gettext("Long URL") %>
              </label>
              <div class="mt-1">
                <input
                  type="url"
                  name="url"
                  id="url"
                  required
                  value={@url_input}
                  placeholder="https://example.com/very-long-url-that-needs-shortening"
                  class="block w-full rounded-md border-line bg-base shadow-sm focus:border-accent focus:ring-accent text-ink placeholder-faded/60 text-sm"
                />
              </div>
            </div>

            <%= if @error do %>
              <div class="rounded-md bg-red-50 p-4 border border-red-200">
                <p class="text-sm text-red-800"><%= @error %></p>
              </div>
            <% end %>

            <button
              type="submit"
              class="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-xs font-bold uppercase tracking-wider text-base bg-ink hover:bg-accent focus:outline-none transition-colors"
            >
              <%= gettext("Shorten URL") %>
            </button>
          </form>
        </div>

        <% # Result Display %>
        <%= if @shortened_url do %>
          <div class="bg-paper border border-line rounded-lg p-6 mb-8 border-l-4 border-l-accent">
            <h3 class="font-serif text-2xl font-bold text-ink mb-2"><%= gettext("Your Shortened URL") %></h3>
            <div class="flex flex-wrap items-center gap-2">
              <input
                type="text"
                id="shortened-url-input"
                value={@shortened_url}
                readonly
                class="flex-1 min-w-[200px] block w-full rounded-md border-line bg-base text-sm font-mono"
              />
              <button
                phx-click="copy_to_clipboard"
                phx-value-text={@shortened_url}
                class="inline-flex items-center px-4 py-2 border border-line rounded-md shadow-sm text-xs font-bold uppercase tracking-wider text-ink bg-base hover:bg-paper transition-colors"
              >
                <%= gettext("Copy") %>
              </button>
              <a
                href={~p"/links/#{@shortened_url |> String.split("/") |> List.last()}/print?auto=true"}
                target="_blank"
                class="inline-flex items-center px-4 py-2 border border-line rounded-md shadow-sm text-xs font-bold uppercase tracking-wider text-base bg-ink hover:bg-accent transition-colors gap-1"
              >
                🖨 <%= gettext("Print PDF") %>
              </a>
            </div>
            <%= if @created_link do %>
              <p class="mt-2 text-xs text-faded truncate" title={@created_link.original_url}>
                (<%= truncate(@created_link.original_url, 60) %>)
              </p>
            <% end %>
          </div>
        <% end %>

        <% # Recent Links List %>
        <%= if @links != [] do %>
          <div class="bg-paper border border-line rounded-lg p-6 mb-8">
            <h3 class="font-serif text-2xl font-bold text-ink mb-4"><%= gettext("Your Recent Links") %></h3>
            <div class="space-y-3">
              <%= for link <- @links do %>
                <div class="flex items-center justify-between border-b border-line pb-2">
                  <div class="truncate max-w-md">
                    <p class="font-mono text-sm font-semibold"><%= build_short_url(@socket, link.short_code) %></p>
                    <p class="text-xs text-faded">(<%= truncate(link.original_url, 60) %>)</p>
                  </div>
                  <div class="flex items-center gap-3">
                    <button
                      phx-click="copy_to_clipboard"
                      phx-value-text={build_short_url(@socket, link.short_code)}
                      class="inline-flex items-center px-4 py-2 border border-line rounded-md shadow-sm text-xs font-bold uppercase tracking-wider text-ink bg-base hover:bg-paper transition-colors"
                    >
                      <%= gettext("Copy") %>
                    </button>
                    <a
                      href={~p"/links/#{link.short_code}/print?auto=true"}
                      target="_blank"
                      class="text-xs font-bold uppercase tracking-wider text-accent hover:text-ink"
                    >
                      🖨 <%= gettext("Print PDF") %>
                    </a>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <% # Upgrade Prompt %>
        <%= if @upgrade_prompt do %>
          <div class="bg-accent rounded-lg shadow-lg p-6 mb-8 text-base" id="upgrade-prompt">
            <div class="flex items-start justify-between">
              <div>
                <h3 class="font-serif text-2xl font-bold"><%= gettext("Unlock More Features") %></h3>
                <p class="mt-2 text-sm opacity-90"><%= @upgrade_prompt %></p>
                <div class="mt-4 flex gap-3">
                  <a href={~p"/users/register"} class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-xs font-bold uppercase tracking-wider text-accent bg-base hover:bg-paper transition-colors">
                    <%= gettext("Sign Up Free") %>
                  </a>
                  <a href={~p"/users/log_in"} class="inline-flex items-center px-4 py-2 border border-base rounded-md text-xs font-bold uppercase tracking-wider text-base hover:bg-base/10 transition-colors">
                    <%= gettext("Sign In") %>
                  </a>
                </div>
              </div>
              <button phx-click="dismiss_upgrade" class="text-base/80 hover:text-base text-lg">
                ✕
              </button>
            </div>
          </div>
        <% end %>

      </div>
    </div>
    """
  end

  @impl true
  def handle_event("shorten", params, socket) do
    socket = ensure_identity(socket, %{})
    url = Map.get(params, "url") || Map.get(params, "original_url") || ""
    custom_alias = Map.get(params, "alias") || Map.get(params, "custom_alias")

    url = String.trim(to_string(url))
    custom_alias = if custom_alias in ["", nil], do: nil, else: String.trim(to_string(custom_alias))

    if url == "" do
      {:noreply, assign(socket, :error, "Please enter a valid URL")}
    else
      attrs = %{
        original_url: url,
        custom_alias: custom_alias
      }

      case Shortener.create_link(socket, attrs) do
        {:ok, link} ->
          short_url = build_short_url(socket, link.short_code)

          socket =
            socket
            |> assign(:shortened_url, short_url)
            |> assign(:created_link, link)
            |> assign(:error, nil)
            |> assign(:url_input, "")
            |> assign(:custom_alias, "")
            |> load_existing_links()
            |> assign_limits()

          {:noreply, socket}

        {:error, :max_links} ->
          {:noreply,
           socket
           |> assign(:error, nil)
           |> assign(:upgrade_prompt, Limiter.upgrade_prompt(:max_links))}

        {:error, :rate_limit} ->
          {:noreply, assign(socket, :error, Limiter.upgrade_prompt(:rate_limit))}

        {:error, %Ecto.Changeset{} = changeset} ->
          error_msg =
            Enum.map(changeset.errors, fn {field, {msg, _}} ->
              "#{field} #{msg}"
            end)
            |> Enum.join(", ")

          {:noreply, assign(socket, :error, error_msg)}

        {:error, reason} when is_binary(reason) ->
          {:noreply, assign(socket, :error, reason)}

        {:error, reason} ->
          {:noreply, assign(socket, :error, "Could not shorten URL: #{inspect(reason)}")}
      end
    end
  end

  @impl true
  def handle_event("copy_to_clipboard", %{"text" => text}, socket) do
    {:noreply, push_event(socket, "clipboard_copy", %{text: text})}
  end

  @impl true
  def handle_event("dismiss_upgrade", _params, socket) do
    {:noreply, assign(socket, :upgrade_prompt, nil)}
  end

  defp ensure_identity(socket, session) do
    if Map.has_key?(socket.assigns, :identity) and socket.assigns.identity != nil do
      socket
    else
      identity =
        case socket.assigns[:current_user] do
          %Jurl.Accounts.User{} = user ->
            Jurl.Accounts.Identity.new_authenticated(user)

          _ ->
            anon_id = (session && session["anonymous_user_id"]) || Ecto.UUID.generate()
            Jurl.Accounts.Identity.new_anonymous(anon_id)
        end

      assign(socket, :identity, identity)
    end
  end

  defp load_existing_links(socket) do
    links = Shortener.list_links_for_identity(socket, %{page: 1, page_size: 10})
    assign(socket, :links, links.entries)
  end

  defp assign_limits(socket) do
    identity = socket.assigns.identity

    if identity.type == :anonymous do
      link_count = Jurl.Anonymous.SessionStore.get_link_count(identity.anonymous_id)

      assign(socket,
        links_remaining: max(0, 50 - link_count),
        is_anonymous: true
      )
    else
      assign(socket,
        links_remaining: :unlimited,
        is_anonymous: false
      )
    end
  end

  defp build_short_url(_socket, short_code) do
    "#{JurlWeb.Endpoint.url()}/#{short_code}"
  end

  defp truncate(text, limit) when is_binary(text) do
    if String.length(text) > limit do
      String.slice(text, 0, limit) <> "..."
    else
      text
    end
  end

  defp truncate(_text, _limit), do: ""
end
