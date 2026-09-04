defmodule Jurl.Anonymous.SessionStoreTest do
  use ExUnit.Case, async: true
  alias Jurl.Anonymous.SessionStore

  setup_all do
    case GenServer.start_link(SessionStore, [], name: SessionStore) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
    :ok
  end

  describe "session management" do
    test "add_link and get_links" do
      anon_id = "session_test_add"
      assert SessionStore.get_links(anon_id) == []
      
      SessionStore.add_link(anon_id, "short1")
      links = SessionStore.get_links(anon_id)
      
      assert length(links) == 1
      assert [%{short_code: "short1", created_at: _}] = links
      
      SessionStore.add_link(anon_id, "short2")
      links2 = SessionStore.get_links(anon_id)
      assert length(links2) == 2
      # The newer link is at the head
      assert hd(links2).short_code == "short2"
    end

    test "get_link_count" do
      anon_id = "session_test_count"
      assert SessionStore.get_link_count(anon_id) == 0
      
      SessionStore.add_link(anon_id, "short1")
      SessionStore.add_link(anon_id, "short2")
      
      assert SessionStore.get_link_count(anon_id) == 2
    end

    test "remove_link" do
      anon_id = "session_test_remove"
      SessionStore.add_link(anon_id, "short1")
      SessionStore.add_link(anon_id, "short2")
      
      SessionStore.remove_link(anon_id, "short1")
      
      links = SessionStore.get_links(anon_id)
      assert length(links) == 1
      assert hd(links).short_code == "short2"
    end

    test "clear_session" do
      anon_id = "session_test_clear"
      SessionStore.add_link(anon_id, "short1")
      assert SessionStore.get_link_count(anon_id) == 1
      
      SessionStore.clear_session(anon_id)
      assert SessionStore.get_links(anon_id) == []
    end

    test "cleanup_expired removes old sessions" do
      anon_id = "session_test_cleanup"
      SessionStore.add_link(anon_id, "short1")
      
      # We manually change the timestamp in ETS to make it look old
      old_time = System.system_time(:second) - (31 * 24 * 60 * 60) # 31 days ago
      [{^anon_id, links, _}] = :ets.lookup(:anonymous_sessions, anon_id)
      :ets.insert(:anonymous_sessions, {anon_id, links, old_time})
      
      deleted_count = SessionStore.cleanup_expired()
      assert deleted_count > 0
      assert SessionStore.get_links(anon_id) == []
    end
  end
end
