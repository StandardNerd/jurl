defmodule Jurl.Cache.URLCache do
  use GenServer

  @table_name :url_cache
  @max_cache_size 1000

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

  def get_url(short_code) do
    case :ets.lookup(@table_name, short_code) do
      [{^short_code, url, _last_accessed, access_count, metadata}] ->
        # Update access count and timestamp
        now = System.system_time(:second)
        :ets.insert(@table_name, {short_code, url, now, access_count + 1, metadata})
        {:ok, url, metadata[:link_id]}
      [] ->
        {:error, :not_found}
    end
  end

  def put_url(short_code, url, link_id) do
    case :ets.info(@table_name, :size) do
      size when size >= @max_cache_size ->
        evict_least_used()
      _ ->
        :ok
    end

    now = System.system_time(:second)
    metadata = %{link_id: link_id}
    :ets.insert(@table_name, {short_code, url, now, 1, metadata})
    {:ok, url}
  end

  defp evict_least_used do
    case :ets.tab2list(@table_name) do
      [] -> :ok
      entries ->
        # Evict the entry with the lowest access count
        {key, _, _, _, _} = Enum.min_by(entries, fn {_, _, _, access_count, _} -> access_count end)
        :ets.delete(@table_name, key)
    end
  end

  def cache_stats do
    %{
      size: :ets.info(@table_name, :size),
      memory: :ets.info(@table_name, :memory) * :erlang.system_info(:wordsize)
    }
  end
end
