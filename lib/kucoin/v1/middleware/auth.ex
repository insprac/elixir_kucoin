defmodule KuCoin.V1.Middleware.Auth do
  @behaviour Tesla.Middleware

  @impl true
  def call(env, next, opts) do
    case Keyword.get(opts, :conn) do
      %KuCoin.V1.Conn{} = conn ->
        timestamp = (DateTime.utc_now() |> DateTime.to_unix()) * 1000
        signature = signature(env, conn, timestamp)

        env
        |> Tesla.put_header("kc-api-key", conn.key)
        |> Tesla.put_header("kc-api-sign", signature)
        |> Tesla.put_header("kc-api-timestamp", "#{timestamp}")
        |> Tesla.put_header("kc-api-passphrase", conn.passphrase)
        |> Tesla.put_header("kc-api-key-version", conn.key_version)
        |> Tesla.run(next)

      nil ->
        Tesla.run(env, next)
    end
  end

  @spec signature(Tesla.Env.t(), KuCoin.V1.Conn.t(), integer) :: String.t()
  defp signature(env, conn, timestamp) do
    body = env.body || ""
    path = path(env)
    method = String.upcase("#{env.method}")

    :crypto.hmac(:sha256, conn.secret, "#{timestamp}#{method}#{path}#{body}")
    |> Base.encode64()
  end

  @spec path(Tesla.Env.t()) :: String.t()
  defp path(env) do
    case Tesla.build_url(env.url, env.query) |> URI.parse() do
      %URI{path: path, query: nil} -> path
      %URI{path: path, query: query} -> path <> "?" <> query
    end
  end
end
