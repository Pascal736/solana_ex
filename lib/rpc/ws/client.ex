defmodule SolanaEx.RPC.WsClient do
  alias SolanaEx.WS.Methods
  alias SolanaEx.Rpc.WsSocket
  alias SolanaEx.RPC

  @default_url "ws://api.mainnet-beta.solana.com"

  # Requirements: User can has convnient interface for calling Solana RPC WS methods 
  # User can provide callback for receiving messages
  # State manages subscriptions to handle callbacks and be able to use a single WS connection
  # Note: The way the Solana nodes are implemented sending the same requests multiple times will lead to the identical ID.
  #
  #
  defstruct [:client_pid]

  def start(opts \\ []) do
    url = Keyword.get(opts, :url, @default_url)
    state = %{active_subscriptions: %{}}
    {:ok, pid} = WsSocket.start_link(url, WsSocket, state)

    {:ok, %__MODULE__{client_pid: pid}}
  end

  def subscribe(
        %__MODULE__{client_pid: pid},
        %Methods.AccountSubscribe{} = method,
        callbacks \\ []
      ) do
    # Change this into cast to store id in the same function.
    request =
      RPC.rpc_request("accountSubscribe", method.pubkey, method.opts)
      |> Jason.encode!()

    # TODO: Assign request ID and callbacks to state
    # id = request |> Map.get("id", nil)
    # cast(self(), {:assign_callbacks, id, callbacks})

    WebSockex.send_frame(pid, {:text, request})
  end
end
