defmodule KuCoin.V1.Conn do
  defstruct key: nil,
            secret: nil,
            passphrase: nil,
            key_version: "v2",
            base_url: "https://api.kucoin.com/api/v1"

  @type t :: %__MODULE__{
          key: String.t(),
          secret: String.t(),
          passphrase: String.t(),
          key_version: String.t(),
          base_url: String.t()
        }
end
