defmodule SFSObject.Binary.Macro do
  defmacro defencode(name, format) do
    quote do
      def encode({unquote(name), v}, output) do
        var!(v) = v
        output <> <<unquote_splicing(format)>>
      end
    end
  end

  defmacro defencode(name, format, do: block) do
    quote do
      defp transform(unquote(name), [val|rest], output) do
        var!(val) = val
        data = <<unquote_splicing(block)>>
        transform(unquote(name), rest, output <> data)
      end

      def encode({unquote(name), v}, output) do
        var!(v) = v
        data = transform(unquote(name), v, output)
        output <> <<unquote_splicing(format), data::binary>>
      end
    end
  end
end
