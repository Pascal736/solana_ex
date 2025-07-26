defmodule SolanaEx.Client do
  alias Tesla

  def new(opts) do
    base_url = Keyword.get(opts, :base_url, "https://solana.drpc.org")
    adapter = Keyword.get(opts, :adapter, Tesla.Adapter.Mint)

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware, adapter)
  end
end
