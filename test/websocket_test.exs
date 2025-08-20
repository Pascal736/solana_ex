defmodule SolanaEx.WebsocketTest do
  alias SolanaEx.RPC.WsClient
  alias SolanaEx.RPC.WsMethods
  alias SolanaEx.RPC.Request
  alias SolanaEx.RPC.WsMethods.AccountSubscribe

  use ExUnit.Case

  describe "websocket client" do
    test "sends correct RPC request for accountSubscribe method" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url, mame: :test1)
      WebSocketMock.reply_with(mock, always_match(), subscription_resp_transformer())

      WsClient.subscribe_account(client, "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12", [], [])

      [{:text, received}] = WebSocketMock.received_messages(mock)
      decoded = Jason.decode!(received)

      assert %{
               "jsonrpc" => "2.0",
               "method" => "accountSubscribe",
               "params" => [
                 "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12",
                 %{
                   "encoding" => "jsonParsed",
                   "commitment" => "finalized"
                 }
               ],
               "id" => _id
             } = decoded
    end

    test "sends correct RPC reqeuest for subscribeSlot method" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)
      WebSocketMock.reply_with(mock, always_match(), subscription_resp_transformer())

      WsClient.subscribe_slot(client, [])

      [{:text, received}] = WebSocketMock.received_messages(mock)
      decoded = Jason.decode!(received)

      assert %{
               "jsonrpc" => "2.0",
               "method" => "slotSubscribe",
               "id" => _id
             } = decoded
    end

    test "sends to correct client when not explicitely specified" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)
      WebSocketMock.reply_with(mock, always_match(), subscription_resp_transformer())

      WsClient.subscribe_slot([])

      [{:text, received}] = WebSocketMock.received_messages(mock)
      decoded = Jason.decode!(received)

      assert %{
               "jsonrpc" => "2.0",
               "method" => "slotSubscribe",
               "id" => _id
             } = decoded
    end

    test "can associate messages to subscriptions" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)

      method = %AccountSubscribe{pubkey: "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12"}
      request = Request.new(WsMethods.name(method), method.pubkey, method.opts)
      msg = Request.encode!(request)

      response = subscription_response(request.id)
      WebSocketMock.reply_with(mock, msg, response)
      WsClient.subscribe(client, request, [fn msg -> IO.puts(msg) end])
      Process.sleep(10)

      assert WebSocketMock.received_messages(mock) == [{:text, msg}]

      assert WsClient.subscriptions(client) == {:ok, %{request.id => 100}}
      {:ok, %{100 => callbacks}} = WsClient.callbacks(client)
      assert length(callbacks) == 1
    end

    test "callback get's executed" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)

      method = %AccountSubscribe{pubkey: "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12"}
      request = Request.new(WsMethods.name(method), method.pubkey, method.opts)
      msg = Request.encode!(request)
      response = subscription_response(request.id)

      test_pid = self()

      callback = fn msg ->
        send(test_pid, {:callback_executed, msg})
      end

      WebSocketMock.reply_with(mock, msg, response)
      WsClient.subscribe(client, request, [callback])
      [%{client_id: client_id}] = WebSocketMock.list_clients(mock)

      subscription_msg = valid_account_subscribe_event(100)

      WebSocketMock.send_message(
        mock,
        client_id,
        Jason.encode!(subscription_msg)
      )

      assert_receive {:callback_executed, received}, 1000
      assert received == subscription_msg
    end

    test "can be called without client parameter" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)

      method = %AccountSubscribe{pubkey: "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12"}
      request = Request.new(WsMethods.name(method), method.pubkey, method.opts)
      msg = Request.encode!(request)
      response = subscription_response(request.id)

      test_pid = self()

      callback = fn msg ->
        send(test_pid, {:callback_executed, msg})
      end

      WebSocketMock.reply_with(mock, msg, response)
      WsClient.subscribe(client, request, [callback])

      assert WsClient.subscriptions(WsClient) == {:ok, %{request.id => 100}}
    end
  end

  defp valid_account_subscribe_event(subscription_id) do
    %{
      "jsonrpc" => "2.0",
      "method" => "accountNotification",
      "params" => %{
        "result" => %{
          "context" => %{
            "slot" => 5_199_307
          },
          "value" => %{
            "data" => %{
              "program" => "nonce",
              "parsed" => %{
                "type" => "initialized",
                "info" => %{
                  "authority" => "Bbqg1M4YVVfbhEzwA9SpC9FhsaG83YMTYoR4a8oTDLX",
                  "blockhash" => "LUaQTmM7WbMRiATdMMHaRGakPtCkc2GHtH57STKXs6k",
                  "feeCalculator" => %{
                    "lamportsPerSignature" => 5000
                  }
                }
              }
            },
            "executable" => false,
            "lamports" => 33594,
            "owner" => "11111111111111111111111111111111",
            "rentEpoch" => 635,
            "space" => 80
          }
        },
        "subscription" => subscription_id
      }
    }
  end

  defp subscription_response(subscription_id) do
    %{
      "jsonrpc" => "2.0",
      "result" => 100,
      "id" => subscription_id
    }
  end

  defp always_match, do: fn _ -> true end

  defp subscription_resp_transformer do
    fn {opcode, msg} ->
      id = Jason.decode!(msg) |> Map.get("id")
      {opcode, subscription_response(id) |> Jason.encode!()}
    end
  end
end
