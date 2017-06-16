defmodule EctoStateMc do
  defmacro state_machine(column, body) do
    quote do
      def smc_column() do
        unquote(column)
      end

      def current_state(%Ecto.Changeset{} = changeset) do
        case Ecto.Changeset.get_field(changeset, smc_column()) do
          nil -> nil
          state -> String.to_atom(state)
        end
      end
      def current_state(record) do
        case Map.fetch(record, smc_column()) do
          {:ok, state} -> String.to_atom(state)
          _ -> nil
        end
      end

      def validate_state_transition(changeset, from_states, to_state) do
        cr_state = current_state(changeset.data)
        if Enum.member?(from_states, cr_state) && state_defined?(to_state) do
          changeset
        else
          Ecto.Changeset.add_error(changeset, smc_column(),
            "You can't move state from :#{cr_state} to :#{to_state}")
        end
      end

      unquote(body[:do])
    end
  end

  defmacro defstate(states) do
    quote do
      def states() do
        unquote(states)
      end

      def state_defined?(state) do
        states()
        |> Enum.member?(state)
      end
    end
  end

  defmacro defevent(event, options, callback \\ default_callback()) do
    quote do
      def unquote(:"#{event}")(%Ecto.Changeset{} = changeset) do
        %{from: from_states, to: to_state} = unquote(options)
        changeset
        |> Ecto.Changeset.put_change(smc_column(), Atom.to_string(to_state))
        |> validate_state_transition(from_states, to_state)
        |> unquote(callback).()
      end
      def unquote(:"#{event}")(record) do
        %{from: from_states, to: to_state} = unquote(options)
        record
        |> Ecto.Changeset.change(%{smc_column() => Atom.to_string(to_state)})
        |> validate_state_transition(from_states, to_state)
        |> unquote(callback).()
      end

      def unquote(:"can_#{event}?")(record) do
        %{from: from_states, to: to_state} = unquote(options)
        cr_state = current_state(record)
        Enum.member?(from_states, cr_state) && state_defined?(to_state)
      end
    end
  end

  defp default_callback do
    quote do: fn(changeset) -> changeset end
  end
end
