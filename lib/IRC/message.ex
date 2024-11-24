defmodule IRC.Message do
  @enforce_keys [:command, :args]

  @type t() :: %__MODULE__{
          tags: %{String.t() => String.t()},
          sender: String.t(),
          command: String.t() | non_neg_integer(),
          args: list(String.t())
        }
  defstruct [:tags, :sender, command: nil, args: []]
end
