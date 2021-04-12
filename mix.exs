defmodule KuCoin.MixProject do
  use Mix.Project

  def project do
    [
      app: :kucoin,
      version: "0.1.0",
      elixir: "~> 1.11",
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
      {:tesla, "~> 1.4"},
      {:jason, "~> 1.2"},
      {:kina, git: "https://github.com/insprac/kina"}
    ]
  end
end
