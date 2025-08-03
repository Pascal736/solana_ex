defmodule SolanaEx.RPC.Request do
  @derive Jason.Encoder
  defstruct [:id, :method, :params, :jsonrpc]

  @doc """
  Creates a new JSON-RPC 2.0 request struct for Solana API calls.

  Builds a properly formatted JSON-RPC request with the specified method and parameters.
  Automatically generates a unique request ID and handles parameter formatting.

  ## Parameters

  - `method` - The RPC method name as a string (e.g., "getAccountInfo", "accountSubscribe")
  - `params` - The primary parameter (pubkey, address, etc.)
  - `opts` - A keyword list of optional parameters (default: `[]`)

  ## Returns

  Returns a `%SolanaEx.RPC.Request{}` struct with:

  - `:jsonrpc` - Always "2.0"
  - `:id` - A unique positive integer for request tracking
  - `:method` - The specified RPC method
  - `:params` - Parameters formatted by `create_params/2`

  ## Examples

      # Standard RPC request with options
      request = SolanaEx.RPC.Request.new(
        "getAccountInfo",
        "vines1vzrYbzLMRdu58ou5XTby4qAqVRLmqo36NKPTg",
        [commitment: :finalized, encoding: :base58]
      )
      #=> %SolanaEx.RPC.Request{
      #     jsonrpc: "2.0",
      #     method: "getAccountInfo",
      #     params: ["vines1vzrYbzLMRdu58ou5XTby4qAqVRLmqo36NKPTg", %{"commitment" => "finalized", "encoding" => "base58"}],
      #     id: 12345
      #   }

      # WebSocket subscription request
      request = SolanaEx.RPC.Request.new(
        "accountSubscribe",
        "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12",
        [commitment: "finalized", encoding: "jsonParsed"]
      )

      # Simple request without options
      request = SolanaEx.RPC.Request.new("getBalance", "vines1vzrYbzLMRdu58ou5XTby4qAqVRLmqo36NKPTg")
      request.params
      #=> ["vines1vzrYbzLMRdu58ou5XTby4qAqVRLmqo36NKPTg"]

  """
  def new(method, params, opts \\ []) do
    %__MODULE__{
      jsonrpc: "2.0",
      id: :erlang.unique_integer([:positive, :monotonic]),
      method: method,
      params: create_params(params, opts)
    }
  end

  def encode!(%__MODULE__{} = request) do
    Jason.encode!(request)
  end

  defp create_params(argument, opts) do
    case convert_options(opts) do
      options when map_size(options) == 0 -> [argument]
      options -> [argument, options]
    end
  end

  defp convert_options(opts) do
    Enum.reduce(opts, %{}, fn {key, value}, acc ->
      Map.put(acc, convert_key(key), convert_value(value))
    end)
  end

  defp convert_value(value) when is_atom(value), do: to_string(value)
  defp convert_value(value), do: value

  defp convert_key(value) when is_atom(value) do
    to_string(value) |> snake_to_camel()
  end

  defp snake_to_camel(string) when is_binary(string) do
    camelized = Macro.camelize(string)
    <<first::utf8, rest::binary>> = camelized
    String.downcase(<<first::utf8>>) <> rest
  end
end
