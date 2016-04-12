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
    ~r{".*[\w]=.*"}
  ]
  def map_erb() do
    "/Users/ivan/code/can2/app/views/petitions/thankyou.html.erb"
    |> File.stream!
    |> Stream.map(&(Regex.scan(~r{<%(.*?)%>}, &1)))
    |> remove_empty_arrays
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.map(&remove_undesired_patterns/1)
    |> Enum.filter(fn(line) -> Regex.match?(~r{.*["'].*}, line) end)
    |> Stream.map(&(Regex.scan(~r{"(?<text>.*)"}, &1)))
    |> remove_empty_arrays
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.map(&Enum.at(&1, 1))
  end

  defp remove_undesired_patterns(string) do
    Enum.reduce(@patterns_to_remove, string, &(Regex.replace(&1, &2, "")))
  end

  defp remove_empty_arrays(stream) do
    Stream.filter(stream, &(length(&1) != 0))
  end
end
