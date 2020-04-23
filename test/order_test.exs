defmodule OrderTest do
  use ExUnit.Case
  import TestHelper

  @invalid_table_number "0"

  describe "test ordering" do
    test "order to an invalid table" do
      result =
        %Seven.CommandRequest{
          id: Seven.Data.Persistence.new_id(),
          command: "PlaceOrder",
          sender: __MODULE__,
          params: %{number: @invalid_table_number, type: :food, items: [%{description: "test", price: 10}]}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == {:table_not_open, "Table not open"}
    end

    test "make an order" do
      table_number = create_a_table("Bob")

      result =
        %Seven.CommandRequest{
          id: Seven.Data.Persistence.new_id(),
          command: "PlaceOrder",
          sender: __MODULE__,
          params: %{number: table_number, type: :food, items: [%{description: "test", price: 10}]}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == :managed

      Seven.Test.Helper.wait()

      {:ok, [%Cafe.Projection.Orders{number: ^table_number, served: false}]} = Cafe.Projection.Orders.query(:unserved, table_number)
    end
  end
end
