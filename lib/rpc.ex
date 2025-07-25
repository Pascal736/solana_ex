defmodule SolanaEx.RPC do
  alias SolanaEx.RPC.AccountInfo
  alias Req

  defmodule AccountInfo do
    defstruct [:lamports, :owner, :data, :executable, :rentEpoch, :space]
  end

  def get_account_info(client \\ Req, pubkey, opts \\ []) do
    # TODO: Idea: Think about the option to provide a data converter.
    opts = filter_options(opts, [:commitment, :encoding, :dataslice, :min_context_slot])
    request = rpc_request_encoded("getAccountInfo", pubkey, opts)

    client.post("https://solana.drpc.org",
      body: request,
      headers: [{"Content-Type", "application/json"}]
    )
    |> handle_response(AccountInfo)
  end

  def get_account_info!(client \\ Req, pubkey, opts \\ []) do
    case get_account_info(client, pubkey, opts) do
      {:ok, response} -> response
      {:error, reason} -> raise "Failed to get account info: #{inspect(reason)}"
    end
  end

  defp handle_response({:ok, response}, struct_module) do
    case get_in(response.body, ["result", "value"]) do
      nil -> {:error, :invalid_response}
      data -> {:ok, to_struct(data, struct_module)}
    end
  end

  defp handle_response(rest, _struct_module) do
    rest
  end

  defp to_struct(data, struct_module) do
    attrs =
      for {key, value} <- data, into: %{} do
        {String.to_atom(key), value}
      end

    struct(struct_module, attrs)
  end

  @doc """
  Creates a JSON-RPC 2.0 request payload for Solana API calls.

  This function builds a properly formatted JSON-RPC request with the specified method
  and parameters. It automatically generates a unique request ID and converts atom
  values to strings for JSON compatibility. The options are assumed to be pre-filtered
  by the calling function.

  ## Parameters

    * `method` - The RPC method name as a string (e.g., "getAccountInfo")
    * `params` - The primary parameter
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

  defp rpc_request_encoded(method, params, opts \\ []) do
    request = rpc_request(method, params, opts)
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
      Map.put(acc, key, convert_value(value))
    end)
  end

  defp convert_value(value) when is_atom(value), do: to_string(value)
  defp convert_value(value), do: value

  defp filter_options(opts, allowed) do
    Enum.filter(opts, fn {key, _value} -> key in allowed end)
  end
end
