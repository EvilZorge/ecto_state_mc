defmodule EctoStateMc do
  defmacro state_machine(column, body) do
    quote do
      def smc_column do
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
          {:ok, nil} -> nil
          {:ok, state} -> String.to_atom(state)
          _ -> nil
        end
      end

      def validate_state_transition(changeset, from_states, to_state) do
        cr_state = current_state(changeset.data)

        if can_change_state?(cr_state, to_state, from_states) do
          changeset
        else
          Ecto.Changeset.add_error(changeset, smc_column(),
            "You can't move state from :#{cr_state} to :#{to_state}")
        end
      end

      defp can_change_state?(cr_state, to_state, from_states) do
        from_states = if all_states?(from_states), do: states(), else: from_states

        Enum.member?(from_states, cr_state) && state_defined?(to_state)
      end

      defp all_states?(from_states) do
        from_states == [:all_states]
      end

      unquote(body[:do])
    end
  end

  defmacro defstate(states) do
    quote do
      def states do
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
      def unquote(:"#{event}")(struct) do
        %{from: from_states, to: to_state} = unquote(options)
        struct
        |> change_struct(to_state)
        |> validate_state_transition(from_states, to_state)
        |> unquote(callback).()
      end

      defp change_struct(%Ecto.Changeset{} = changeset, to_state) do
        Ecto.Changeset.put_change(changeset, smc_column(), Atom.to_string(to_state))
      end

      defp change_struct(record, to_state) do
        Ecto.Changeset.change(record, %{smc_column() => Atom.to_string(to_state)})
      end

      def unquote(:"can_#{event}?")(record) do
        %{from: from_states, to: to_state} = unquote(options)
        record
        |> current_state()
        |> can_change_state?(to_state, from_states)
      end
    end
  end

  defp default_callback do
    quote do: fn(changeset) -> changeset end
  end
end
