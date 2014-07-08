defmodule SFSObject.MapTest do
  use ExUnit.Case

  test "empty map" do
    map = new_map
    assert SFSObject.Map.size(map) == 0
    assert SFSObject.Map.empty?(map)
  end

  defp new_map do 
    SFSObject.Map.new
  end
end
