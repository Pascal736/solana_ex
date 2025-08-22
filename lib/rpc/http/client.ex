defmodule SolanaEx.RPC.HttpClient do
  alias Tesla

  @default_url "https://api.mainnet-beta.solana.com"

  def new(opts \\ []) do
    url = Keyword.get(opts, :url) || Application.get_env(:solana_ex, __MODULE__)[:url] || @default_url
    adapter = Keyword.get(opts, :adapter, Tesla.Adapter.Mint)

    middleware = [
      {Tesla.Middleware.BaseUrl, url},
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware, adapter)
  end
end
