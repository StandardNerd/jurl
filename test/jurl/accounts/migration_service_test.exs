defmodule Jurl.Accounts.MigrationServiceTest do
  use Jurl.DataCase, async: true
  alias Jurl.Accounts.MigrationService
  alias Jurl.AccountsFixtures
  alias Jurl.Shortener.Link
  
  setup_all do
    # Ensure Limiter/SessionStore are running for clearing sessions
    case GenServer.start_link(Jurl.Anonymous.SessionStore, [], name: Jurl.Anonymous.SessionStore) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
    :ok
  end

  setup do
    user = AccountsFixtures.user_fixture()
    {:ok, user: user}
  end

  describe "claim_anonymous_links/2" do
    test "handles nil anonymous_id", %{user: user} do
      assert {:ok, %{links_migrated: 0}} = MigrationService.claim_anonymous_links(nil, user)
    end
    
    test "migrates links and updates user", %{user: user} do
      anon_id = "migrate_test_anon_1"
      
      # create some links for anon
      Jurl.Repo.insert!(%Link{original_url: "https://a.com", short_code: "a1", anonymous_id: anon_id})
      Jurl.Repo.insert!(%Link{original_url: "https://b.com", short_code: "b2", anonymous_id: anon_id})
      
      Jurl.Anonymous.SessionStore.add_link(anon_id, "a1")
      
      assert {:ok, result} = MigrationService.claim_anonymous_links(anon_id, user)
      assert result.links_migrated == 2
      assert result.user.migrated_anonymous_id == anon_id
      
      links = Jurl.Repo.all(Link)
      Enum.each(links, fn l -> 
        assert l.user_id == user.id 
        assert l.anonymous_id == nil
      end)
      
      # verify session store cleared
      assert Jurl.Anonymous.SessionStore.get_links(anon_id) == []
    end
  end

  describe "merge_anonymous_links/2" do
    test "skips if already migrated", %{user: user} do
      anon_id = "merge_test_anon_2"
      user = Ecto.Changeset.change(user, migrated_anonymous_id: anon_id) |> Jurl.Repo.update!()
      
      assert {:ok, %{links_migrated: 0, message: "Already migrated"}} = MigrationService.merge_anonymous_links(anon_id, user)
    end
    
    test "calls claim_anonymous_links if not migrated", %{user: user} do
      anon_id = "merge_test_anon_3"
      Jurl.Repo.insert!(%Link{original_url: "https://a.com", short_code: "m1", anonymous_id: anon_id})
      
      assert {:ok, result} = MigrationService.merge_anonymous_links(anon_id, user)
      assert result.links_migrated == 1
    end
  end

  describe "preview_migration/1" do
    test "returns count and preview" do
      anon_id = "preview_anon_1"
      Jurl.Repo.insert!(%Link{original_url: "https://p.com", short_code: "p1", anonymous_id: anon_id})
      
      preview = MigrationService.preview_migration(anon_id)
      assert preview.total_links == 1
      assert [%{short_code: "p1", original_url: "https://p.com"}] = preview.preview
    end
  end
end
