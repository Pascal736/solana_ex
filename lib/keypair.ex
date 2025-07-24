defmodule SolanaEx.KeyPair do
  @moduledoc """
  A key pair structure for Solana Ed25519 cryptographic operations.

  This module provides functionality for generating, validating, and managing
  Ed25519 key pairs used in Solana blockchain operations. Each key pair consists
  of a 32-byte private key and a corresponding 32-byte public key.

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> {:ok, pubkey} = SolanaEx.KeyPair.pubkey(keypair)
      iex> byte_size(pubkey)
      32

      iex> SolanaEx.KeyPair.is_valid?(SolanaEx.KeyPair.new())
      true
  """

  alias Ed25519
  alias Base58

  defstruct [:public_key, :secret_key]

  defimpl Inspect, for: SolanaEx.KeyPair do
    import Inspect.Algebra

    def inspect(%SolanaEx.KeyPair{public_key: nil}, _opts) do
      "#SolanaEx.KeyPair<public_key: nil>"
    end

    def inspect(%SolanaEx.KeyPair{public_key: public_key}, _opts) do
      base58_pubkey = Base58.encode(public_key)

      concat([
        "#SolanaEx.KeyPair<",
        "public_key: ",
        base58_pubkey,
        ">"
      ])
    end
  end

  @doc """
  Generates a new random Ed25519 key pair.

  The private key is 32 bytes and the public key is derived from it.

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> byte_size(keypair.public_key)
      32
      iex> byte_size(keypair.secret_key)
      32
      iex> SolanaEx.KeyPair.is_valid?(keypair)
      true
  """
  @spec new() :: %__MODULE__{}
  def new() do
    {priv, pub} = Ed25519.generate_key_pair()

    %__MODULE__{
      secret_key: priv,
      public_key: pub
    }
  end

  @doc """
  Gets the public key from the key pair.

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> {:ok, pubkey} = SolanaEx.KeyPair.pubkey(keypair)
      iex> is_binary(pubkey) and byte_size(pubkey) == 32
      true

      iex> invalid_keypair = %SolanaEx.KeyPair{public_key: nil, secret_key: <<1::256>>}
      iex> SolanaEx.KeyPair.pubkey(invalid_keypair)
      {:error, :public_key_not_set}
  """
  @spec pubkey(%__MODULE__{}) :: {:ok, binary()} | {:error, :public_key_not_set}
  def pubkey(%__MODULE__{public_key: nil}), do: {:error, :public_key_not_set}
  def pubkey(%__MODULE__{public_key: pubkey}), do: {:ok, pubkey}

  @doc """
  Raising version of `pubkey/1`.
  """
  @spec pubkey!(%__MODULE__{}) :: binary()
  def pubkey!(%__MODULE__{public_key: nil}), do: raise("Public key is not set")
  def pubkey!(%__MODULE__{public_key: pubkey}), do: pubkey

  @doc """
  Gets the private key from a key pair.

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> {:ok, privkey} = SolanaEx.KeyPair.private_key(keypair)
      iex> is_binary(privkey) and byte_size(privkey) == 32
      true

      iex> invalid_keypair = %SolanaEx.KeyPair{public_key: <<1::256>>, secret_key: nil}
      iex> SolanaEx.KeyPair.private_key(invalid_keypair)
      {:error, :private_key_not_set}
  """
  @spec private_key(%__MODULE__{}) :: {:ok, binary()} | {:error, :private_key_not_set}
  def private_key(%__MODULE__{secret_key: nil}), do: {:error, :private_key_not_set}
  def private_key(%__MODULE__{secret_key: privkey}), do: {:ok, privkey}

  @doc """
  Raising version of `private_key/1`.
  """
  @spec private_key!(%__MODULE__{}) :: binary()
  def private_key!(%__MODULE__{secret_key: nil}), do: raise("Private key is not set")
  def private_key!(%__MODULE__{secret_key: privkey}), do: privkey

  @doc """
  Validates that a key pair is cryptographically valid.

  Checks that both keys are 32 bytes and that the public key correctly corresponds
  to the private key according to Ed25519 mathematics.

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> SolanaEx.KeyPair.is_valid?(keypair)
      true

      iex> invalid_keypair = %SolanaEx.KeyPair{public_key: <<0::256>>, secret_key: <<1::256>>}
      iex> SolanaEx.KeyPair.is_valid?(invalid_keypair)
      false

      iex> SolanaEx.KeyPair.is_valid?("not a keypair")
      false
  """
  @spec is_valid?(%__MODULE__{}) :: boolean()
  def is_valid?(%__MODULE__{public_key: pub, secret_key: secret})
      when byte_size(pub) == 32 and byte_size(secret) == 32 do
    pub == Ed25519.derive_public_key(secret)
  end

  def is_valid?(_), do: false

  @doc """
  Loads a key pair from a file containing a JSON array of bytes.

  Reads a file containing a JSON array of 64 integers (0-255) and constructs a key pair.
  The format expects the first 32 bytes to be the private key and the last 32 bytes
  to be the public key.

  ## Parameters
  - `filename` - The path to the key pair file to load

  ## Returns
  - `{:ok, keypair}` - If the file was successfully loaded and is valid
  - `{:error, reason}` - If there was an error reading the file or parsing the content

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> {:ok, filename} = SolanaEx.KeyPair.to_file("test.json", keypair)
      iex> {:ok, loaded_keypair} = SolanaEx.KeyPair.from_file(filename)
      iex> SolanaEx.KeyPair.is_valid?(loaded_keypair)
      true

      iex> SolanaEx.KeyPair.from_file("nonexistent.json")
      {:error, :file_not_found}

      iex> File.write!("invalid.json", ~s|{"not": "array"}|)
      iex> SolanaEx.KeyPair.from_file("invalid.json")
      {:error, :expected_array}
  """
  @spec from_file(String.t()) :: {:ok, %__MODULE__{}} | {:error, atom() | {atom(), integer()}}
  def from_file(filename) do
    with {:ok, content} <- File.read(filename),
         {:ok, byte_list} <- Jason.decode(content),
         {:ok, bytes} <- validate_and_convert_bytes(byte_list) do
      from_bytes(bytes)
    else
      {:error, :enoent} -> {:error, :file_not_found}
      {:error, %Jason.DecodeError{}} -> {:error, :invalid_json}
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_and_convert_bytes(byte_list) when is_list(byte_list) do
    cond do
      length(byte_list) != 64 ->
        {:error, {:invalid_keypair_size, length(byte_list)}}

      not Enum.all?(byte_list, &is_integer/1) ->
        {:error, :non_integer_values}

      not Enum.all?(byte_list, &(&1 >= 0 and &1 <= 255)) ->
        {:error, :invalid_byte_range}

      true ->
        {:ok, :binary.list_to_bin(byte_list)}
    end
  end

  defp validate_and_convert_bytes(_) do
    {:error, :expected_array}
  end

  @doc """
  Creates a key pair from a 64-byte binary.

  The binary should contain the 32-byte private key followed by the 32-byte public key.
  Validates that the public key corresponds to the private key.

  ## Parameters
  - `bytes` - A 64-byte binary containing private key (first 32 bytes) and public key (last 32 bytes)

  ## Returns
  - `{:ok, keypair}` - If the binary is valid and keys match
  - `{:error, :invalid_keypair}` - If the public key doesn't match the private key
  - `{:error, {:invalid_size, size}}` - If the binary is not exactly 64 bytes
  - `{:error, :not_binary}` - If the input is not a binary

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> bytes = SolanaEx.KeyPair.to_bytes(keypair)
      iex> {:ok, restored_keypair} = SolanaEx.KeyPair.from_bytes(bytes)
      iex> SolanaEx.KeyPair.is_valid?(restored_keypair)
      true

      iex> SolanaEx.KeyPair.from_bytes(<<1, 2, 3>>)
      {:error, {:invalid_size, 3}}
  """
  def from_bytes(bytes) when byte_size(bytes) == 64 do
    <<private_key::binary-size(32), public_key::binary-size(32)>> = bytes

    case Ed25519.derive_public_key(private_key) == public_key do
      true -> {:ok, %__MODULE__{secret_key: private_key, public_key: public_key}}
      false -> {:error, :invalid_keypair}
    end
  end

  def from_bytes(bytes) when is_binary(bytes) do
    {:error, {:invalid_size, byte_size(bytes)}}
  end

  def from_bytes(_) do
    {:error, :not_binary}
  end

  @doc """
  Converts a key pair to a 64-byte binary representation.

  The binary contains the 32-byte private key followed by the 32-byte public key.
  This format is compatible with `from_bytes/1`.

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> bytes = SolanaEx.KeyPair.to_bytes(keypair)
      iex> byte_size(bytes)
      64

      iex> keypair = SolanaEx.KeyPair.new()
      iex> bytes = SolanaEx.KeyPair.to_bytes(keypair)
      iex> {:ok, restored} = SolanaEx.KeyPair.from_bytes(bytes)
      iex> restored.public_key == keypair.public_key
      true
  """
  @spec to_bytes(%__MODULE__{}) :: binary()
  def to_bytes(%__MODULE__{} = keypair) do
    "#{keypair.secret_key}#{keypair.public_key}"
  end

  @doc """
  Saves a key pair to a file in JSON array format.

  The key pair is saved as a JSON array of 64 integers (0-255), where the first 32 bytes
  represent the private key and the last 32 bytes represent the public key. This format
  is compatible with standard Solana tooling.

  ## Parameters
  - `filename` - The path where the key pair file should be saved
  - `keypair` - The key pair to save

  ## Returns
  - `{:ok, filename}` - If the file was successfully written
  - `{:error, reason}` - If writing failed (file permissions, disk space, etc.)

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> {:ok, filename} = SolanaEx.KeyPair.to_file("test_keypair.json", keypair)
      iex> File.exists?(filename)
      true

      iex> keypair = SolanaEx.KeyPair.new()
      iex> SolanaEx.KeyPair.to_file("/invalid/path/keypair.json", keypair)
      {:error, :enoent}
  """
  @spec to_file(String.t(), %__MODULE__{}) :: {:ok, String.t()} | {:error, atom()}
  def to_file(filename, %__MODULE__{} = keypair) do
    bytes = to_bytes(keypair)
    byte_list = :binary.bin_to_list(bytes)

    with {:ok, json_content} <- Jason.encode(byte_list),
         :ok <- File.write(filename, json_content) do
      {:ok, filename}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Checks if a public key or key pair's public key is on the Ed25519 curve.

  Can accept either a key pair struct or a raw public key binary.

  ## Examples

      iex> keypair = SolanaEx.KeyPair.new()
      iex> SolanaEx.KeyPair.is_on_curve?(keypair)
      true

      iex> keypair = SolanaEx.KeyPair.new()
      iex> SolanaEx.KeyPair.is_on_curve?(keypair.public_key)
      true
  """
  @spec is_on_curve?(%__MODULE__{} | binary()) :: boolean()
  def is_on_curve?(%__MODULE__{public_key: pub}), do: Ed25519.on_curve?(pub)
  def is_on_curve?(key), do: Ed25519.on_curve?(key)
end
