defmodule SFSObject.DecodeBench do
  use Benchfella

  @empty SFSObject.new

  @sfsobject @empty
  @data SFSObject.encode(@sfsobject)
  bench "decode empty" do
    SFSObject.decode(@data)
  end

  @sfsobject @empty |> SFSObject.put_null("a")
  @data SFSObject.encode(@sfsobject)
  bench "decode null" do
    SFSObject.decode(@data)
  end

  @sfsobject @empty |> SFSObject.put_int("a", 1)
  @data SFSObject.encode(@sfsobject)
  bench "decode int" do
    SFSObject.decode(@data)
  end

  @sfsobject @empty |> SFSObject.put_string("a", "hello world")
  @data SFSObject.encode(@sfsobject)
  bench "decode string" do
    SFSObject.decode(@data)
  end

  @sfsobject @empty |> SFSObject.put_int_array("a", [1,2,3])
  @data SFSObject.encode(@sfsobject)
  bench "decode int array" do
    SFSObject.decode(@data)
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
  @data SFSObject.encode(@sfsobject)
  bench "decode nested object" do
    SFSObject.decode(@data)
  end
end
