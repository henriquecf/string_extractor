defmodule ErbContent do
  @patterns_to_remove [
    ~r{render\s+["'][#\w\s.]+["']},
    ~r{:class\s+=>\s+["'][#\w\s-]+["']},
    ~r{:id\s+=>\s+["'][#\w\s-]+["']},
    ~r{:controller\s+=>\s+["'][#\w\s-]+["']},
    ~r{:action\s+=>\s+["'][#\w\s-]+["']},
    ~r{:novalidate\s+=>\s+["'][#\w\s-]+["']},
    ~r{:equalTo\s+=>\s+["'][#\w\s-]+["']},
    ~r{:target\s+=>\s+["'][#\w\s-]+["']},
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
    ~r{"[#]"},
    ~r{class="<%.*%>"},
    ~r{"none"}
  ]
  def map_text_from_erb(file_path) do
    file_path
    |> File.stream!
    |> Stream.map(&(Regex.scan(~r{.*\n}, &1)))
    |> remove_empty_arrays
    |> Stream.map(&Enum.at(&1, 0))
    |> Stream.map(&Enum.at(&1, 0))
    |> Stream.map(&remove_undesired_patterns/1)
    |> Stream.map(&(Regex.scan(~r{<%(.*?)%>}, &1)))
    |> remove_empty_arrays
    |> Stream.map(&Enum.at(&1, 0))
    |> Stream.map(&Enum.at(&1, 0))
    |> Stream.map(&remove_undesired_patterns/1)
    |> Stream.filter(fn(line) -> Regex.match?(~r{.*["'].*}, line) end)
    |> Stream.map(&(Regex.scan(~r{"(?<text>.*?)"}, &1)))
    |> remove_empty_arrays
    |> Stream.map(&Enum.at(&1, 0))
    |> Stream.map(&Enum.at(&1, 1))
    |> Enum.map(&Translatable.from_original/1)
    |> TranslatableList.from_list(file_path)
  end

  defp remove_undesired_patterns(string) do
    Enum.reduce(@patterns_to_remove, string, &(Regex.replace(&1, &2, "")))
  end

  defp remove_empty_arrays(stream) do
    Stream.filter(stream, &(length(&1) != 0))
  end
end
