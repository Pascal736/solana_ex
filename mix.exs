defmodule SolanaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :solana_ex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ed25519, "~> 1.4"},
      {:b58, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:tesla, "~> 1.15"},
      {:mint, "~> 1.0"},
      {:websockex, "~> 0.5.0", hex: :websockex_wt},
      {:websocket_mock, "~> 0.1.3", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
end
