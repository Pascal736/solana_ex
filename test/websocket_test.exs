defmodule SolanaEx.WebsocketTest do
  alias SolanaEx.RPC
  alias SolanaEx.RPC.WsClient
  alias SolanaEx.WS.Methods
  alias SolanaEx.RPC.Request

  alias SolanaEx.WS.Methods.AccountSubscribe

  use ExUnit.Case

  describe "websocket client" do
    test "sends correct subscribe message to server" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)

      method = %AccountSubscribe{pubkey: "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12"}
      request = Request.new(Methods.name(method), method.pubkey, method.opts)

      try do
        WsClient.subscribe(client, request, [])
      catch
        # We expect a timeout because we did not configure the mock server to reply.
        :exit, _ -> nil
      end

      Process.sleep(10)

      assert WebSocketMock.received_messages(mock) == [
               {:text,
                "{\"id\":#{request.id},\"params\":[\"CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12\",{\"commitment\":\"finalized\",\"encoding\":\"jsonParsed\"}],\"method\":\"accountSubscribe\",\"jsonrpc\":\"2.0\"}"}
             ]
    end

    test "can associate messages to subscriptions" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)

      method = %AccountSubscribe{pubkey: "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12"}
      request = Request.new(Methods.name(method), method.pubkey, method.opts)
      msg = request_as_frame(request)

      response = %{
        "jsonrpc" => "2.0",
        # subscription ID
        "result" => 100,
        "id" => request.id
      }

      WebSocketMock.reply_with(mock, msg, {:text, response})
      WsClient.subscribe(client, request, [fn msg -> IO.puts(msg) end])
      Process.sleep(10)

      assert WebSocketMock.received_messages(mock) == [msg]

      assert WsClient.subscriptions(client) == {:ok, %{request.id => 100}}
      {:ok, %{100 => callbacks}} = WsClient.callbacks(client)
      assert length(callbacks) == 1
    end

    test "callback get's executed" do
      {:ok, mock} = WebSocketMock.start()
      {:ok, client} = WsClient.start_link(url: mock.url)

      method = %AccountSubscribe{pubkey: "CM78CPUeXjn8o3yroDHxUtKsZZgoy4GPkPPXfouKNH12"}
      request = Request.new(Methods.name(method), method.pubkey, method.opts)
      msg = request_as_frame(request)

      response = %{
        "jsonrpc" => "2.0",
        # subscription ID
        "result" => 100,
        "id" => request.id
      }

      test_pid = self()

      callback = fn msg ->
        send(test_pid, :callback_executed)
      end

      WebSocketMock.reply_with(mock, msg, {:text, response})
      WsClient.subscribe(client, request, [callback])
      [%{client_id: client_id}] = WebSocketMock.list_clients(mock)

      WebSocketMock.send_message(
        mock,
        client_id,
        {:text, Jason.encode!(valid_account_subscribe_event(100))}
      )

      assert_receive :callback_executed, 1000
    end
  end

  defp request_as_frame(request) do
    {:text,
     request
     |> Request.encode!()}
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
