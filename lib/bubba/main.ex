defmodule Main do
  @moduledoc """
  Documentation for `Main`.

  This file is responsible for generating our daily word AND checking if the answer is correct and returning the shape of data we want
  """
  def generate_random_word do
    {Application.app_dir(:bubba, Path.join(["lib", "bubba", "current_word.txt"])),
     Application.app_dir(:bubba, Path.join(["lib", "bubba", "words.txt"]))}
    |> generate
  end

  def verify_answer(answer, attempts) do
    load_words(Application.app_dir(:bubba, Path.join(["lib", "bubba", "current_word.txt"])))
    |> String.split("", trim: true)
    |> compare(answer, attempts)
  end

  defp generate({current_word_path, words_path}) do
    cond do
      File.exists?(current_word_path) ->
        File.rm!(current_word_path)

      true ->
        random_word =
          load_words(words_path)
          |> String.split("\n", trim: true)
          |> Enum.random()

        File.write(
          random_word,
          Application.app_dir(:bubba, Path.join(["lib", "bubba", "current_word"]))
        )

        nil
    end
  end

  defp compare(word, answer, attempts) do
    result =
      for {letter_in_answer, answer_index} <-
            Enum.with_index(String.split(answer, "", trim: true), &{&1, &2}) do
        for {letter_in_word, word_index} <- Enum.with_index(word, &{&1, &2}) do
          cond do
            letter_in_answer == letter_in_word && answer_index == word_index ->
              %{bg: '#00ff00', letter: letter_in_answer}

            letter_in_answer == letter_in_word ->
              %{bg: '#fcf55f', letter: letter_in_answer}

            Enum.member?(word, letter_in_answer) === false ->
              %{bg: '#000', letter: letter_in_answer}

            true ->
              ''
          end
        end
      end
      |> List.flatten()
      |> Enum.chunk_by(& &1)
      |> Enum.map(&Enum.uniq/1)
      |> List.flatten()

    word_from_result = result |> Enum.map(& &1.letter) |> List.to_string()

    cond do
      word_from_result == List.to_string(word) ->
        %{solved: true, attempts: attempts, data: result}

      true ->
        %{solved: false, attempts: attempts, data: result}
    end
  end

  defp load_words(filename) do
    case File.read(filename) do
      {:ok, binary} -> binary
      {:error, _reason} -> "That file doesn't exist welp 🥲"
    end
  end
end
