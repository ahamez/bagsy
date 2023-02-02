defmodule Bagsy.MixProject do
  use Mix.Project

  def project do
    [
      app: :bagsy,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:evision, "~> 0.1.21"},
      {:exqlite, "~> 0.11.9"},
      {:nx, "~> 0.4"}
    ]
  end
end
