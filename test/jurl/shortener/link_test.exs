defmodule Jurl.Shortener.LinkTest do
  use Jurl.DataCase, async: true

  alias Jurl.Shortener.Link

  describe "changeset/2" do
    @valid_attrs %{original_url: "https://example.com"}
    @invalid_attrs %{original_url: nil}

    test "with valid attributes" do
      changeset = Link.changeset(%Link{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Link.changeset(%Link{}, @invalid_attrs)
      refute changeset.valid?
      assert %{original_url: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates url format" do
      changeset = Link.changeset(%Link{}, %{original_url: "not-a-url"})
      refute changeset.valid?
      assert %{original_url: ["Must be a valid HTTP or HTTPS URL"]} = errors_on(changeset)
      
      changeset_ftp = Link.changeset(%Link{}, %{original_url: "ftp://example.com"})
      refute changeset_ftp.valid?
    end

    test "generates a short code if none is provided" do
      changeset = Link.changeset(%Link{}, @valid_attrs)
      assert changeset.valid?
      assert get_change(changeset, :short_code)
      assert String.length(get_change(changeset, :short_code)) == 3
    end

    test "uses custom alias as short code if provided" do
      changeset = Link.changeset(%Link{}, %{original_url: "https://example.com", custom_alias: "my-alias"})
      assert changeset.valid?
      assert get_change(changeset, :short_code) == "my-alias"
    end

    test "hashes password if provided" do
      changeset = Link.changeset(%Link{}, %{original_url: "https://example.com", password_hash: "secret"})
      assert changeset.valid?
      assert hashed = get_change(changeset, :password_hash)
      assert Bcrypt.verify_pass("secret", hashed)
    end

    test "validates expires_at is in the future" do
      past_date = DateTime.utc_now() |> DateTime.add(-3600, :second)
      changeset = Link.changeset(%Link{}, %{original_url: "https://example.com", expires_at: past_date})
      refute changeset.valid?
      assert %{expires_at: ["must be in the future"]} = errors_on(changeset)

      future_date = DateTime.utc_now() |> DateTime.add(3600, :second)
      changeset_future = Link.changeset(%Link{}, %{original_url: "https://example.com", expires_at: future_date})
      assert changeset_future.valid?
    end

    test "rejects custom alias with invalid characters" do
      for alias <- ["my alias!", "with space", "dot.com", "ünïcode", "a/b"] do
        changeset = Link.changeset(%Link{}, %{original_url: "https://example.com", custom_alias: alias})
        refute changeset.valid?
        assert %{custom_alias: [msg]} = errors_on(changeset)
        assert msg =~ "letters, numbers, hyphens and underscores"
      end
    end

    test "rejects custom alias outside length bounds" do
      too_short = Link.changeset(%Link{}, %{original_url: "https://example.com", custom_alias: "ab"})
      refute too_short.valid?
      assert %{custom_alias: ["should be at least 3 character(s)"]} = errors_on(too_short)

      too_long = Link.changeset(%Link{}, %{original_url: "https://example.com", custom_alias: String.duplicate("a", 33)})
      refute too_long.valid?
      assert %{custom_alias: ["should be at most 32 character(s)"]} = errors_on(too_long)

      boundary = Link.changeset(%Link{}, %{original_url: "https://example.com", custom_alias: String.duplicate("a", 32)})
      assert boundary.valid?
    end

    test "rejects reserved words as custom alias" do
      for alias <- ["admin", "api", "new", "login", "users", "dashboard"] do
        changeset = Link.changeset(%Link{}, %{original_url: "https://example.com", custom_alias: alias})
        refute changeset.valid?
        assert %{custom_alias: ["is reserved"]} = errors_on(changeset)
      end
    end

    test "reservation applies case-insensitively" do
      changeset = Link.changeset(%Link{}, %{original_url: "https://example.com", custom_alias: "ADMIN"})
      refute changeset.valid?
      assert %{custom_alias: ["is reserved"]} = errors_on(changeset)
    end

    test "downcases custom alias before storing" do
      changeset = Link.changeset(%Link{}, %{original_url: "https://example.com", custom_alias: "House12"})
      assert changeset.valid?
      assert get_change(changeset, :custom_alias) == "house12"
      assert get_change(changeset, :short_code) == "house12"
    end

    test "rejects duplicate custom alias (case-insensitive)" do
      {:ok, _link} =
        %Link{}
        |> Link.changeset(%{original_url: "https://example.com", custom_alias: "housetaken"})
        |> Repo.insert()

      changeset = Link.changeset(%Link{}, %{original_url: "https://another.com", custom_alias: "HouseTaken"})
      refute changeset.valid?
      assert %{short_code: ["has already been taken"]} = errors_on(changeset)
      assert {:error, _} = Repo.insert(changeset)
    end
  end
end
