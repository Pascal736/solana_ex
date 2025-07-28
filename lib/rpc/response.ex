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

  defmodule Block do
    # TODO: Parse transactions
    defstruct [
      :block_height,
      :block_time,
      :block_hash,
      :parent_slot,
      :previous_blockhash,
      transactions: []
    ]

    def from_json(%{
          "blockHeight" => block_height,
          "blockTime" => block_time,
          "blockhash" => block_hash,
          "parentSlot" => parent_slot,
          "previousBlockhash" => previous_blockhash,
          "transactions" => transactions
        }) do
      %Block{
        block_height: block_height,
        block_time: block_time,
        block_hash: block_hash,
        parent_slot: parent_slot,
        previous_blockhash: previous_blockhash,
        transactions: transactions
      }
    end
  end

  defmodule BlockHeight do
    defstruct [:blockHeight]

    def from_json(block_height) do
      %BlockHeight{blockHeight: block_height}
    end
  end

  defmodule BlockCommitment do
    defstruct [:commitment, :total_stake]

    def from_json(%{
          "commitment" => commitment,
          "totalStake" => total_stake
        }) do
      %BlockCommitment{
        commitment: commitment,
        total_stake: total_stake
      }
    end
  end
end
