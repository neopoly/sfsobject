defmodule SFSObject.EncodeBench do
  use Benchfella

  @empty SFSObject.new

  @sfsobject @empty
  bench "encode empty" do
    SFSObject.encode(@sfsobject)
  end

  @sfsobject @empty |> SFSObject.put_null("a")
  bench "encode null" do
    SFSObject.encode(@sfsobject)
  end

  @sfsobject @empty |> SFSObject.put_int("a", 1)
  bench "encode int" do
    SFSObject.encode(@sfsobject)
  end

  @sfsobject @empty |> SFSObject.put_string("a", "hello world")
  bench "encode string" do
    SFSObject.encode(@sfsobject)
  end

  @sfsobject @empty |> SFSObject.put_int_array("a", [1,2,3])
  bench "encode int array" do
    SFSObject.encode(@sfsobject)
  end

  @sfsobject @empty
    |> SFSObject.put_byte("c", 1)
    |> SFSObject.put_short("a", 13)
    |> SFSObject.put_object("p", SFSObject.new
      |> SFSObject.put_string("c", "User.Me")
      |> SFSObject.put_object("p", SFSObject.new
        |> SFSObject.put_string("username", "foobar")
        |> SFSObject.put_int("rank", 1)
      )
    )
  bench "encode nested object" do
    SFSObject.encode(@sfsobject)
  end
end
