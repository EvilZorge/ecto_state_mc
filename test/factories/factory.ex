  defmodule EctoStateMc.Factory do
    use ExMachina.Ecto, repo: EctoStateMc.Repo

    def user_factory do
      %EctoStateMc.User{
        state: "unconfirmed"
      }
    end
  end
