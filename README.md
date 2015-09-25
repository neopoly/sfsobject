# SFSObject

Encode/decode `SFSObject`s in Elixir.
See http://www.smartfoxserver.com/

:construction: :warning:
**This project is in very stage. Things will change!**

## Usage

```elixir
original = SFSObject.new
  |> SFSObject.put_string("some key", "hello world")
  |> SFSObject.put_int("meaning_of_life", 42)
binary = SFSObject.encode(object)
^original = SFSObject.decode(binary)
```

## Tests

    $ mix deps.get
    $ mix test.watch

## Release

* increase `version:` in `mix.exs`
* `git commit -am "Release vVERSION"`
* `git tag vVERSION`
* `mix hex.publish`
