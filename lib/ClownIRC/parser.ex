defmodule ClownIRC.Parser do
  alias ClownIRC.Message

  @doc """
  The main parser funciton. For now it only provides some sort of parsing, but
  no input validation.
  """
  @spec parse!(binary()) :: Message.t()
  def parse!(message) when is_binary(message) do
    with {:ok, rest, tags} <- parse_tags(message),
         {:ok, rest, source} <- parse_source(rest),
         {:ok, rest, cmd} <- parse_command(rest),
         {:ok, "", args} <- parse_args(rest) do
      %Message{
        tags: tags,
        source: source,
        command: cmd,
        args: args
      }
      |> IO.inspect()
    else
      _ -> raise "Parsing failed"
    end
  end

  # this will do for now. Docs will wait until it is also working and stableish
  defp parse_tags(<<?@, message::binary>>) do
    # Will need to take a chunk of the string until the next space
    [tags, rest] = String.split(message, " ", trim: true, parts: 2)
    # Tag parsing
    # They are key=value; pairs separated by semicolons
    res_tags =
      String.split(tags, ";")
      |> Enum.reduce(
        %{},
        fn pair, acc ->
          [key, value] = String.split(pair, "=", parts: 2)
          Map.put(acc, key, value)
        end
      )

    {:ok, rest, res_tags}
    # if the thing fails then i think of something like
    # {:error,:bad_tag,tag}
  end

  # Second clause in case we do not have our message start with "@"
  defp parse_tags(message) when is_binary(message) do
    {:ok, message, %{}}
  end

  defp parse_source(<<?:, message::binary>>) do
    [source, rest] = String.split(message, " ", trim: true, parts: 2)
    {:ok, rest, source}
  end

  defp parse_source(message) when is_binary(message) do
    {:ok, message, ""}
  end

  defp parse_command(message) when is_binary(message) do
    [command | rest] = String.split(message, " ", parts: 2)

    if(Enum.empty?(rest)) do
      {:error, :no_args}
    else
      {:ok, List.first(rest), command}
    end
  end

  defp parse_args(message) when is_binary(message) do
    [args | final] = String.split(message, ":", trim: true, parts: 2)

    res =
      [String.split(args, " ", trim: true) | final]
      |> List.flatten()

    {:ok, "", res}
  end
end
