defmodule HtmlContent do
  @frase_in_html_pattern ~r{>(?<text>[^<>]+)<}
  @html_attr_pattern ~r{\w=\"}
  @html_symbol_pattern ~r/&\w{4,5};/
  @single_punctuation_pattern ~r/^[\?\:\,]\s*$/
  @path_pattern ~r/^\/\w+\/$/
  @strings_with_params_pattern ~r{params\[\:\w+\]}
  @only_numbers_pattern ~r{^\d+\s*$}
  @percentage_pattern ~r(^\s*\d\d%\s*$)

  def map_text_from_html_file(file_path) do
    file_path
    |> File.stream!
    |> Stream.map(&(Regex.scan(@frase_in_html_pattern, &1)))
    |> Stream.filter(&(length(&1) != 0))
    |> Stream.map(&get_only_relevant_pattern/1)
    |> Stream.map(&filter_out_html_attrs/1)
    |> Stream.filter(&(length(&1) != 0))
    |> Stream.map(&filter_out_html_symbols/1)
    |> Stream.filter(&(length(&1) != 0))
    |> Stream.map(&filter_out_question_marks/1)
    |> Stream.filter(&(length(&1) != 0))
    |> Stream.map(&filter_out_paths/1)
    |> Stream.filter(&(length(&1) != 0))
    |> Stream.map(&filter_out_strs_with_params/1)
    |> Stream.filter(&(length(&1) != 0))
    |> Stream.map(&filter_out_only_numbers/1)
    |> Stream.filter(&(length(&1) != 0))
    |> Stream.map(&filter_out_percentage/1)
    |> Stream.filter(&(length(&1) != 0))
    #|> Stream.map(&strip_strs/1)
    #|> Stream.map(&filter_out_empty_strings/1)
    #|> Stream.filter(&(length(&1) != 0))
    |> Enum.to_list
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

  defp strip_strs(list) do
    Enum.map(list, fn(str) -> String.strip(str) end)
  end

  defp filter_out_empty_strings(list) do
    Enum.filter(list, fn(str) -> String.length(str) != 0 end)
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
  # Read file by line

  # Find in each line all the texts that match pattern -> between >TEXT<

  # Get text, downcase_underscore_key, the {file, line}(s) it was found and put in struct (non duplicated)

  # Change the text for t(underscore_text, default: "Underscore Text")

  # Put the key in the yml file (if not already there)
end
