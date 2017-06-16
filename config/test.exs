use Mix.Config

config :ecto_state_mc, EctoStateMc.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: "localhost",
  username: "optimizeplayer",
  password: "123",
  database: "ecto_state_mc_test",
  pool: Ecto.Adapters.SQL.Sandbox

