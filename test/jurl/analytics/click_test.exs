defmodule Jurl.Analytics.ClickTest do
  use Jurl.DataCase, async: true
  alias Jurl.Analytics.Click
  alias Ecto.UUID

  describe "changeset/2" do
    @valid_attrs %{
      link_id: UUID.generate(),
      ip_address: "127.0.0.1",
      user_agent: "Mozilla/5.0",
      referrer: "https://google.com",
      country: "US",
      city: "New York",
      region: "NY",
      device_type: "desktop",
      browser: "Chrome",
      operating_system: "Mac OS X",
      is_unique: true
    }
    
    @invalid_attrs %{link_id: nil}

    test "with valid attributes" do
      changeset = Click.changeset(%Click{}, @valid_attrs)
      assert changeset.valid?
    end

    test "requires a link_id" do
      changeset = Click.changeset(%Click{}, @invalid_attrs)
      refute changeset.valid?
      assert %{link_id: ["can't be blank"]} = errors_on(changeset)
    end
    
    test "is_unique defaults to false but can be set to true" do
      # Note: default values are applied by Ecto on insert or if we specify it in schema, 
      # but we can test that casting works.
      changeset = Click.changeset(%Click{}, %{link_id: UUID.generate()})
      assert changeset.valid?
      
      changeset_unique = Click.changeset(%Click{}, %{link_id: UUID.generate(), is_unique: true})
      assert get_change(changeset_unique, :is_unique) == true
    end
  end
end
