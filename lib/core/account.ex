defmodule SolanaEx.Account do
  alias Ed25519

  defstruct [:address, :lamports, :owner, :data, :executable, :rent_epoch, :space]

  def find_program_address(_seeds, _program_id) do
  end
end
