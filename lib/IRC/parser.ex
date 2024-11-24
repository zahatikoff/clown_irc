defmodule IRC.Parser do
  alias IRC.Message

  def parse!(raw_message) when is_binary(raw_message) do
    with {:ok, tags, rest} <- parse_tags(raw_message),
         {:ok, user, rest} <- parse_sender(rest),
         {:ok, command, rest} <- parse_command(rest),
         {:ok, args, ""} <- parse_args(rest) do
      %Message{
        tags: tags,
        sender: user,
        command: command,
        args: args
      }
    end
  end

  defp is_tag_invalid?(tag_string) when is_binary(tag_string) do
    String.contains?(tag_string, [" ", ";", "\r", "\n"])
  end

  defp parse_tags(<<?@, message::binary>>) do
    [tag_chunk, rest] = String.split(message, " ", trim: true, parts: 2)
    raw_tags = String.split(tag_chunk, ";", trim: true)

    if(Enum.any?(raw_tags, &is_tag_invalid?/1)) do
      tag_map =
        raw_tags
        |> Enum.map(&String.split(&1, "=", trim: true))
        |> Enum.reduce(%{}, fn
          [key], acc -> Map.put(acc, key, [])
          [key, value], acc -> Map.put(acc, key, value)
        end)

      {:ok, tag_map, rest}
    else
      {:error, Enum.find(raw_tags, "bad tag", &is_tag_invalid?/1), rest}
    end
  end

  defp parse_tags(rest) do
    {:ok, %{}, rest}
  end

  defp parse_sender(<<?:, message::binary>>) do
    [sender, rest] = String.split(message, " ", trim: true, parts: 2)
    {:ok, sender, rest}
  end

  defp parse_sender(rest) do
    {:ok, "", rest}
  end

  defp parse_command(message) when is_binary(message) do
    [command, rest] = String.split(message, " ", trim: true, parts: 2)
    {:ok, command, rest}
  end

  defp parse_args(<<message::binary>>) do
    args =
      case String.contains?(message, ":") do
        true ->
          [p, t] = String.split(message, ":", parts: 2)
          List.flatten([String.split(p, " ", trim: true), t])

        false ->
          String.split(message, " ", parts: 2)
      end

    {:ok, args, ""}
  end
end
