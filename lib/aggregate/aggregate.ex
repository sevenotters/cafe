defmodule Cafe.Aggregate.Aggregate do

  @spec validate(Map, Map, atom) :: Tuple
  def validate(command, schema, module) do
    case Ve.validate(command.payload, schema) do
      {:ok, _} -> {:routed, command, module}
      {:error, reasons} -> {:routed_but_invalid, reasons |> List.first()}
    end
  end
end
