# EctoStateMc

State machine for Ecto.

## Installation

Add `ecto_state_mc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ecto_state_mc, "~> 0.1.0"}]
end
```

## How to use?
Example:

```elixir
defmodule Example.User do
  use Example.Web, :model

  import EctoStateMc

  schema "users" do
    field :state, :string, default: "waiting"
  end

  state_machine :state do
    defstate [:waiting, :approved, :rejected]
    defevent :approve, %{from: [:waiting, :rejected], to: :approved}, fn(changeset) ->
      changeset
      |> Example.Repo.update()
    end
    defevent :reject, %{from: [:waiting, :approved], to: :rejected}
  end
end
```

## How to run?

You can use it with records
```elixir
user = Example.Repo.get(Example.User, 1)
Example.User.current_state(user) # => get current state
Example.User.can_approve?(user)  # => check event approve
Example.User.can_reject?(user)   # => check event reject
Example.User.approve(user)       # => call event approve to change state to approved
Example.User.reject(user)        # => call event reject to change state to rejected
```
or with changesets

```elixir
changeset = Example.Repo.get(Example.User, 1) |> Ecto.Changeset.change()
Example.User.current_state(changeset) # => get current state
Example.User.can_approve?(changeset)  # => check event approve
Example.User.can_reject?(changeset)   # => check event reject
Example.User.approve(changeset)       # => call event approve to change state to approved
Example.User.reject(changeset)        # => call event reject to change state to rejected
```


