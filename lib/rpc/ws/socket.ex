defmodule SolanaEx.RPC.WsSocket do
  use WebSockex

  @ping_interval 20_000

  def start_link(url, module, state) do
    WebSockex.start_link(url, module, state)
  end

  @impl true
  def handle_connect(_conn, state) do
    schedule_next_ping()
    {:ok, state}
  end

  @impl true
  def handle_frame({:text, msg}, state) do
    case Jason.decode(msg) do
      {:ok, decoded} ->
        send(state.parent_pid, {:ws_message, decoded})

      {:error, _} ->
        :ok
    end

    {:ok, state}
  end

  @impl true
  def handle_cast({:send_frame, frame}, state) do
    {:reply, frame, state}
  end

  @impl true
  def handle_info(:send_ping, state) do
    schedule_next_ping()
    {:reply, {:ping, ""}, state}
  end

  defp schedule_next_ping() do
    Process.send_after(self(), :send_ping, @ping_interval)
  end
end
