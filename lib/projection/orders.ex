defmodule Cafe.Projection.Orders do
  @moduledoc """
  List of all orders in any status.
  """
  @order_placed_event "OrderPlaced"
  @drinks_served_event "DrinksServed"

  use Seven.Otters.Projection,
    listener_of_events: [
      @order_placed_event,
      @drinks_served_event
    ]

  defstruct order_id: nil, number: nil, items: nil, served: false

  @spec initial_state() :: List.t()
  defp initial_state, do: []

  @spec handle_event(Seven.Otters.Event.t(), List.t()) :: List.t()
  defp handle_event(%Seven.Otters.Event{type: @order_placed_event} = event, orders) do
    order = %__MODULE__{
      order_id: event.payload.v1.order.id,
      number: event.payload.v1.number,
      items: event.payload.v1.order.items
    }

    orders ++ [order]
  end

  defp handle_event(%Seven.Otters.Event{type: @drinks_served_event} = event, orders) do
    i = Enum.find_index(orders, &(&1.order_id == event.payload.v1.order.id))
    order = Enum.find(orders, nil, &(&1.order_id == event.payload.v1.order.id))
    order = %{order | served: event.payload.v1.order.served}
    List.insert_at(orders, i, order)
  end

  @table_number_validation [:string]

  defp pre_handle_query(:served, params, _tables), do: validate(params, @table_number_validation)
  defp pre_handle_query(:unserved, params, _tables), do: validate(params, @table_number_validation)
  defp pre_handle_query(:all, _params, _tables), do: :ok

  defp handle_query(:served, table_number, orders) do
    orders |> Enum.filter(fn t -> t.number == table_number and t.served end)
  end

  defp handle_query(:unserved, table_number, orders) do
    orders |> Enum.filter(fn t -> t.number == table_number and not t.served end)
  end

  defp handle_query(:all, _params, orders), do: orders

  defp handle_filter(filter_func, orders), do: orders |> Enum.filter(filter_func)
  defp handle_state(orders), do: orders
end
