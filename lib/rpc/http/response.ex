defmodule SolanaEx.RPC.Response do
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
    defstruct [:value]

    def from_json(block_height) do
      %BlockHeight{value: block_height}
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

  defmodule BlockProduction do
    defstruct [:by_identity, :range]

    def from_json(%{
          "byIdentity" => by_identity,
          "range" => range
        }) do
      %BlockProduction{
        by_identity: by_identity,
        range: range
      }
    end
  end

  defmodule Blocks do
    defstruct [:blocks]

    def from_json(blocks) when is_list(blocks) do
      %Blocks{blocks: blocks}
    end
  end

  defmodule BlocksWithLimit do
    defstruct [:blocks]

    def from_json(blocks) when is_list(blocks) do
      %BlocksWithLimit{blocks: blocks}
    end
  end

  defmodule BlockTime do
    defstruct [:timestamp]

    def from_json(timestamp) do
      %BlockTime{timestamp: timestamp}
    end
  end

  defmodule ClusterNodes do
    defstruct [:nodes]

    def from_json(nodes) when is_list(nodes) do
      %ClusterNodes{nodes: nodes}
    end
  end

  defmodule EpochInfo do
    defstruct [:absolute_slot, :block_height, :epoch, :slot_index, :slots_in_epoch, :transaction_count]

    def from_json(%{
          "absoluteSlot" => absolute_slot,
          "blockHeight" => block_height,
          "epoch" => epoch,
          "slotIndex" => slot_index,
          "slotsInEpoch" => slots_in_epoch,
          "transactionCount" => transaction_count
        }) do
      %EpochInfo{
        absolute_slot: absolute_slot,
        block_height: block_height,
        epoch: epoch,
        slot_index: slot_index,
        slots_in_epoch: slots_in_epoch,
        transaction_count: transaction_count
      }
    end
  end

  defmodule EpochSchedule do
    defstruct [:slots_per_epoch, :leader_schedule_slot_offset, :warmup, :first_normal_epoch, :first_normal_slot]

    def from_json(%{
          "slotsPerEpoch" => slots_per_epoch,
          "leaderScheduleSlotOffset" => leader_schedule_slot_offset,
          "warmup" => warmup,
          "firstNormalEpoch" => first_normal_epoch,
          "firstNormalSlot" => first_normal_slot
        }) do
      %EpochSchedule{
        slots_per_epoch: slots_per_epoch,
        leader_schedule_slot_offset: leader_schedule_slot_offset,
        warmup: warmup,
        first_normal_epoch: first_normal_epoch,
        first_normal_slot: first_normal_slot
      }
    end
  end

  defmodule FeeForMessage do
    defstruct [:value]

    def from_json(value) do
      %FeeForMessage{value: value}
    end
  end

  defmodule FirstAvailableBlock do
    defstruct [:slot]

    def from_json(slot) do
      %FirstAvailableBlock{slot: slot}
    end
  end

  defmodule GenesisHash do
    defstruct [:hash]

    def from_json(hash) do
      %GenesisHash{hash: hash}
    end
  end

  defmodule Health do
    defstruct [:status]

    def from_json(status) do
      %Health{status: status}
    end
  end

  defmodule HighestSnapshotSlot do
    defstruct [:full, :incremental]

    def from_json(%{
          "full" => full,
          "incremental" => incremental
        }) do
      %HighestSnapshotSlot{
        full: full,
        incremental: incremental
      }
    end
  end

  defmodule Identity do
    defstruct [:identity]

    def from_json(%{"identity" => identity}) do
      %Identity{identity: identity}
    end
  end

  defmodule InflationGovernor do
    defstruct [:initial, :terminal, :taper, :foundation, :foundation_term]

    def from_json(%{
          "initial" => initial,
          "terminal" => terminal,
          "taper" => taper,
          "foundation" => foundation,
          "foundationTerm" => foundation_term
        }) do
      %InflationGovernor{
        initial: initial,
        terminal: terminal,
        taper: taper,
        foundation: foundation,
        foundation_term: foundation_term
      }
    end
  end

  defmodule InflationRate do
    defstruct [:total, :validator, :foundation, :epoch]

    def from_json(%{
          "total" => total,
          "validator" => validator,
          "foundation" => foundation,
          "epoch" => epoch
        }) do
      %InflationRate{
        total: total,
        validator: validator,
        foundation: foundation,
        epoch: epoch
      }
    end
  end

  defmodule InflationReward do
    defstruct [:rewards]

    def from_json(rewards) when is_list(rewards) do
      %InflationReward{rewards: rewards}
    end
  end

  defmodule LargestAccounts do
    defstruct [:accounts]

    def from_json(accounts) when is_list(accounts) do
      %LargestAccounts{accounts: accounts}
    end
  end

  defmodule LatestBlockhash do
    defstruct [:blockhash, :last_valid_block_height]

    def from_json(%{
          "blockhash" => blockhash,
          "lastValidBlockHeight" => last_valid_block_height
        }) do
      %LatestBlockhash{
        blockhash: blockhash,
        last_valid_block_height: last_valid_block_height
      }
    end
  end

  defmodule LeaderSchedule do
    defstruct [:schedule]

    def from_json(schedule) when is_map(schedule) do
      %LeaderSchedule{schedule: schedule}
    end
  end

  defmodule MaxRetransmitSlot do
    defstruct [:slot]

    def from_json(slot) do
      %MaxRetransmitSlot{slot: slot}
    end
  end

  defmodule MaxShredInsertSlot do
    defstruct [:slot]

    def from_json(slot) do
      %MaxShredInsertSlot{slot: slot}
    end
  end

  defmodule MinimumBalanceForRentExemption do
    defstruct [:lamports]

    def from_json(lamports) do
      %MinimumBalanceForRentExemption{lamports: lamports}
    end
  end

  defmodule MultipleAccounts do
    defstruct [:accounts]

    def from_json(accounts) when is_list(accounts) do
      %MultipleAccounts{accounts: accounts}
    end
  end

  defmodule ProgramAccounts do
    defstruct [:accounts]

    def from_json(accounts) when is_list(accounts) do
      %ProgramAccounts{accounts: accounts}
    end
  end

  defmodule RecentPerformanceSamples do
    defstruct [:samples]

    def from_json(samples) when is_list(samples) do
      %RecentPerformanceSamples{samples: samples}
    end
  end

  defmodule RecentPrioritizationFees do
    defstruct [:fees]

    def from_json(fees) when is_list(fees) do
      %RecentPrioritizationFees{fees: fees}
    end
  end

  defmodule SignaturesForAddress do
    defstruct [:signatures]

    def from_json(signatures) when is_list(signatures) do
      %SignaturesForAddress{signatures: signatures}
    end
  end

  defmodule SignatureStatuses do
    defstruct [:statuses]

    def from_json(statuses) when is_list(statuses) do
      %SignatureStatuses{statuses: statuses}
    end
  end

  defmodule Slot do
    defstruct [:slot]

    def from_json(slot) do
      %Slot{slot: slot}
    end
  end

  defmodule SlotLeader do
    defstruct [:leader]

    def from_json(leader) do
      %SlotLeader{leader: leader}
    end
  end

  defmodule SlotLeaders do
    defstruct [:leaders]

    def from_json(leaders) when is_list(leaders) do
      %SlotLeaders{leaders: leaders}
    end
  end

  defmodule StakeMinimumDelegation do
    defstruct [:lamports]

    def from_json(lamports) do
      %StakeMinimumDelegation{lamports: lamports}
    end
  end

  defmodule Supply do
    defstruct [:total, :circulating, :non_circulating, :non_circulating_accounts]

    def from_json(%{
          "total" => total,
          "circulating" => circulating,
          "nonCirculating" => non_circulating,
          "nonCirculatingAccounts" => non_circulating_accounts
        }) do
      %Supply{
        total: total,
        circulating: circulating,
        non_circulating: non_circulating,
        non_circulating_accounts: non_circulating_accounts
      }
    end
  end

  defmodule TokenAccountBalance do
    defstruct [:amount, :decimals, :ui_amount, :ui_amount_string]

    def from_json(%{
          "amount" => amount,
          "decimals" => decimals,
          "uiAmount" => ui_amount,
          "uiAmountString" => ui_amount_string
        }) do
      %TokenAccountBalance{
        amount: amount,
        decimals: decimals,
        ui_amount: ui_amount,
        ui_amount_string: ui_amount_string
      }
    end
  end

  defmodule TokenAccountsByDelegate do
    defstruct [:accounts]

    def from_json(accounts) when is_list(accounts) do
      %TokenAccountsByDelegate{accounts: accounts}
    end
  end

  defmodule TokenAccountsByOwner do
    defstruct [:accounts]

    def from_json(accounts) when is_list(accounts) do
      %TokenAccountsByOwner{accounts: accounts}
    end
  end

  defmodule TokenLargestAccounts do
    defstruct [:accounts]

    def from_json(accounts) when is_list(accounts) do
      %TokenLargestAccounts{accounts: accounts}
    end
  end

  defmodule TokenSupply do
    defstruct [:amount, :decimals, :ui_amount, :ui_amount_string]

    def from_json(%{
          "amount" => amount,
          "decimals" => decimals,
          "uiAmount" => ui_amount,
          "uiAmountString" => ui_amount_string
        }) do
      %TokenSupply{
        amount: amount,
        decimals: decimals,
        ui_amount: ui_amount,
        ui_amount_string: ui_amount_string
      }
    end
  end

  defmodule Transaction do
    # TODO: Parse transaction details
    defstruct [:slot, :transaction, :block_time, :meta]

    def from_json(%{
          "slot" => slot,
          "transaction" => transaction,
          "blockTime" => block_time,
          "meta" => meta
        }) do
      %Transaction{
        slot: slot,
        transaction: transaction,
        block_time: block_time,
        meta: meta
      }
    end
  end

  defmodule TransactionCount do
    defstruct [:count]

    def from_json(count) do
      %TransactionCount{count: count}
    end
  end

  defmodule Version do
    defstruct [:solana_core, :feature_set]

    def from_json(%{
          "solana-core" => solana_core,
          "feature-set" => feature_set
        }) do
      %Version{
        solana_core: solana_core,
        feature_set: feature_set
      }
    end
  end

  defmodule VoteAccounts do
    defstruct [:current, :delinquent]

    def from_json(%{
          "current" => current,
          "delinquent" => delinquent
        }) do
      %VoteAccounts{
        current: current,
        delinquent: delinquent
      }
    end
  end

  defmodule BlockhashValid do
    defstruct [:valid]

    def from_json(valid) do
      %BlockhashValid{valid: valid}
    end
  end

  defmodule MinimumLedgerSlot do
    defstruct [:slot]

    def from_json(slot) do
      %MinimumLedgerSlot{slot: slot}
    end
  end

  defmodule RequestAirdrop do
    defstruct [:signature]

    def from_json(signature) do
      %RequestAirdrop{signature: signature}
    end
  end

  defmodule SendTransaction do
    defstruct [:signature]

    def from_json(signature) do
      %SendTransaction{signature: signature}
    end
  end

  defmodule SimulateTransaction do
    defstruct [:err, :logs, :accounts, :units_consumed, :return_data, :inner_instructions]

    def from_json(%{
          "err" => err,
          "logs" => logs,
          "accounts" => accounts,
          "unitsConsumed" => units_consumed,
          "returnData" => return_data,
          "innerInstructions" => inner_instructions
        }) do
      %SimulateTransaction{
        err: err,
        logs: logs,
        accounts: accounts,
        units_consumed: units_consumed,
        return_data: return_data,
        inner_instructions: inner_instructions
      }
    end
  end
end
