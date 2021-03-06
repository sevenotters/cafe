defmodule Cafe.MixProject do
  use Mix.Project

  def project do
    [
      app: :cafe,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Cafe.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:seven, path: "../sevenotters"},
      {:sevenotters_mongo, path: "../sevenotters_mongo"},
      {:ve, "~> 0.1"}
    ]
  end
end
