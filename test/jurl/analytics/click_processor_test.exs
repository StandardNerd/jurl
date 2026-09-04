defmodule Jurl.Analytics.ClickProcessorTest do
  use Jurl.DataCase, async: false
  alias Jurl.Analytics.ClickProcessor
  alias Jurl.Shortener.Link
  
  setup_all do
    case GenServer.start_link(ClickProcessor, [], name: ClickProcessor) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
    :ok
  end

  setup do
    ClickProcessor.clear_state()
    Ecto.Adapters.SQL.Sandbox.allow(Jurl.Repo, self(), Process.whereis(ClickProcessor))

    # Create a link to test against
    link = %Link{original_url: "https://example.com", short_code: "test1", click_count: 0}
           |> Jurl.Repo.insert!()
    
    {:ok, link: link}
  end

  describe "track_click/2" do
    test "buffers and flushes clicks", %{link: link} do
      click_data = %{
        ip: "127.0.0.1",
        user_agent: "Mozilla/5.0",
        referrer: "Direct"
      }
      
      # Subscribe to pubsub to catch the broadcast
      Phoenix.PubSub.subscribe(Jurl.PubSub, "analytics:#{link.id}")
      
      ClickProcessor.track_click(link.id, click_data)
      
      # Force flush
      send(Process.whereis(ClickProcessor), :flush)
      
      # Assert the broadcast was received
      assert_receive {:new_click, click}, 1000
      assert click.link_id == link.id
      assert click.ip_address == "127.0.0.1"
      
      # Wait a bit for db insert to finish
      Process.sleep(100)
      
      # Assert click count was incremented
      updated_link = Jurl.Repo.get!(Link, link.id)
      assert updated_link.click_count == 1
      
      # Assert click record was created
      clicks = Jurl.Repo.all(Jurl.Analytics.Click)
      assert length(clicks) == 1
      db_click = hd(clicks)
      assert db_click.link_id == link.id
      assert db_click.country == "Local"
    end
  end
end
