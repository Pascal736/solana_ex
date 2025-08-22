defmodule SolanaEx.RPC.HttpClient do

  use GenServer

  alias Tesla

  alias SolanaEx.RPC.Request
  alias SolanaEx.RPC.HttpMethods

  @default_url "https://api.mainnet-beta.solana.com"

  @doc """
  Starts the HttpClient GenServer.
  
  ## Options
  - `:url` - The base URL for the RPC endpoint
  - `:adapter` - The Tesla adapter to use (default: Tesla.Adapter.Mint)
  - `:name` - The name to register the GenServer under
  """
  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    url = Keyword.get(opts, :url) || Application.get_env(:solana_ex, :http_url) || @default_url
    adapter = Keyword.get(opts, :adapter, Tesla.Adapter.Mint)

    middleware = [
      {Tesla.Middleware.BaseUrl, url},
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]},
      Tesla.Middleware.JSON
    ]

    client = Tesla.client(middleware, adapter)
    {:ok, %{client: client}}
  end

  HttpMethods.methods()
  |> Enum.each(fn {name, args, opts, rpc_method, response_module} ->
    args = Enum.map(args, &Macro.var(&1, nil))
    
    def unquote(:"#{name}")(unquote_splicing(args), opts \\ []) do
      unquote(:"#{name}")(__MODULE__, unquote_splicing(args), opts)
    end
    
    def unquote(:"#{name}")(server, unquote_splicing(args), opts) when is_atom(server) or is_pid(server) do
      opts = filter_options(opts, unquote(opts)) |> dbg()
      [unquote_splicing(args)] |> dbg()
      request = Request.new(unquote(rpc_method), unquote_splicing(args), opts) |> Request.encode!()
      GenServer.call(server, {:request, request, unquote(response_module)})
    end
    
    def unquote(:"#{name}!")(unquote_splicing(args), opts \\ []) do
      unquote(:"#{name}")(unquote_splicing(args), opts) |> response_to_raise()
    end
    
    def unquote(:"#{name}!")(server, unquote_splicing(args), opts) when is_atom(server) or is_pid(server) do
      unquote(:"#{name}")(server, unquote_splicing(args), opts) |> response_to_raise()
    end
  end)

 
  @impl true
  def handle_call({:request, request, response_module}, _from, %{client: client} = state) do
      response = post(client, request) |> handle_response(response_module)
    {:reply, response, state}
  end

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
