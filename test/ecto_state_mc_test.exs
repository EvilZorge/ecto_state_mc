defmodule EctoStateMcTest do
  use ExUnit.Case, async: true

  import EctoStateMc.Factory

  alias EctoStateMc.User

  setup_all do
    {
      :ok,
      unconfirmed_user: insert(:user, %{state: "unconfirmed"}),
      confirmed_user:   insert(:user, %{state: "confirmed"}),
      blocked_user:     insert(:user, %{state: "blocked"}),
      admin:            insert(:user, %{state: "admin"}),
      moderator:        insert(:user, %{state: "moderator"})
    }
  end

  describe "events" do
    test "#confirm", context do
      changeset = User.confirm(context[:unconfirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.state     == "confirmed"
      assert Map.keys(changeset.changes) == ~w(confirmed_at state)a

      changeset = User.confirm(context[:confirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :confirmed to :confirmed", []}]

      changeset = User.confirm(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :blocked to :confirmed", []}]

      changeset = User.confirm(context[:admin])
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :admin to :confirmed", []}]
    end

    test "#block", context do
      changeset = User.block(context[:unconfirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :unconfirmed to :blocked", []}]

      changeset = User.block(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.state     == "blocked"

      changeset = User.block(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :blocked to :blocked", []}]

      changeset = User.block(context[:admin])
      assert changeset.valid?            == true
      assert changeset.changes.state     == "blocked"
    end

    test "#make_admin", context do
      changeset = User.make_admin(context[:unconfirmed_user])
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :unconfirmed to :admin", []}]

      changeset = User.make_admin(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.state     == "admin"

      changeset = User.make_admin(context[:blocked_user])
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :blocked to :admin", []}]

      changeset = User.make_admin(context[:admin])
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :admin to :admin", []}]
    end
  end

  describe "can_?" do
    test "#can_confirm?", context do
      assert User.can_confirm?(context[:unconfirmed_user])    == true
      assert User.can_confirm?(context[:confirmed_user])      == false
      assert User.can_confirm?(context[:blocked_user])        == false
      assert User.can_confirm?(context[:admin])               == false
    end

    test "#can_block?", context do
      assert User.can_block?(context[:unconfirmed_user])      == false
      assert User.can_block?(context[:confirmed_user])        == true
      assert User.can_block?(context[:blocked_user])          == false
      assert User.can_block?(context[:admin])                 == true
    end

    test "#can_make_admin?", context do
      assert User.can_make_admin?(context[:unconfirmed_user]) == false
      assert User.can_make_admin?(context[:confirmed_user])   == true
      assert User.can_make_admin?(context[:blocked_user])     == false
      assert User.can_make_admin?(context[:admin])            == false
    end
  end

  test "#states" do
    assert User.states() == [:unconfirmed, :confirmed, :blocked, :admin, :moderator]
  end

  describe "#changeset events" do
    test "#confirm", context do
      changeset = Ecto.Changeset.change(context[:unconfirmed_user]) |> User.confirm()
      assert changeset.valid?            == true
      assert changeset.changes.state     == "confirmed"
      assert Map.keys(changeset.changes) == ~w(confirmed_at state)a

      changeset = Ecto.Changeset.change(context[:confirmed_user]) |> User.confirm()
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :confirmed to :confirmed", []}]

      changeset = Ecto.Changeset.change(context[:blocked_user]) |> User.confirm()
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :blocked to :confirmed", []}]

      changeset = Ecto.Changeset.change(context[:admin]) |> User.confirm()
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :admin to :confirmed", []}]
    end

    test "#block", context do
      changeset = Ecto.Changeset.change(context[:unconfirmed_user]) |> User.block()
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :unconfirmed to :blocked", []}]

      changeset = Ecto.Changeset.change(context[:confirmed_user]) |> User.block()
      assert changeset.valid?            == true
      assert changeset.changes.state     == "blocked"

      changeset = Ecto.Changeset.change(context[:blocked_user]) |> User.block()
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :blocked to :blocked", []}]

      changeset = Ecto.Changeset.change(context[:admin]) |> User.block()
      assert changeset.valid?            == true
      assert changeset.changes.state     == "blocked"
    end

    test "#make_admin", context do
      changeset = Ecto.Changeset.change(context[:unconfirmed_user]) |> User.make_admin()
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :unconfirmed to :admin", []}]

      changeset = Ecto.Changeset.change(context[:confirmed_user]) |> User.make_admin()
      assert changeset.valid?            == true
      assert changeset.changes.state     == "admin"

      changeset = Ecto.Changeset.change(context[:blocked_user]) |> User.make_admin()
      assert changeset.errors == [state: {"You can't move state from :blocked to :admin", []}]

      changeset = Ecto.Changeset.change(context[:admin]) |> User.make_admin()
      assert changeset.valid? == false
      assert changeset.errors == [state: {"You can't move state from :admin to :admin", []}]
    end
  end

  describe "#changeset can_?" do
    test "#can_confirm?", context do
      assert Ecto.Changeset.change(context[:unconfirmed_user]) |> User.can_confirm?() == true
      assert Ecto.Changeset.change(context[:confirmed_user]) |> User.can_confirm?() == false
      assert Ecto.Changeset.change(context[:blocked_user]) |> User.can_confirm?() == false
      assert Ecto.Changeset.change(context[:admin]) |> User.can_confirm?() == false
    end

    test "#can_block?", context do
      assert Ecto.Changeset.change(context[:unconfirmed_user]) |> User.can_block?() == false
      assert Ecto.Changeset.change(context[:confirmed_user]) |> User.can_block?() == true
      assert Ecto.Changeset.change(context[:blocked_user]) |> User.can_block?() == false
      assert Ecto.Changeset.change(context[:admin]) |> User.can_block?() == true
    end

    test "#can_make_admin?", context do
      assert Ecto.Changeset.change(context[:unconfirmed_user]) |> User.can_make_admin?() == false
      assert Ecto.Changeset.change(context[:confirmed_user]) |> User.can_make_admin?() == true
      assert Ecto.Changeset.change(context[:blocked_user]) |> User.can_make_admin?() == false
      assert Ecto.Changeset.change(context[:admin]) |> User.can_make_admin?() == false
    end
  end

  describe "options" do
    test "all_states?", context do
      changeset = User.make_moderator(context[:unconfirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.state     == "moderator"
      assert Map.keys(changeset.changes) == ~w(confirmed_at state)a

      changeset = User.make_moderator(context[:confirmed_user])
      assert changeset.valid?            == true
      assert changeset.changes.state     == "moderator"
      assert Map.keys(changeset.changes) == ~w(confirmed_at state)a

      changeset = User.make_moderator(context[:blocked_user])
      assert changeset.valid?            == true
      assert changeset.changes.state     == "moderator"
      assert Map.keys(changeset.changes) == ~w(confirmed_at state)a

      changeset = User.make_moderator(context[:admin])
      assert changeset.valid?            == true
      assert changeset.changes.state     == "moderator"
      assert Map.keys(changeset.changes) == ~w(confirmed_at state)a
    end

    test "all_states? with same state", context do
      changeset = User.make_moderator(context[:moderator])
      assert changeset.valid?  == true
      assert Map.keys(changeset.changes) == ~w(confirmed_at)a
    end
  end
end
