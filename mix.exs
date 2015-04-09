defmodule PlugRc.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_rc,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :plug],
     mod: {PlugRc, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:poison, "1.3.1"},
      {:plug, "~> 0.11.1", path: "../plug", override: true},
      # cowboy: "~> 1.0",
      # {:elli, "~> 1.0.3", github: "knutin/elli"},
      {:elli, git: "git@github.com:zampino/elli.git", ref: "88_fix_chunk_loop", override: true},
      plug_cors: "~> 0.7.1"
    ]
  end
end
