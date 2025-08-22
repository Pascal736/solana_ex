defmodule SolanaEx.RPC.WsClient do
  use GenServer

  alias SolanaEx.RPC.WsSocket
  alias SolanaEx.RPC.Request
  alias SolanaEx.RPC.WsMethods

  @default_url "ws://api.mainnet-beta.solana.com"

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    url = Keyword.get(opts, :url) || Application.get_env(:solana_ex, :ws_url) || @default_url
    {:ok, pid} = WsSocket.start_link(url, WsSocket, %{parent_pid: self()})
    state = %{subscriptions: %{}, callbacks: %{}, pending_requests: %{}, socket_pid: pid}
    {:ok, state}
  end

  def subscribe(%Request{} = request, callbacks) when is_list(callbacks) do
    GenServer.call(__MODULE__, {:subscribe, request, callbacks})
  end

  def subscribe(client, %Request{} = request, callbacks \\ []) when is_list(callbacks) do
    GenServer.call(client, {:subscribe, request, callbacks})
  end

  def subscribe_account(pubkey, opts \\ [], callbacks \\ []) when is_list(callbacks) and is_list(opts) do
    subscribe_account(__MODULE__, pubkey, opts, callbacks)
  end

  def subscribe_account(client, pubkey, opts, callbacks) when is_list(callbacks) and is_list(opts) do
    method = %WsMethods.AccountSubscribe{pubkey: pubkey}
    # TODO: Add proper merging of opts.
    request = Request.new("accountSubscribe", method.pubkey, method.opts)
    subscribe(client, request, callbacks)
  end

  def subscribe_slot(callbacks) do
    request = Request.new("slotSubscribe", [], [])
    subscribe(request, callbacks)
  end

  def subscribe_slot(client, callbacks) do
    request = Request.new("slotSubscribe", [], [])
    subscribe(client, request, callbacks)
  end

  # TODO: Implement
  def unsubscribe(client, request_id) do
    GenServer.call(client, {:unsubscribe, request_id})
  end

  def subscriptions(client) do
    GenServer.call(client, :subscriptions)
  end

  def callbacks(client) do
    GenServer.call(client, :callbacks)
  end

  def handle_call({:subscribe, request, callbacks}, from, state) do
    new_state = add_pending_request(state, request, from, callbacks)
    WebSockex.cast(state.socket_pid, {:send_frame, {:text, Request.encode!(request)}})

    {:noreply, new_state}
  end

  def handle_call(:subscriptions, _from, state) do
    {:reply, {:ok, state.subscriptions}, state}
  end

  def handle_call(:callbacks, _from, state) do
    {:reply, {:ok, state.callbacks}, state}
  end

  def handle_info({:ws_message, %{"id" => id, "result" => subscription_id}}, state) do
    case Map.pop(state.pending_requests, id) do
      {{from, callbacks}, remaining_requests} ->
        GenServer.reply(from, {:ok, subscription_id})

        new_state = %{
          state
          | pending_requests: remaining_requests,
            subscriptions: Map.put(state.subscriptions, id, subscription_id),
            callbacks: Map.put(state.callbacks, subscription_id, callbacks)
        }

        {:noreply, new_state}

      {nil, _} ->
        {:noreply, state}
    end
  end

  def handle_info({:ws_message, message}, state) do
    subscription_id = get_in(message, ["params", "subscription"])

    Map.get(state.callbacks, subscription_id, [])
    |> Enum.each(fn callback -> spawn(fn -> callback.(message) end) end)

    {:noreply, state}
  end

  defp add_pending_request(state, request, from, callbacks) do
    pending_requests = Map.put(state.pending_requests, request.id, {from, callbacks})
    %{state | pending_requests: pending_requests}
  end
end
