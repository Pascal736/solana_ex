defmodule SolanaEx.RPCTest do
  use ExUnit.Case, async: true

  alias SolanaEx.RPC.HttpClient
  doctest SolanaEx.RPC.Request

  describe "new/1" do
    test "uses correct default URL" do
      {:ok, pid} = HttpClient.start_link()

      assert get_url(pid) == "https://api.mainnet-beta.solana.com"
    end

    test "uses custom URL if provided" do
      custom_url = "https://custom-url.com"
      {:ok, pid} = HttpClient.start_link(url: custom_url)

      assert get_url(pid) == custom_url
    end

    test "uses environment variable URL if set" do
      Application.put_env(:solana_ex, :http_url, "https://env-url.com")
      {:ok, pid} = HttpClient.start_link()
      assert get_url(pid) == "https://env-url.com"
      Application.delete_env(:solana_ex, :http_url)
    end
  end

  defp get_url(pid) do
    :sys.get_state(pid) |> Map.get(:client) |> Map.get(:pre) |> Enum.at(0) |> elem(2) |> Enum.at(0)
  end
end
