defmodule PlugRc.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_rc,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :plug],
     mod: {PlugRc, []}]
  end

  defp deps do
    [
      {:plug, "~> 0.12.0"}, #, path: "../plug", override: true},
      {:pastelli, github: "zampino/pastelli"},
      {:poison, "~> 1.3.0"},
      {:plug_cors, "~> 0.7.0"}
    ]
  end
end
