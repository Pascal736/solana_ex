defmodule SolanaEx.RPC.Http do
  alias SolanaEx.RPC.Request
  alias SolanaEx.RPC.HttpMethods

  HttpMethods.methods()
  |> Enum.each(fn {name, args, opts, rpc_method, response_module} ->
    args = Enum.map(args, &Macro.var(&1, nil))

    def unquote(:"#{name}")(client, unquote_splicing(args), opts \\ []) do
      opts = filter_options(opts, unquote(opts)) 
      request = Request.new(unquote(rpc_method), unquote_splicing(args), opts) |> Request.encode!()
      post(client, request) |> handle_response(unquote(response_module))
    end

    def unquote(:"#{name}!")(client, unquote_splicing(args), opts \\ []) do
      unquote(:"#{name}")(client, unquote_splicing(args), opts) |> response_to_raise()
    end
  end)

  defp filter_options(_opts, []), do: []

  defp filter_options(opts, allowed) do
    Enum.filter(opts, fn {key, _value} -> key in allowed end)
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
end
