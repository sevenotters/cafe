defmodule Cafe.Aggregate.Table do
  use Seven.Otters.Aggregate, aggregate_field: :number

  defstruct number: nil, waiter: nil

  @open_table_command "OpenTable"
  @open_table_validation [
    :map,
    fields: [
      number: [:string],
      waiter: [:string]
    ]
  ]

  @table_open_event "TableOpen"

  @moduledoc """
    Table aggregate.
    Responds to commands:
    - #{@open_table_command}
  """

  defp init_state, do: %__MODULE__{}

  @spec route(String.t(), any) :: {:routed, Map.y(), atom} | {:invalid, Map.t()}
  def route(@open_table_command, params) do
    cmd = %{
      number: params[:number],
      waiter: params[:waiter]
    }

    @open_table_command
    |> Seven.Otters.Command.create(cmd)
    |> validate(@open_table_validation)
  end

  defp pre_handle_command(_command, _state), do: :ok

  @spec handle_command(Map.t(), any) :: {:managed, List.t()}
  defp handle_command(%Seven.Otters.Command{type: @open_table_command} = command, _state) do
  event = %{
    number: command.payload.number,
    waiter: command.payload.waiter
  }

  {:managed, [create_event(@table_open_event, %{v1: event})]}
  end

  @spec handle_event(Map.t(), any) :: any
  defp handle_event(%Seven.Otters.Event{type: @table_open_event} = event, state) do
    %{ state | number: event.payload.v1.number, waiter: event.payload.v1.waiter }
  end
end
