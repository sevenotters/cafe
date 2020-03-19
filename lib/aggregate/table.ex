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
      type: [:atom, in: [:drink, :food]],
      items: [:list, min: 1, of: [
        :map,
        fields: [
          description: [:string],
          price: [:integer]
        ]
      ]]
    ]
  ]

  @serve_drinks_command "ServeDrinks"
  @serve_drinks_validation [
    :map,
    fields: [
      number: [:string],
      order_id: [:string]
    ]
  ]

  @table_open_event "TableOpen"
  @order_placed_event "OrderPlaced"
  @drinks_served_event "DrinksServed"

  @moduledoc """
    Table aggregate.
    Responds to commands:
    - #{@open_table_command}
    - #{@place_order_command}
    - #{@serve_drinks_command}
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
      type: params[:type],
      items: params[:items],
      served: false
    }

    @place_order_command
    |> Seven.Otters.Command.create(cmd)
    |> validate(@place_order_validation)
  end

  def route(@serve_drinks_command, params) do
    cmd = %{
      number: params[:number],
      order_id: params[:order_id]
    }

    @serve_drinks_command
    |> Seven.Otters.Command.create(cmd)
    |> validate(@serve_drinks_validation)
  end

  def route(_command, _params), do: :not_routed

  @spec pre_handle_command(Map.t(), any) :: :ok | {atom, any}
  defp pre_handle_command(%Seven.Otters.Command{type: @open_table_command}, %{number: nil}), do: :ok
  defp pre_handle_command(%Seven.Otters.Command{type: @open_table_command}, _state), do: {:table_already_open, "Table already open"}
  defp pre_handle_command(_command, %{number: nil}), do: {:table_not_open, "Table not open"}

  defp pre_handle_command(%Seven.Otters.Command{type: @serve_drinks_command} = command, %{orders: orders}) do
    case find_order(:drink, command.payload.order_id, orders) do
      nil             -> {:routed_but_invalid, "no_drinks_order"}
      %{served: true} -> {:routed_but_invalid, "already_served"}
      _               -> :ok
    end
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

  defp handle_command(%Seven.Otters.Command{type: @place_order_command} = command, _state) do
    event = %{
      number: command.payload.number,
      order: %{
        id: command.payload.order_id,
        type: command.payload.type,
        items: command.payload.items,
        served: command.payload.served
      }
    }

    {:managed, [create_event(@order_placed_event, %{v1: event})]}
  end

  defp handle_command(%Seven.Otters.Command{type: @serve_drinks_command} = command, %{orders: orders}) do
    order = find_order(:drink, command.payload.order_id, orders) |> assert_is_not_null()

    event = %{
      number: command.payload.number,
      order: %{order | served: true}
    }

    {:managed, [create_event(@drinks_served_event, %{v1: event})]}
  end

  @spec handle_event(Map.t(), any) :: any
  defp handle_event(%Seven.Otters.Event{type: @table_open_event} = event, state) do
    %{ state | number: event.payload.v1.number, waiter: event.payload.v1.waiter }
  end

  defp handle_event(%Seven.Otters.Event{type: @order_placed_event} = event, %{orders: orders} = state) do
    %{ state | orders: [event.payload.v1.order] ++ orders }
  end

  defp handle_event(%Seven.Otters.Event{type: @drinks_served_event} = event, %{orders: orders} = state) do
    i = Enum.find_index(orders, &(&1.id == event.payload.v1.order.id))
    put_in(state, [Access.key!(:orders), Access.at(i), :served], event.payload.v1.order.served)
  end

  #
  # Private
  #
  defp find_order(type, order_id, orders) do
    orders |> Enum.find(fn o -> o.id == order_id and o.type == type end)
  end

  defp assert_is_not_null(i) when is_nil(i), do: raise "is not null assertion failed"
  defp assert_is_not_null(i), do: i
end
