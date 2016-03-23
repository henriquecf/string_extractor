defmodule HtmlContent do
  @frase_in_html_pattern ~r{>(?<text>[^<>]+)<}
  @html_attr_pattern ~r{\w=\"}
  @html_symbol_pattern ~r/&\w{4,5};/
  @single_punctuation_pattern ~r/^[\?\:\,]\s*$/
  @path_pattern ~r/^\/\w+\/$/
  @strings_with_params_pattern ~r{params\[\:\w+\]}
  @only_numbers_pattern ~r{^\d+\s*$}
  @percentage_pattern ~r(^\s*\d\d%\s*$)
  @number_currency_pattern ~r/^\s*?\$?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?$/
  @currency_symbol_pattern ~r/^\s*\$\s*$/

  def map_text_from_html_file(file_path) do
    file_path
    |> File.stream!
    |> Stream.map(&(Regex.scan(@frase_in_html_pattern, &1)))
    |> remove_empty_arrays
    |> Stream.map(&get_only_relevant_pattern/1)
    |> Stream.map(&filter_out_html_attrs/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_html_symbols/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_question_marks/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_paths/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_strs_with_params/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_only_numbers/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_percentage/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_number_currency/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_currency_symbol/1)
    |> remove_empty_arrays
    |> Stream.map(&filter_out_only_spaces/1)
    |> remove_empty_arrays
    |> Stream.map(&extract_tranlatables/1)
    |> Enum.to_list
    |> List.flatten
    |> TranslatableList.from_list(file_path)
  end

  defp get_only_relevant_pattern(list) do
    Enum.map(list, fn(patterns) -> Enum.at(patterns, 1) end)
  end

  defp filter_out_html_attrs(list) do
    Enum.filter(list, fn(line) -> !Regex.match?(@html_attr_pattern, line) end)
  end

  defp filter_out_html_symbols(list) do
    Enum.filter(list, fn(line) -> !Regex.match?(@html_symbol_pattern, line) end)
  end

  defp filter_out_only_spaces(list) do
    Enum.filter(list, fn(line) -> !Regex.match?(~r{^\s*$}, line) end)
  end

  defp filter_out_question_marks(list) do
    Enum.filter(list, fn(str) -> !Regex.match?(@single_punctuation_pattern, str) end)
  end

  defp filter_out_paths(list) do
    Enum.filter(list, fn(str) -> !Regex.match?(@path_pattern, str) end)
  end

  defp filter_out_strs_with_params(list) do
    Enum.filter(list, fn(str) -> !Regex.match?(@strings_with_params_pattern, str) end)
  end

  defp filter_out_only_numbers(list) do
    Enum.filter(list, fn(str) -> !Regex.match?(@only_numbers_pattern, str) end)
  end

  defp filter_out_percentage(list) do
    Enum.filter(list, fn(str) -> !Regex.match?(@percentage_pattern, str) end)
  end

  defp filter_out_number_currency(list) do
    Enum.filter(list, fn(str) -> !Regex.match?(@number_currency_pattern, str) end)
  end

  defp filter_out_currency_symbol(list) do
    Enum.filter(list, fn(str) -> !Regex.match?(@currency_symbol_pattern, str) end)
  end

  defp remove_empty_arrays(stream) do
    Stream.filter(stream, &(length(&1) != 0))
  end

  defp extract_tranlatables(stream) do
    Enum.map(stream, &Translatable.from_original/1)
  end
  # Read file by line

  # Find in each line all the texts that match pattern -> between >TEXT<

  # Get text, downcase_underscore_key, the {file, line}(s) it was found and put in struct (non duplicated)

  # Change the text for t(underscore_text, default: "Underscore Text")

  # Put the key in the yml file (if not already there)
end
