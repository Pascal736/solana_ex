defmodule SolanaEx.Rpc.WsSocket do
  use WebSockex

  @ping_interval 20_000

  @impl true
  def start_link(url, module, state) do
    WebSockex.start_link(url, module, state)
  end

  def handle_connect(_conn, state) do
    IO.puts("Connected to Solana WebSocket")
    schedule_next_ping()
    {:ok, state}
  end

  @impl true
  def handle_frame({_type, msg}, state) do
    dbg(msg)

    {:ok, state}
  end

  @impl true
  def handle_cast(:assign_callbacks, {id, callback}, state) do
    IO.puts("Assigning callbacks for ID: #{inspect(id)} with callbacks")
    state = state |> Map.put(id, callback)
    {:noreply, state}
  end

  @impl true
  def handle_cast(msg, state) do
    dbg(msg)
    {:reply, "thing", state}
  end

  @impl true
  def handle_info(:send_ping, state) do
    IO.puts("Sending ping to keep connection alive")
    schedule_next_ping()
    {:reply, {:ping, ""}, state}
  end

  defp schedule_next_ping() do
    Process.send_after(self(), :send_ping, @ping_interval)
  end
end
