defmodule Jurl.Anonymous.SessionStore do
  use GenServer

  @table_name :anonymous_sessions
  @session_ttl 30 * 24 * 60 * 60  # 30 days in seconds

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    :ets.new(@table_name, [
      :named_table,
      :public,
      :set,
      read_concurrency: true,
      write_concurrency: true
    ])
    {:ok, %{}}
  end

  def add_link(nil, _short_code), do: :ok
  def add_link(anonymous_id, short_code) do
    links = get_links(anonymous_id)
    timestamp = System.system_time(:second)
    new_link = %{
      short_code: short_code,
      created_at: timestamp
    }

    :ets.insert(@table_name, {anonymous_id, [new_link | links], timestamp})
  end

  def get_links(nil), do: []
  def get_links(anonymous_id) do
    case :ets.lookup(@table_name, anonymous_id) do
      [{^anonymous_id, links, _}] -> links
      [] -> []
    end
  end

  def get_link_count(nil), do: 0
  def get_link_count(anonymous_id) do
    anonymous_id |> get_links() |> length()
  end

  def remove_link(nil, _short_code), do: :ok
  def remove_link(anonymous_id, short_code) do
    links = get_links(anonymous_id)
    updated_links = Enum.reject(links, &(&1.short_code == short_code))
    timestamp = System.system_time(:second)
    :ets.insert(@table_name, {anonymous_id, updated_links, timestamp})
  end

  def clear_session(nil), do: :ok
  def clear_session(anonymous_id) do
    :ets.delete(@table_name, anonymous_id)
  end

  # Cleanup expired anonymous sessions
  def cleanup_expired do
    now = System.system_time(:second)
    cutoff = now - @session_ttl

    :ets.select_delete(@table_name, [
      {{:"$1", :_, :"$2"}, [{:<, :"$2", cutoff}], [true]}
    ])
  end
end
