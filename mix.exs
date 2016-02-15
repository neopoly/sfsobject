defmodule SFSObject.Mixfile do
  use Mix.Project

  def project do
    [app: :sfsobject,
     version: "0.0.3",
     elixir: "~> 1.0",
     name: "sfsobject",
     description: "Encode/decode SFSObjects",
     package: package,
     deps: deps]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:benchfella, "~> 0.3.0", only: :dev}
    ]
  end

  defp package do
    [
      contributors: ["Peter Suschlik"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/splattael/sfsobject"}
    ]
  end
end
