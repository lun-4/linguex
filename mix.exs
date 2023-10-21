defmodule Linguex.MixProject do
  use Mix.Project

  def project do
    [
      app: :linguex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :tesla, :abacus],
      # applications: [
      #   :nostrum, :nosedrum,
      # ],
      mod: {Linguex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7.6"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},

      # {:nostrum, git: "https://github.com/Kraigie/nostrum.git", branch: "master", override: true},
      # use master branch until https://github.com/Kraigie/nostrum/pull/522 is
      # in a pinned release
      # {:nostrum, "~> 0.8"},

      # {:nosedrum, "~> 0.6"},
      # pinning is required until https://github.com/elixir-tesla/tesla/pull/587 is merged
      # {:gun, "~> 2.0", override: true},
      {:tesla, "~> 1.7"},
      {:hackney, "~> 1.17"},
      {:recon, "~> 2.5"},
      {:abacus, "~> 0.4.2"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
