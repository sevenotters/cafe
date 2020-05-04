defmodule Cafe.Projection.Projection do

  @spec validate(Map, Map) :: :ok | any
  def validate(params, schema) do
    case Ve.validate(params, schema) do
      {:ok, _} -> :ok
      err -> err
    end
  end
end
