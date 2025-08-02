defmodule SolanaEx.WebsocketTest do
  alias SolanaEx.RPC.WsClient
  alias SolanaEx.WS.Methods.AccountSubscribe

  use ExUnit.Case

  describe "websocket client" do
    test "sends correct subscribe message to server" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start(url: mock.url)

      request = %AccountSubscribe{pubkey: "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12"}

      WsClient.subscribe(client, request, [])
      Process.sleep(10)

      assert WebSocketMock.received_messages(mock) == [
               {:text,
                "{\"id\":1,\"params\":[\"CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12\",{\"commitment\":\"finalized\",\"encoding\":\"jsonParsed\"}],\"method\":\"accountSubscribe\",\"jsonrpc\":\"2.0\"}"}
             ]
    end
  end
end
