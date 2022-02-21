defmodule Main do
  @moduledoc """
  Documentation for `Main`.

  This file is responsible for generating our daily word AND checking if the answer is correct and returning the shape of data we want
  """

  def verify_answer({daily_word, answer}) do
    load_words("./words.txt")
    |> String.split("\n", trim: true)
  end

  def load_words(filename) do
    case File.read(filename) do
      {:ok, binary} -> binary
      {:error, _reason} -> "That file doesn't exist welp 🥲"
    end
  end
end
