defmodule SolanaEx.RPC.HttpClient do
  alias Tesla

  @default_url "https://api.mainnet-beta.solana.com"

  def new(opts \\ []) do
    # TODO: Make also configureable via config
    base_url = Keyword.get(opts, :base_url, @default_url)
    adapter = Keyword.get(opts, :adapter, Tesla.Adapter.Mint)

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware, adapter)
  end
end
