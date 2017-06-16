defmodule EctoStateMc.EctoCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoStateMc.Repo)
  end
end
