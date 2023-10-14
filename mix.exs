defmodule Linguex.MixProject do
  use Mix.Project

  def project do
    [
      app: :linguex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [:nostrum, :nosedrum, :tesla],
      mod: {Linguex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.8"},
      {:nosedrum, "~> 0.6"},
      # pinning is required until https://github.com/elixir-tesla/tesla/pull/587 is merged
      {:gun, "~> 2.0", override: true},
      {:tesla, "~> 1.7"},
      {:hackney, "~> 1.17"},
      {:jason, ">= 1.0.0"},
      {:recon, "~> 2.5"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
