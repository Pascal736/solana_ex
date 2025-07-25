defmodule SolanaEx.RPC do
  def get_account_info(client, pubkey, opts \\ []) do
    opts = filter_options(opts, [:commitment, :encoding, :dataslice, :min_context_slot])

    request =
      rpc_request("getAccountInfo", pubkey, opts)

    # TODO: Continue
  end

  @doc """
  Creates a JSON-RPC 2.0 request payload for Solana API calls.

  This function builds a properly formatted JSON-RPC request with the specified method
  and parameters. It automatically generates a unique request ID and converts atom
  values to strings for JSON compatibility. The options are assumed to be pre-filtered
  by the calling function.

  ## Parameters

    * `method` - The RPC method name as a string (e.g., "getAccountInfo")
    * `params` - The primary parameter (typically a public key or account address)
    * `opts` - A keyword list of optional parameters (keys and values can be atoms or strings)

  ## Returns

  Returns a map representing the JSON-RPC 2.0 request structure with:
    * `:jsonrpc` - Always "2.0"
    * `:id` - A unique positive integer for request tracking
    * `:method` - The specified RPC method
    * `:params` - An array containing the main parameter and optional configuration object

  ## Examples

      iex> request = SolanaEx.RPC.rpc_request(
      ...>   "getAccountInfo",
      ...>   "vines1vzrYbzLMRdu58ou5XTby4qAqVRLmqo36NKPTg",
      ...>   [commitment: :finalized, encoding: :base58]
      ...> )
      iex> %{
      ...>   jsonrpc: "2.0",
      ...>   method: "getAccountInfo",
      ...>   params: [
      ...>     "vines1vzrYbzLMRdu58ou5XTby4qAqVRLmqo36NKPTg",
      ...>     %{commitment: "finalized", encoding: "base58"}
      ...>   ]
      ...> } = request

      iex> # With no options
      iex> request = SolanaEx.RPC.rpc_request("getBalance", "vines1vzrYbzLMRdu58ou5XTby4qAqVRLmqo36NKPTg")
      iex> request.params
      ["vines1vzrYbzLMRdu58ou5XTby4qAqVRLmqo36NKPTg"]
  """
  def rpc_request(method, params, opts \\ []) do
    %{
      jsonrpc: "2.0",
      id: :erlang.unique_integer([:positive, :monotonic]),
      method: method,
      params: create_params(params, opts)
    }
  end

  defp create_params(argument, opts) do
    case convert_options(opts) do
      options when map_size(options) == 0 -> [argument]
      options -> [argument, options]
    end
  end

  defp convert_options(opts) do
    Enum.reduce(opts, %{}, fn {key, value}, acc ->
      Map.put(acc, key, convert_value(value))
    end)
  end

  defp convert_value(value) when is_atom(value), do: to_string(value)
  defp convert_value(value), do: value

  defp filter_options(opts, allowed) do
    Enum.filter(opts, fn {key, _value} -> key in allowed end)
  end
end
