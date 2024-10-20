defmodule ClownIRC.Message do
  @moduledoc """
  This module contains the main defintion of the IRC message struct and
  methods or something
  """
  alias ClownIRC.Message

  @type t() :: %Message{
          tags: map(),
          source: nil | String.t(),
          command: String.t() | pos_integer(),
          args: list(String.t())
        }

  @doc """
   The main IRC package contains 4 fields
   1. The optional IRCv3 tags, a key-value store
   2. String indicating where the message came from
   3. The command/response field
   4. The command arguments
  """
  defstruct [:tags, :source, :command, :args]

  @doc """
  A function that returns a struct with the default values
  """
  def new() do
    %Message{
      tags: %{},
      source: nil,
      command: nil,
      args: []
    }
  end
end
