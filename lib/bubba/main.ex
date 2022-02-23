defmodule Main do
  @moduledoc """
  This file is responsible for generating our daily word AND checking if the answer is correct and returning the shape of data we want.
  """
  def generate_random_word do
    Application.app_dir(:bubba, Path.join(["priv", "words.txt"]))
    |> generate
  end

  def verify_answer(answer, attempts) do
    load_words(Application.app_dir(:bubba, Path.join(["priv", "current_word.txt"])))
    |> String.split("\n", trim: true)
    |> compare(answer, attempts)
  end

  defp generate(words_path) do
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
    {:ok, word} = Base.decode64(word)
    word = word |> String.trim() |> String.split("", trim: true)

    {_popped, wod} =
      word
      |> Enum.with_index()
      |> Enum.map(fn {el, index} ->
        prev =
          cond do
            index !== 0 -> index - 1
            true -> 0
          end

        current = index

        cond do
          Enum.at(word, prev) === Enum.at(word, current) -> el
          true -> ''
        end
      end)
      |> List.pop_at(0)

    {_popped2, wod2} =
      String.split(answer, "", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {el, index} ->
        prev =
          cond do
            index !== 0 -> index - 1
            true -> 0
          end

        current = index

        cond do
          Enum.at(word, prev) === Enum.at(word, current) -> el
          true -> ''
        end
      end)
      |> List.pop_at(0)

    IO.puts(List.flatten(wod2) > 0)

    response =
      cond do
        length(List.flatten(wod)) > 0 || length(List.flatten(wod2)) > 0 ->
          res =
            for {letter_in_answer, answer_index} <-
                  Enum.with_index(String.split(answer, "", trim: true), &{&1, &2}) do
              for {letter_in_word, word_index} <- Enum.with_index(word, &{&1, &2}) do
                {prev_letter, _index} =
                  Enum.find(
                    Enum.with_index(word, &{&1, &2}),
                    fn {_word, index} ->
                      cond do
                        word_index == 0 -> index === word_index
                        word_index == length(word) - 1 -> index === length(word) - 1
                        true -> index === word_index - 1
                      end
                    end
                  )

                cond do
                  letter_in_answer == letter_in_word && answer_index == word_index ->
                    %{bg: "#00ff00", letter: letter_in_answer}

                  letter_in_answer == letter_in_word && letter_in_answer !== prev_letter ->
                    IO.puts(prev_letter)
                    %{bg: "#fcf55f", letter: letter_in_answer}

                  Enum.member?(word, letter_in_answer) === false ->
                    %{bg: "#fff", letter: letter_in_answer}

                  true ->
                    ''
                end
              end
            end
            |> List.flatten()
            |> Enum.chunk_by(& &1)
            |> Enum.map(&Enum.uniq/1)
            |> List.flatten()

          result =
            cond do
              answer == List.to_string(word) ->
                thing = Enum.chunk_by(res, & &1.letter) |> Enum.with_index()

                [[index, item]] =
                  Enum.map(thing, fn {array, index} ->
                    cond do
                      length(array) === 3 ->
                        [index | [Enum.filter(array, &(&1.bg !== "#fcf55f"))]]

                      true ->
                        ''
                    end
                  end)
                  |> Enum.filter(fn x ->
                    length(x) > 0
                  end)

                List.replace_at(thing, index, {item, index})
                |> Enum.map(fn {item, _index} ->
                  item
                end)
                |> List.flatten()

              true ->
                res
            end

          word_from_result = result |> Enum.map(& &1.letter) |> List.to_string()

          cond do
            word_from_result == List.to_string(word) ->
              %{solved: true, attempts: attempts, data: result}

            true ->
              %{
                solved: false,
                attempts: attempts,
                answer:
                  cond do
                    attempts == 6 -> List.to_string(word)
                    true -> nil
                  end,
                data: result
              }
          end

        true ->
          res =
            for {letter_in_answer, answer_index} <-
                  Enum.with_index(String.split(answer, "", trim: true), &{&1, &2}) do
              for {letter_in_word, word_index} <- Enum.with_index(word, &{&1, &2}) do
                {prev_letter, _index} =
                  Enum.find(
                    Enum.with_index(word, &{&1, &2}),
                    fn {_word, index} ->
                      cond do
                        word_index == 0 -> index === word_index
                        word_index == length(word) - 1 -> index === length(word) - 1
                        true -> index === word_index - 1
                      end
                    end
                  )

                cond do
                  letter_in_answer == letter_in_word && answer_index == word_index ->
                    %{bg: "#00ff00", letter: letter_in_answer}

                  letter_in_answer == letter_in_word && letter_in_answer !== prev_letter ->
                    IO.puts(prev_letter)
                    %{bg: "#fcf55f", letter: letter_in_answer}

                  Enum.member?(word, letter_in_answer) === false ->
                    %{bg: "#fff", letter: letter_in_answer}

                  true ->
                    ''
                end
              end
            end
            |> List.flatten()
            |> Enum.chunk_by(& &1)
            |> Enum.map(&Enum.uniq/1)
            |> List.flatten()

          word_from_result = res |> Enum.map(& &1.letter) |> List.to_string()

          cond do
            word_from_result == List.to_string(word) ->
              %{solved: true, attempts: attempts, data: res}

            true ->
              %{
                solved: false,
                attempts: attempts,
                answer:
                  cond do
                    attempts == 6 -> List.to_string(word)
                    true -> nil
                  end,
                data: res
              }
          end
      end

    response
  end

  defp load_words(filename) do
    case File.read(filename) do
      {:ok, binary} -> binary
      {:error, _reason} -> "That file doesn't exist welp 🥲"
    end
  end
end
