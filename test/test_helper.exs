{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()

{ :ok, _ } = EctoStateMc.Repo.start_link
