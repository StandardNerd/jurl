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
  end
end
