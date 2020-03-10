Seven.Test.Helper.drop_events()
Seven.Test.Helper.clean_projections()

ExUnit.start()

defmodule TestHelper do

  @spec create_a_table(String, String) :: any
  def create_a_table(number, waiter) do
    %Seven.CommandRequest{
      id: Seven.Data.Persistence.new_id,
      command: "OpenTable",
      sender: __MODULE__,
      params: %{number: number, waiter: waiter}
    }
    |> Seven.CommandBus.send_command_request()

    Seven.Test.Helper.wait()
  end
end
