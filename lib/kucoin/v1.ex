defmodule KuCoin.V1 do
  import KuCoin.Params, only: [param: 2, param: 3]

  alias KuCoin.V1.{Conn, Pagination, SubUser, Account, AccountLedger}

  @type error :: Tesla.Env.t() | Kina.Parser.Error.t() | KuCoin.Params.Error.t()

  @doc """
  Lists the user info of all sub-users.

  https://docs.kucoin.com/#user-info

  Example:

      iex> KuCoin.V1.list_sub_users(conn)
      {:ok, [
        %KuCoin.V1.SubUser{
          user_id: "5cbd31ab9c93e9280cd36a0a",
          sub_name: "kucoin1",
          remarks: "kucoin1"
        },
        %KuCoin.V1.SubUser{
          user_id: "5cbd31b89c93e9280cd36a0d",
          sub_name: "kucoin2",
          remarks: "kucoin2"
        }
      ]}
  """

  @spec list_sub_users(Conn.t()) ::
          {:ok, [SubUser.t()]} | {:error, Tesla.Env.t()}
  def list_sub_users(%Conn{} = conn) do
    client(conn)
    |> Tesla.get("/sub/user")
    |> response({:list, SubUser})
  end

  @doc """
  Creates a new account and returns the `id`.

  https://docs.kucoin.com/#create-an-account

  Example:

      iex> account = %KuCoin.V1.Account{type: "trade", currency: "BTC"}
      iex> KuCoin.V1.create_account(conn)
      {:ok, "5bd6e9286d99522a52e458de"}
  """

  @spec create_account(Conn.t(), Account.t()) ::
          {:ok, String.t()} | {:error, Tesla.Env.t()}
  def create_account(%Conn{} = conn, %Account{} = account) do
    body = %{type: account.type, currency: account.currency}

    result =
      client(conn)
      |> Tesla.post("/accounts", body)
      |> response(Account)

    with {:ok, %Account{id: id}} <- result do
      {:ok, id}
    end
  end

  @doc """
  Lists all accounts.

  https://docs.kucoin.com/#list-accounts

  Example:

      iex> KuCoin.V1.list_accounts(conn, type: "main", currency: "BTC")
      {:ok, [
        %KuCoin.V1.Account{
          id: "5bd6e9286d99522a52e458de",
          currency: "BTC",
          type: "main",
          balance: "237582.04299",
          available: "237582.032",
          holds: "0.01099"
        }
      ]}
  """

  @params [
    param(:type, :string),
    param(:currency, :string)
  ]

  @spec list_accounts(Conn.t(), Keyword.t()) ::
          {:ok, [Account.t()]} | {:error, Tesla.Env.t()}
  def list_accounts(%Conn{} = conn, params \\ []) when is_list(params) do
    with {:ok, params} <- KuCoin.Params.parse(params, @params) do
      client(conn)
      |> Tesla.get("/accounts", query: params)
      |> response({:list, Account})
    end
  end

  @doc """
  Gets an account by it's `id`.

  https://docs.kucoin.com/#get-an-account

  Example:

      iex> KuCoin.V1.get_account(conn, "5bd6e9286d99522a52e458de")
      {:ok, %KuCoin.V1.Account{
        currency: "BTC",
        balance: "237582.04299",
        available: "237582.032",
        holds: "0.01099"
      }}
  """

  @spec get_account(Conn.t(), String.t()) ::
          {:ok, Account.t()} | {:error, Tesla.Env.t()}
  def get_account(%Conn{} = conn, id) when is_binary(id) do
    client(conn)
    |> Tesla.get("/accounts/" <> id)
    |> response(Account)
  end

  @doc """
  Lists an account's ledgers

  https://docs.kucoin.com/#get-account-ledgers

  Example:

      iex> KuCoin.V1.get_account(conn, "5bd6e9286d99522a52e458de")
      {:ok, %KuCoin.V1.Account{
        currency: "BTC",
        balance: "237582.04299",
        available: "237582.032",
        holds: "0.01099"
      }}
  """

  @params [
    param(:currency, {:list, :string}),
    param(:direction, :string),
    param(:biz_type, :string, key: :bizType),
    param(:start_at, :integer, key: :startAt),
    param(:end_at, :integer, key: :endAt)
  ]

  @spec list_account_ledgers(Conn.t(), Keyword.t()) ::
          {:ok, [AccountLedger.t()], Pagination.t()} | {:error, Tesla.Env.t()}
  def list_account_ledgers(%Conn{} = conn, params \\ []) when is_list(params) do
    with {:ok, params} <- KuCoin.Params.parse(params, @params) do
      client(conn)
      |> Tesla.get("/accounts/ledgers", query: params)
      |> paginated_response({:list, AccountLedger})
    end
  end

  @spec client(Conn.t()) :: Tesla.Client.t()
  defp client(conn) do
    middleware = [
      {Tesla.Middleware.BaseUrl, conn.base_url},
      Tesla.Middleware.JSON,
      {KuCoin.V1.Middleware.Auth, conn: conn}
    ]

    Tesla.client(middleware)
  end

  @spec response(Tesla.Env.result(), Kina.type()) ::
          {:ok, any()} | {:error, Tesla.Env.t()}
  defp response(
         {:ok, %Tesla.Env{status: status} = response},
         _schema
       )
       when status not in 200..299 do
    {:error, response}
  end

  defp response(
         {:ok, %Tesla.Env{body: %{"code" => code}} = response},
         _type
       )
       when code != "200000" do
    {:error, response}
  end

  defp response({:ok, %Tesla.Env{body: body}}, type) do
    try do
      {:ok, Kina.Parser.parse(body["data"], type)}
    catch
      error ->
        {:error, error}
    end
  end

  defp response({:error, _} = error, _schema) do
    error
  end

  @spec paginated_response(Tesla.Env.result(), Kina.type()) ::
          {:ok, any()} | {:error, Tesla.Env.t()}
  defp paginated_response(
         {:ok, %Tesla.Env{status: status} = response},
         _schema
       )
       when status not in 200..299 do
    {:error, response}
  end

  defp paginated_response(
         {:ok, %Tesla.Env{body: %{"code" => code}} = response},
         _type
       )
       when code != "200000" do
    {:error, response}
  end

  defp paginated_response({:ok, %Tesla.Env{body: body}}, type) do
    try do
      result = Kina.Parser.parse(body["data"]["items"], type)
      pagination = Kina.Parser.parse(body["data"], Pagination)
      {:ok, result, pagination}
    catch
      error ->
        {:error, error}
    end
  end

  defp paginated_response({:error, _} = error, _schema) do
    error
  end
end
