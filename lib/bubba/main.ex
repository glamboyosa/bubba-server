defmodule Main do
  @moduledoc """
  This file is responsible for generating our daily word AND checking if the answer is correct and returning the shape of data we want.
  """
  def generate_random_word do
    {Application.app_dir(:bubba, Path.join(["priv", "current_word.txt"])),
     Application.app_dir(:bubba, Path.join(["priv", "words.txt"]))}
    |> generate
  end

  def verify_answer(answer, attempts) do
    load_words(Application.app_dir(:bubba, Path.join(["priv", "current_word.txt"])))
    |> String.split("\n", trim: true)
    |> compare(answer, attempts)
  end

  defp generate({current_word_path, words_path}) do
    IO.puts(words_path)

    random_word =
      load_words(words_path)
      |> String.split("\n", trim: true)
      |> Enum.random()

    # Log the random word to the Fly / local terminal
    IO.puts(random_word)

    File.write(
      Application.app_dir(:bubba, Path.join(["priv", "current_word.txt"])),
      Base.encode64(random_word),
      [:write]
    )
  end

  defp compare(word, answer, attempts) do
    [word] = word
    word = Base.decode64(word) |> String.split("", trim: true)

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
              %{bg: '#fff', letter: letter_in_answer}

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
