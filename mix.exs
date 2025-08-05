defmodule SolanaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :solana_ex,
      version: "0.0.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
      {:websocket_mock, git: "https://github.com/Pascal736/websocket_mock", branch: "main", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Pascal Pfeiffer"],
      links: %{
        "GitHub" => "https://github.com/pascal736/solana_ex"
      }
    ]
  end
end
