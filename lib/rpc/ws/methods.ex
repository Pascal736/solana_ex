defmodule SolanaEx.WS.Methods do
  defmodule AccountSubscribe do
    defstruct([:pubkey, opts: [commitment: "finalized", encoding: "jsonParsed"]])
  end
end
