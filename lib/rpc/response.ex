defmodule SolanaEx.Rpc.Response do
  defmodule AccountInfo do
    defstruct [:lamports, :owner, :data, :executable, :rent_epoch, :space]

    def from_json(%{
          "lamports" => lamports,
          "owner" => owner,
          "data" => data,
          "executable" => executable,
          "rentEpoch" => rent_epoch,
          "space" => space
        }) do
      %AccountInfo{
        lamports: lamports,
        owner: owner,
        data: data,
        executable: executable,
        rent_epoch: rent_epoch,
        space: space
      }
    end
  end

  defmodule Balance do
    defstruct [:value]

    def from_json(value) do
      %Balance{value: value}
    end
  end

  defmodule BlockHeight do
    defstruct [:blockHeight]

    def from_json(block_height) do
      %BlockHeight{blockHeight: block_height}
    end
  end
end
