defmodule SFSObject.Map do
  defstruct data: %{}

  def new, do: %__MODULE__{}

  def size(map) do
    Map.size(map.data)
  end

  def empty?(map), do: __MODULE__.size(map) == 0
end
