defmodule Jurl.Cache.URLCacheTest do
  use ExUnit.Case, async: true
  alias Jurl.Cache.URLCache

  setup_all do
    case GenServer.start_link(URLCache, [], name: URLCache) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
    :ok
  end

  setup do
    # Clear cache before each test if needed
    :ets.delete_all_objects(:url_cache)
    :ok
  end

  describe "caching" do
    test "put and get url" do
      assert URLCache.get_url("short1") == {:error, :not_found}
      
      assert {:ok, "https://example.com"} = URLCache.put_url("short1", "https://example.com", "link_id_1")
      
      assert {:ok, "https://example.com", "link_id_1"} = URLCache.get_url("short1")
    end

    test "access count updates on get" do
      URLCache.put_url("short2", "https://example.com", "link_id_2")
      
      [{_, _, _, count1, _}] = :ets.lookup(:url_cache, "short2")
      assert count1 == 1
      
      URLCache.get_url("short2")
      [{_, _, _, count2, _}] = :ets.lookup(:url_cache, "short2")
      assert count2 == 2
    end
    
    test "cache_stats" do
      URLCache.put_url("short_stat", "https://example.com", "link_id_stat")
      stats = URLCache.cache_stats()
      assert Map.has_key?(stats, :size)
      assert Map.has_key?(stats, :memory)
      assert stats.size >= 1
    end
  end
end
