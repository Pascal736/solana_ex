defmodule SolanaEx.WebsocketTest do
  alias Mint.HTTP1.Request
  alias SolanaEx.RPC.WsClient
  alias SolanaEx.RPC.WsMethods
  alias SolanaEx.RPC.Request
  alias SolanaEx.RPC.WsMethods.AccountSubscribe

  use ExUnit.Case

  describe "websocket client" do
    test "can associate messages to subscriptions" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)

      method = %AccountSubscribe{pubkey: "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12"}
      request = Request.new(WsMethods.name(method), method.pubkey, method.opts)
      msg = Request.encode!(request)

      response = %{
        "jsonrpc" => "2.0",
        # subscription ID
        "result" => 100,
        "id" => request.id
      }

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

      response = %{
        "jsonrpc" => "2.0",
        # subscription ID
        "result" => 100,
        "id" => request.id
      }

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
end
