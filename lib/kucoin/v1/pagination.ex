defmodule KuCoin.V1.Pagination do
  use Kina.Schema

  schema do
    field :current_page, :integer, key: :currentPage
    field :page_size, :integer, key: :pageSize
    field :total_num, :integer, key: :totalNum
    field :total_page, :integer, key: :totalPage
  end
end
