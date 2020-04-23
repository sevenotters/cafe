Seven.Test.Helper.drop_events()
Seven.Test.Helper.clean_projections()

ExUnit.start()

defmodule TestHelper do
  @spec create_a_table(String) :: String
  def create_a_table(waiter) do
    table_number = Seven.Data.Persistence.new_id() |> Seven.Data.Persistence.printable_id()

    %Seven.CommandRequest{
      id: Seven.Data.Persistence.new_id(),
      command: "OpenTable",
      sender: __MODULE__,
      params: %{number: table_number, waiter: waiter}
    }
    |> Seven.CommandBus.send_command_request()

    Seven.Test.Helper.wait()

    table_number
  end

  @spec order_a_drink(String, String, Integer) :: any
  def order_a_drink(number, description, price) do
    %Seven.CommandRequest{
      id: Seven.Data.Persistence.new_id(),
      command: "PlaceOrder",
      sender: __MODULE__,
      params: %{number: number, type: :drink, items: [%{description: description, price: price}]}
    }
    |> Seven.CommandBus.send_command_request()

    Seven.Test.Helper.wait()
  end

  @spec get_an_userved_order(String, String) :: [Cafe.Projection.Orders]
  def get_an_userved_order(number, description) do
    Cafe.Projection.Orders.state()
    |> find_table(number)
    |> filter_userved()
    |> filter_by_item(description)
  end

  defp find_table(orders, number), do: orders |> Enum.filter(fn o -> o.number == number end)

  defp filter_userved(orders), do: orders |> Enum.filter(fn o -> not o.served end)

  defp filter_by_item(orders, description) do
    orders
    |> Enum.filter(fn o ->
      not (Enum.find(o.items, fn i -> i.description == description end) |> is_nil())
    end)
  end
end
