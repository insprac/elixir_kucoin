defmodule KuCoin.V1.SubUser do
  use Kina.Schema

  schema do
    field :user_id, :string, key: :userId
    field :sub_name, :string, key: :subName
    field :remarks, :string
  end
end
