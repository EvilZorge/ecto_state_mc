defmodule EctoStateMc.Mixfile do
  use Mix.Project

  def project do
    [app: :ecto_state_mc,
     version: "0.1.3",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     description: "State machine for Ecto.",
     deps: deps(),
     aliases: aliases(),
     package: package()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support", "test/factories"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [
     {:ecto, ">= 2.0.0"},
     {:postgrex,   ">= 0.0.0", only: :test},
     {:ex_machina, "~> 1.0.0", only: :test},
     {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      name: :ecto_state_mc,
      files: ["lib/ecto_state_mc.ex", "mix.exs"],
      maintainers: ["Kirill Chernobai"],
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/evilzorge/ecto_state_mc"
      }
    ]
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
