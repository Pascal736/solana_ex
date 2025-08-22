defmodule SolanaEx.RPCTest do
  use ExUnit.Case, async: true

  alias SolanaEx.RPC.HttpClient
  doctest SolanaEx.RPC.Request

  describe "new/1" do
    test "uses correct default URL" do
      client = HttpClient.new()

      assert get_url(client) == "https://api.mainnet-beta.solana.com"
    end

    test "uses custom URL if provided" do
      custom_url = "https://custom-url.com"
      client = HttpClient.new(url: custom_url)

      assert get_url(client) == custom_url
    end

    test "uses environment variable URL if set" do
      Application.put_env(:solana_ex, SolanaEx.RPC.HttpClient, url: "https://env-url.com")
      client = HttpClient.new()
      assert get_url(client) == "https://env-url.com"
      Application.delete_env(:solana_ex, SolanaEx.RPC.HttpClient)
    end
  end

  defp get_url(client) do
    client.pre |> Enum.at(0) |> elem(2) |> Enum.at(0)
  end
end
