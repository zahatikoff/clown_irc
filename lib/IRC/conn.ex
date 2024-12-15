defmodule IRC.Conn do
  @type t() :: %IRC.Conn{
          server: String.t(),
          port: non_neg_integer(),
          nick: String.t(),
          password: String.t()
        }

  @enforce_keys [:server, :port, :nick]
  defstruct [:server, :port, :nick, :password]

  defp nickname_valid?(<<?#, _rest::binary>>), do: false
  defp nickname_valid?(<<?:, _rest::binary>>), do: false

  defp nickname_valid?(nickname) do
    not String.contains?(nickname, ["\0", "\n", "\r", " "])
  end

  def new(server, port \\ 6667, username \\ "clown_bot", password \\ "") do
    username =
      if(nickname_valid?(username)) do
        username
      else
        "clown_bot"
      end

    %IRC.Conn{
      server: String.to_charlist(server),
      port: port,
      nick: username,
      password: password
    }
  end
end
