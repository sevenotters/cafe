defmodule OrderTest do
  use ExUnit.Case
  import TestHelper

  @table_number "1"
  @invalid_table_number "0"

  setup do
    create_a_table(@table_number, "Bob")
    :ok
  end

  describe "test ordering" do

    test "order to an invalid table" do
      result =
        %Seven.CommandRequest{
          id: Seven.Data.Persistence.new_id,
          command: "PlaceOrder",
          sender: __MODULE__,
          params: %{number: @invalid_table_number, items: [%{type: :food, description: "test", price: 10}]}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == {:table_not_open, "Table not open"}
    end

    test "make an order" do
      result =
        %Seven.CommandRequest{
          id: Seven.Data.Persistence.new_id,
          command: "PlaceOrder",
          sender: __MODULE__,
          params: %{number: @table_number, items: [%{type: :food, description: "test", price: 10}]}
        }
        |> Seven.CommandBus.send_command_request()

      assert result == :managed
    end
  end
end
