defmodule KuCoin.Params do
  @type param :: {atom, Kina.type(), [param_option()]}
  @type param_option :: {:required, boolean} | {:key, atom}

  @spec param(atom, Kina.type(), [param_option()]) :: param
  def param(key, type, opts \\ []) do
    {key, type, opts}
  end

  @spec parse(Keyword.t(), [param]) ::
          {:ok, Keyword.t()} | {:error, KuCoin.Params.Error.t()}
  def parse(given, definitions), do: parse(given, definitions, [])

  @spec parse(Keyword.t(), [param], Keyword.t()) ::
          {:ok, Keyword.t()} | {:error, KuCoin.Params.Error.t()}
  def parse([], [], params), do: {:ok, params}

  def parse([], [{key, type, opts} | rem], params) do
    if {:required, true} in opts do
      message = "The following param was missing #{key}: #{inspect(type)}"
      {:error, %KuCoin.Params.Error{message: message}}
    else
      parse([], rem, params)
    end
  end

  def parse([{key, value} | rem], definitions, params) do
    case Enum.find(definitions, &(elem(&1, 0) == key)) do
      {key, type, opts} = definition ->
        with {:ok, value} <- parse_value(value, type) do
          key = Keyword.get(opts, :key, key)
          params = [{key, value} | params]
          definitions = List.delete(definitions, definition)
          parse(rem, definitions, params)
        end

      nil ->
        message = "Param not found or provided multiple times #{key}"
        {:error, %KuCoin.Params.Error{message: message}}
    end
  end

  @spec parse_value(any(), Kina.type()) ::
          {:ok, any()} | {:error, KuCoin.Params.Error.t()}
  defp parse_value(value, type) do
    try do
      parsed_value = Kina.Parser.parse(value, type)

      case type do
        {:list, _sub_type} ->
          {:ok, Enum.join(parsed_value, ",")}

        _ ->
          {:ok, parsed_value}
      end
    catch
      %Kina.Parser.Error{message: message} ->
        {:error, %KuCoin.Params.Error{message: message}}
    end
  end
end
