defmodule ServeTest do
  use ExUnit.Case
  import TestHelper

  @invalid_table_number "0"

  describe "test serving" do

    test "serving to an invalid table" do
      table_number = create_a_table("Bob")
      order_a_drink(table_number, "beer_1", 10)

      [order] = get_an_userved_order(table_number, "beer_1")

      result =
        %Seven.CommandRequest{
          id: Seven.Data.Persistence.new_id,
          command: "ServeDrinks",
          sender: __MODULE__,
          params: %{number: @invalid_table_number, order_id: order.order_id}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == {:table_not_open, "Table not open"}
    end

    test "serve a drinks order" do
      table_number = create_a_table("Bob")
      order_a_drink(table_number, "beer_1", 10)

      [order] = get_an_userved_order(table_number, "beer_1")

      result =
        %Seven.CommandRequest{
          id: Seven.Data.Persistence.new_id,
          command: "ServeDrinks",
          sender: __MODULE__,
          params: %{number: table_number, order_id: order.order_id}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == :managed

      Seven.Test.Helper.wait()

      {:ok, [%Cafe.Projection.Orders{number: ^table_number, served: true}]} = Cafe.Projection.Orders.query(:served, table_number)
    end

    test "serve twice a drinks order" do
      table_number = create_a_table("Bob")
      order_a_drink(table_number, "beer_1", 10)

      [order] = get_an_userved_order(table_number, "beer_1")

      # First time
      result =
        %Seven.CommandRequest{
          id: Seven.Data.Persistence.new_id,
          command: "ServeDrinks",
          sender: __MODULE__,
          params: %{number: table_number, order_id: order.order_id}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == :managed

      # Second time
      result =
        %Seven.CommandRequest{
          id: Seven.Data.Persistence.new_id,
          command: "ServeDrinks",
          sender: __MODULE__,
          params: %{number: table_number, order_id: order.order_id}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == {:routed_but_invalid, "already_served"}
    end
  end
end
