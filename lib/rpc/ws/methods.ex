defmodule SolanaEx.WS.Methods do
  defmodule AccountSubscribe do
    defstruct([:pubkey, opts: [commitment: "finalized", encoding: "jsonParsed"]])
  end

  def name(%AccountSubscribe{}), do: "accountSubscribe"
end
