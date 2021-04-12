defmodule KuCoin.Params.Error do
  defexception [:message]

  @type t :: %__MODULE__{message: String.t()}
end
