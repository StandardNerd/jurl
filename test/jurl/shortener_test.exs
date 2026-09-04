defmodule Jurl.ShortenerTest do
  use Jurl.DataCase, async: true
  alias Jurl.Shortener
  alias Jurl.Accounts.Identity

  setup_all do
    # Ensure Limiter/SessionStore are running
    case GenServer.start_link(Jurl.Anonymous.Limiter, [], name: Jurl.Anonymous.Limiter) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
    case GenServer.start_link(Jurl.Anonymous.SessionStore, [], name: Jurl.Anonymous.SessionStore) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
    :ok
  end

  describe "create_link/2" do
    test "creates anonymous link" do
      identity = Identity.new_anonymous("test_anon")
      {:ok, link} = Shortener.create_link(identity, %{original_url: "https://example.com"})
      
      assert link.anonymous_id == "test_anon"
      assert link.owner_type == "anonymous"
      assert link.user_id == nil
    end
    
    test "creates authenticated link" do
      user = Jurl.AccountsFixtures.user_fixture()
      identity = Identity.new_authenticated(user)
      
      {:ok, link} = Shortener.create_link(identity, %{original_url: "https://example.com"})
      
      assert link.user_id == user.id
      assert link.owner_type == "authenticated"
      assert link.anonymous_id == nil
    end
  end
  
  describe "list_links_for_identity/2" do
    test "lists only links for given identity" do
      anon_id1 = "list_anon_1"
      anon_id2 = "list_anon_2"
      
      id1 = Identity.new_anonymous(anon_id1)
      id2 = Identity.new_anonymous(anon_id2)
      
      Shortener.create_link(id1, %{original_url: "https://example.com"})
      Shortener.create_link(id2, %{original_url: "https://example.com"})
      
      result = Shortener.list_links_for_identity(id1)
      assert length(result.entries) == 1
      assert hd(result.entries).anonymous_id == anon_id1
    end
  end

  describe "get_link_for_identity/2" do
    test "returns ok and link if owned" do
      identity = Identity.new_anonymous("get_anon")
      {:ok, link} = Shortener.create_link(identity, %{original_url: "https://example.com"})
      
      assert {:ok, fetched_link} = Shortener.get_link_for_identity(link.short_code, identity)
      assert fetched_link.id == link.id
    end
    
    test "returns not_found if not owned" do
      id1 = Identity.new_anonymous("get_anon_1")
      id2 = Identity.new_anonymous("get_anon_2")
      {:ok, link} = Shortener.create_link(id1, %{original_url: "https://example.com"})
      
      assert {:error, :not_found} = Shortener.get_link_for_identity(link.short_code, id2)
    end
  end

  describe "deactivate_link/1" do
    test "deactivates link" do
      identity = Identity.new_anonymous("deactivate_anon")
      {:ok, link} = Shortener.create_link(identity, %{original_url: "https://example.com"})
      
      assert link.is_active == true
      
      {:ok, deactivated} = Shortener.deactivate_link(link)
      assert deactivated.is_active == false
      
      # Should not show up in lists
      result = Shortener.list_links_for_identity(identity)
      assert result.entries == []
    end
  end
end
