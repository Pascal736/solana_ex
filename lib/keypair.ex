defmodule SolanaEx.KeyPair do
  alias Ed25519

  @derive {Inspect, only: [:public_key]}
  defstruct [:public_key, :secret_key]

  def new() do
    {priv, pub} = Ed25519.generate_key_pair()

    %__MODULE__{
      secret_key: priv,
      public_key: pub
    }
  end

  def pubkey(%__MODULE__{public_key: nil}), do: {:error, :public_key_not_set}
  def pubkey(%__MODULE__{public_key: pubkey}), do: {:ok, pubkey}

  def pubkey!(%__MODULE__{public_key: nil}), do: raise("Public key is not set")
  def pubkey!(%__MODULE__{public_key: pubkey}), do: pubkey

  def private_key(%__MODULE__{secret_key: nil}), do: {:error, :private_key_not_set}
  def private_key(%__MODULE__{secret_key: privkey}), do: {:ok, privkey}

  def private_key!(%__MODULE__{secret_key: nil}), do: raise("Private key is not set")
  def private_key!(%__MODULE__{secret_key: privkey}), do: privkey

  def is_valid?(%__MODULE__{public_key: pub, secret_key: secret})
      when byte_size(pub) == 32 and byte_size(secret) == 32 do
    pub == Ed25519.derive_public_key(secret)
  end

  def is_valid?(_), do: false

  def from_file(), do: nil

  def from_bytes(bytes) when byte_size(bytes) == 64 do
    <<private_key::binary-size(32), public_key::binary-size(32)>> = bytes

    case Ed25519.derive_public_key(private_key) != public_key do
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

  def to_bytes(%__MODULE__{} = keypair) do
    "#{keypair.secret_key}#{keypair.public_key}"
  end

  def to_files(name, %__MODULE__{} = keypair) do
  end

  def is_on_curve?(%__MODULE__{public_key: pub}), do: Ed25519.on_curve?(pub)
  def is_on_curve?(key), do: Ed25519.on_curve?(key)
end
