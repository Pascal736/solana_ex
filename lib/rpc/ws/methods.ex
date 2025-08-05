defmodule SolanaEx.RPC.WsMethods do
  defmodule AccountSubscribe do
    defstruct([:pubkey, opts: [commitment: "finalized", encoding: "jsonParsed"]])
  end

  defmodule BlockSubscribe do
    # accounts can be eiter "all" or "mentionsAccountOrProgram" => pubkey
    defstruct([
      :accounts,
      opts: [
        commitment: "finalized",
        encoding: "jsonParsed",
        transactionDetails: "full",
        max_supported_transaction_version: 0,
        show_rewards: true
      ]
    ])
  end

  def name(%AccountSubscribe{}), do: "accountSubscribe"
  def name(%BlockSubscribe{}), do: "blockSubscribe"
end
