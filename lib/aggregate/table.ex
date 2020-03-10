defmodule Cafe.Aggregate.Table do
  use Seven.Otters.Aggregate, aggregate_field: :number

  alias Seven.Data.Persistence

  defstruct number: nil, waiter: nil, orders: []

  @open_table_command "OpenTable"
  @open_table_validation [
    :map,
    fields: [
      number: [:string],
      waiter: [:string]
    ]
  ]

  @place_order_command "PlaceOrder"
  @place_order_validation [
    :map,
    fields: [
      number: [:string],
      order_id: [:string],
      items: [:list, min: 1, of: [
        :map,
        fields: [
          type: [:atom],
          description: [:string],
          price: [:integer]
        ]
      ]]
    ]
  ]

  @table_open_event "TableOpen"
  @order_placed_event "OrderPlaced"

  @moduledoc """
    Table aggregate.
    Responds to commands:
    - #{@open_table_command}
    - #{@place_order_command}
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

  def route(@place_order_command, params) do
    cmd = %{
      number: params[:number],
      order_id: Persistence.new_id() |> Persistence.printable_id(),
      items: params[:items]
    }

    @place_order_command
    |> Seven.Otters.Command.create(cmd)
    |> validate(@place_order_validation)
  end

  def route(_command, _params), do: :not_routed

  defp pre_handle_command(_command, _state), do: :ok

  @spec handle_command(Map.t(), any) :: {:managed, List.t()}
  defp handle_command(%Seven.Otters.Command{type: @open_table_command} = command, _state) do
    event = %{
      number: command.payload.number,
      waiter: command.payload.waiter
    }

    {:managed, [create_event(@table_open_event, %{v1: event})]}
  end

  defp handle_command(%Seven.Otters.Command{type: @place_order_command}, %{number: nil}) do
    {:table_not_open, "Table not open"}
  end

  defp handle_command(%Seven.Otters.Command{type: @place_order_command} = command, _state) do
    event = %{
      number: command.payload.number,
      order: %{
        id: command.payload.order_id,
        items: command.payload.items
      }
    }

    {:managed, [create_event(@order_placed_event, %{v1: event})]}
  end

  @spec handle_event(Map.t(), any) :: any
  defp handle_event(%Seven.Otters.Event{type: @table_open_event} = event, state) do
    %{ state | number: event.payload.v1.number, waiter: event.payload.v1.waiter }
  end

  defp handle_event(%Seven.Otters.Event{type: @order_placed_event} = event, %{orders: orders} = state) do
    %{ state | orders: [event.payload.v1.order] ++ orders }
  end
end
