defmodule PlugRc.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_rc,
     version: "0.1.0",
     elixir: "~> 1.1",
     deps: deps]
  end

  def application do
    [applications: [:logger, :plug],
     mod: {PlugRc, []}]
  end

  defp deps do
    [
      {:hashids, "~> 2.0"},
      {:pastelli, "0.2.3", github: "zampino/pastelli", branch: :toward_pastelli_phoenix},
      # {:pastelli, path: "../pastelli"},
      {:poison, "~> 1.3.0"},
      {:plug_cors, "~> 0.7.0"}
    ]
  end
end
