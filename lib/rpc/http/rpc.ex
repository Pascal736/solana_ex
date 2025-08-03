defmodule SolanaEx.RPC do
  alias SolanaEx.Rpc.Response
  alias SolanaEx.Client
  alias SolanaEx.RPC.Request

  def get_account_info(client, pubkey, opts \\ []) do
    opts = filter_options(opts, [:commitment, :encoding, :dataslice, :min_context_slot])
    request = Request.new("getAccountInfo", pubkey, opts) |> Request.encode!()
    post(client, request) |> handle_response(Response.AccountInfo)
  end

  def get_account_info!(client, pubkey, opts \\ []) do
    get_account_info(client, pubkey, opts) |> response_to_raise()
  end

  def get_balance(client, pubkey, opts \\ []) do
    opts = filter_options(opts, [:commitment, :min_context_slot])
    request = Request.new("getBalance", pubkey, opts) |> Request.encode!()
    post(client, request) |> handle_response(Response.Balance)
  end

  def get_balance!(client, pubkey, opts \\ []) do
    get_balance(client, pubkey, opts) |> response_to_raise()
  end

  def get_block(client, slot_number, opts \\ []) do
    opts =
      filter_options(opts, [
        :commitment,
        :encoding,
        :max_supported_transaction_version,
        :transaction_details,
        :rewards
      ])

    request = Request.new("getBlock", slot_number, opts) |> Request.encode!()
    post(client, request) |> handle_response(Response.Block)
  end

  def get_block!(slot_number, opts \\ []) do
    get_block(slot_number, opts) |> response_to_raise()
  end

  def get_block_height(client, opts \\ []) do
    opts = filter_options(opts, [:commitment, :min_context_slot])
    request = Request.new("getBlockHeight", nil, opts) |> Request.encode!()
    post(client, request) |> handle_response(Response.BlockHeight)
  end

  def get_block_height!(client, opts \\ []) do
    get_block_height(client, opts) |> response_to_raise
  end

  def get_block_commitment(client, block_height, opts \\ []) do
    opts = filter_options(opts, [])
    request = Request.new("getBlockCommitment", block_height, opts) |> Request.encode!()
    post(client, request) |> handle_response(Response.BlockCommitment)
  end

  def get_block_commitment!(client, block_height, opts \\ []) do
    get_block_commitment(client, block_height, opts) |> response_to_raise()
  end

  defp filter_options(_opts, []), do: []

  defp filter_options(opts, allowed) do
    Enum.filter(opts, fn {key, _value} -> key in allowed end)
  end

  defp post(nil, body) do
    client = Client.new([])
    Tesla.post(client, "", body)
  end

  defp post(client, body) do
    Tesla.post(client, "", body)
  end

  defp handle_response({:ok, %{body: %{"result" => %{"value" => data}}}}, struct_module) do
    case data do
      nil -> {:error, :invalid_response}
      data -> {:ok, struct_module.from_json(data)}
    end
  end

  defp handle_response({:ok, %{body: %{"result" => data}}}, struct_module) do
    case data do
      nil -> {:error, :invalid_response}
      data -> {:ok, struct_module.from_json(data)}
    end
  end

  defp handle_response({:ok, %{body: %{"error" => %{"message" => message}}}}, _struct_module) do
    case message do
      nil -> {:error, :invalid_response}
      message -> {:error, message}
    end
  end

  defp handle_response(_rest, _struct_module) do
    {:error, :invalid_response}
  end

  # TODO: Think about raising custom exception.
  defp response_to_raise({:ok, response}), do: response
  defp response_to_raise({:error, reason}), do: raise("RPC Error: #{inspect(reason)}")

  defp to_struct(data, struct_module) when is_map(data) do
    attrs =
      for {key, value} <- data, into: %{} do
        {String.to_atom(key), value}
      end

    struct(struct_module, attrs)
  end

  defp to_struct(data, struct_module) when is_integer(data) do
    struct(struct_module, value: data)
  end
end
