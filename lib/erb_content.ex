defmodule ErbContent do
  @patterns_to_remove [
    ~r{render\s+["'][#\w\s.]+["']},
    ~r{:(class|id|controller|action|novalidate|equalTo|target)\s*=>\s*["'][#\w\s-]*(#\{.*\})*[#\w\s-]*["']},
    ~r{(class|id|controller|action|novalidate|equalTo|target):\s*["'][#\w\s-]*(#\{.*\})*[#\w\s-]*["']},
    ~r{render\s+["'].*["']},
    ~r{template:\s+["'][\w\s\/]+["']},
    ~r{layout:\s+["'][\w\s\/]+["']},
    ~r{["']\/[\w\/#.@\{\}]+["']},
    ~r{["'][\w\/#.@\{\}]+["']\/},
    ~r{["']\/[\w\/#.@\{\}]+["']\/},
    ~r{["'][\w\/#.@\{\}]+\/[\w\/#.@\{\}]+["']},
    ~r{["']([#\w]+[_]+[#\w]+)+[#\s\w]*["']},
    ~r{\+\s*["'][,\s]+["']\s*\+},
    ~r{["']US["']},
    ~r{".*[\w]=.*"},
    ~r{"[#?@]*"},
    ~r{class="<%.*%>"},
    ~r{"none"},
    ~r{"\d+"}
  ]
  def map_text_from_erb(file_path) do
    file_path
    |> File.stream!
    |> Stream.map(&remove_undesired_patterns/1)
    |> Stream.map(&(Regex.scan(~r{<%(.*?)%>}, &1)))
    |> remove_empty_arrays
    |> Stream.map(&get_position(&1, 0))
    |> Enum.to_list
    |> List.flatten
    |> Stream.map(&remove_undesired_patterns/1)
    |> Stream.filter(fn(line) -> Regex.match?(~r{.*["'].*}, line) end)
    |> Stream.map(&(Regex.scan(~r{"(?<text>.*?)"}, &1)))
    |> remove_empty_arrays
    |> Stream.map(&get_position(&1, 1))
    |> Enum.to_list
    |> List.flatten
    |> Enum.map(&Translatable.from_original/1)
    |> TranslatableList.from_list(file_path)
    |> replace_keys_in_a_file
  end

  def replace_keys_in_a_file(translatable_list) do
    translatable_list.file_path
    |> File.stream!
    |> Enum.map(&(replace_keys_in_a_line(&1, translatable_list)))
    |> write_file(translatable_list.file_path)
  end

  def replace_keys_in_a_line(line, translatable_list) do
    translatable_list.translatables
    |> Enum.reduce(line, &(Regex.replace(~r{(<%.*)(["']#{&1.text}["'])(.*%>)}, &2, "\\1t(\".#{&1.key}\")\\3")))
  end

  def write_file(lines, file) do
    {:ok, file} = File.open(file, [:write], fn(f) ->
      lines
      |> Enum.map(&(IO.write(f, &1)))
    end)
  end

  defp get_position(list, indice) do
    Enum.map(list, &Enum.at(&1, indice))
  end

  defp remove_undesired_patterns(string) do
    Enum.reduce(@patterns_to_remove, string, &(Regex.replace(&1, &2, "")))
  end

  defp remove_empty_arrays(stream) do
    Stream.filter(stream, &(length(&1) != 0))
  end
end
