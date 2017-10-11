defmodule EctoStateMc.User do
  use Ecto.Schema

  import EctoStateMc

  state_machine :state do
    defstate [:unconfirmed, :confirmed, :blocked, :admin, :moderator]
    defevent :confirm, %{from: [:unconfirmed], to: :confirmed}, fn(changeset) ->
      Ecto.Changeset.put_change(changeset, :confirmed_at, Ecto.DateTime.utc)
    end
    defevent :block, %{from: [:confirmed, :admin], to: :blocked}
    defevent :make_admin, %{from: [:confirmed], to: :admin}
    defevent :make_moderator, %{from: [:all_states], to: :moderator}, fn(changeset) ->
      Ecto.Changeset.put_change(changeset, :confirmed_at, Ecto.DateTime.utc)
    end
  end

  schema "users" do
    field :state, :string
  end
end
