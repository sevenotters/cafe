defmodule TableTest do
  use ExUnit.Case

  test "register a new table" do
    Seven.EventStore.EventStore.subscribe("TableOpen", self())

    request_id = Seven.Data.Persistence.new_id()

    result =
      %Seven.CommandRequest{
        id: request_id,
        command: "OpenTable",
        sender: __MODULE__,
        params: %{number: "42", waiter: "Bob"}
      }
      |> Seven.CommandBus.send_command_request()

    refute result == :not_managed, "Command is not managed by anyone"

    assert_receive %Seven.Otters.Event{type: "TableOpen", request_id: ^request_id, correlation_module: Cafe.Aggregate.Table}
  end

  test "register a new table and check if it is in list" do
    table_number = "43"

    %Seven.CommandRequest{
      id: Seven.Data.Persistence.new_id(),
      command: "OpenTable",
      sender: __MODULE__,
      params: %{number: table_number, waiter: "Bob"}
    }
    |> Seven.CommandBus.send_command_request()

    Seven.Test.Helper.wait()

    # method 1
    {:ok, module} = Seven.Projections.get_projection("Tables")
    tables = module.filter(fn c -> c.number == table_number end)
    assert length(tables) == 1

    # method 2
    [%Cafe.Projection.Tables{number: "43", waiter: "Bob"}] = Cafe.Projection.Tables.query(:table, table_number)
  end
end
