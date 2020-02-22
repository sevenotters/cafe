defmodule TableTest do
  use ExUnit.Case

  test "register a new user" do
    Seven.EventStore.EventStore.subscribe("TableOpen", self())

    request_id = Seven.Data.Persistence.new_id

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
end
