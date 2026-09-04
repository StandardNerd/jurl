defmodule Jurl.Anonymous.LimiterTest do
  use ExUnit.Case, async: true
  alias Jurl.Anonymous.Limiter

  # Ensure the GenServer is started for the ETS tables
  setup_all do
    # It might already be started by the application supervisor,
    # but we can check and start if needed.
    case GenServer.start_link(Limiter, [], name: Limiter) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
    :ok
  end

  describe "limits" do
    test "check_link_count allows up to 50 links" do
      anon_id = "anon_link_count_test"
      assert Limiter.check_link_count(anon_id) == :ok
      
      # Simulate adding 50 links
      Enum.each(1..50, fn _ -> Limiter.increment_link_count(anon_id) end)
      
      assert Limiter.check_link_count(anon_id) == {:error, :max_links}
    end

    test "check_rate_limit allows up to 10 requests per minute" do
      anon_id = "anon_rate_limit_test"
      
      # Should allow 10 requests
      Enum.each(1..10, fn _ -> 
        assert Limiter.check_rate_limit(anon_id) == :ok
      end)
      
      # 11th request should fail
      assert Limiter.check_rate_limit(anon_id) == {:error, :rate_limit}
    end

    test "check_limits checks both counts and rate limits" do
      anon_id_rate = "anon_limits_rate"
      Enum.each(1..10, fn _ -> Limiter.check_rate_limit(anon_id_rate) end)
      assert Limiter.check_limits(anon_id_rate) == {:error, :rate_limit}

      anon_id_count = "anon_limits_count"
      Enum.each(1..50, fn _ -> Limiter.increment_link_count(anon_id_count) end)
      assert Limiter.check_limits(anon_id_count) == {:error, :max_links}
      
      anon_id_ok = "anon_limits_ok"
      assert Limiter.check_limits(anon_id_ok) == :ok
    end
  end

  describe "prompts and features" do
    test "upgrade_prompt/1 returns correct messages" do
      assert Limiter.upgrade_prompt(:max_links) =~ "reached the limit"
      assert Limiter.upgrade_prompt(:rate_limit) =~ "too quickly"
      assert Limiter.upgrade_prompt(:feature_restricted) =~ "requires an account"
    end

    test "feature lists" do
      assert :basic_shorten in Limiter.allowed_features()
      assert :api_access in Limiter.restricted_features()
    end
  end
end
