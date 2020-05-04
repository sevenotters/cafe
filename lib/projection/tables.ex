defmodule Cafe.Projection.Tables do
  @moduledoc """
  List of all available tables.
  """

  import Cafe.Projection.Projection

  @table_open_event "TableOpen"

  use Seven.Otters.Projection,
    listener_of_events: [
      @table_open_event
    ]

  defstruct number: nil, waiter: nil

  @spec init_state() :: List.t()
  defp init_state, do: []

  @spec handle_event(Seven.Otters.Event.t(), List.t()) :: List.t()
  defp handle_event(%Seven.Otters.Event{type: @table_open_event} = event, tables) do
    new_table = %__MODULE__{number: event.payload.v1.number, waiter: event.payload.v1.waiter}

    tables ++ [new_table]
  end

  @table_number_validation [:string]

  defp pre_handle_query(:table, params, _tables), do: validate(params, @table_number_validation)

  defp handle_query(:table, table_number, tables) do
    tables |> Enum.filter(fn t -> t.number == table_number end)
  end
end
