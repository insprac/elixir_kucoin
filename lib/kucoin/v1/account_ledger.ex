defmodule KuCoin.V1.AccountLedger do
  use Kina.Schema

  schema do
    field :id, :string
    field :currency, :string
    field :amount, :string
    field :fee, :string
    field :balance, :string
    field :biz_type, :string, key: :bizType
    field :direction, :string
    field :created_at, :integer, key: :createdAt
  end
end
