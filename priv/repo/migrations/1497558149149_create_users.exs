defmodule EctoStateMc.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :state, :string, null: false
      add :confirmed_at, :naive_datetime
    end
  end
end
