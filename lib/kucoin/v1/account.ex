defmodule KuCoin.V1.Account do
  use Kina.Schema

  schema do
    field :id, :string
    field :currency, :string
    field :type, :string
    field :balance, :string
    field :available, :string
    field :holds, :string
  end
end
