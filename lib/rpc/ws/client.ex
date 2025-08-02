defmodule SolanaEx.RPC.WsClient do
  @ping_interval 20_000

  use WebSockex

  alias SolanaEx.WS.Methods
  alias SolanaEx.RPC

  # Requirements: User can has convnient interface for calling Solana RPC WS methods 
  # User can provide callback for receiving messages
  # State manages subscriptions to handle callbacks and be able to use a single WS connection
  # Note: The way the Solana nodes are implemented sending the same requests multiple times will lead to the identical ID.

  def start_link(url \\ "ws://api.mainnet-beta.solana.com") do
    state = %{active_subscriptions: %{}}
    WebSockex.start_link(url, __MODULE__, state)
  end

  def handle_connect(_conn, state) do
    IO.puts("Connected to Solana WebSocket")
    schedule_next_ping()
    {:ok, state}
  end

  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, decoded_msg} ->
        handle_msg(decoded_msg, state)

      {:error, _reason} ->
        IO.puts("Failed to decode message: #{msg}")
    end

    {:ok, state}
  end

  defp handle_msg(%{"id" => id, "jsonrpc" => "2.0", "result" => subscription_id}, state) do
    # callbacks = Map.get(state, id, [])
    # state = Map.put(state, subscription_id, callbacks)
    state
  end

  defp handle_msg(other, state) do
    state
  end

  def handle_cast(:assign_callbacks, {id, callback}, state) do
    IO.puts("Assigning callbacks for ID: #{inspect(id)} with callbacks")
    state = state |> Map.put(id, callback)
    {:noreply, state}
  end

  def subscribe(server, %Methods.AccountSubscribe{} = method, callbacks \\ []) do
    # Change this into cast to store id in the same function.
    request =
      RPC.rpc_request("accountSubscribe", method.pubkey, method.opts)
      |> Jason.encode!()

    # TODO: Assign request ID and callbacks to state
    # id = request |> Map.get("id", nil)
    # cast(self(), {:assign_callbacks, id, callbacks})

    res = WebSockex.send_frame(server, {:text, request})
    dbg(res)
  end

  defp schedule_next_ping() do
    Process.send_after(self(), :send_ping, @ping_interval)
  end

  def handle_cast(msg, state) do
    dbg(msg)
    {:reply, "thing", state}
  end

  def handle_info(:send_ping, state) do
    IO.puts("Sending ping to keep connection alive")
    schedule_next_ping()
    {:reply, {:ping, ""}, state}
  end
end
