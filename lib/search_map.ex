defmodule SearchMap do
  @base_path "/Users/henrique/code/can2/app"
  @wildcard_views "views/**/*.html.erb"

  """
  Snippet to find error when parsing files:
  Path.wildcard(p) |> Enum.map( fn (f) -> IO.puts(f); YamlElixir.read_from_file(f) end)
  """
  def process_views() do
    Path.join([@base_path, @wildcard_views])
    |> Path.wildcard
    |> Stream.map(&HtmlContent.map_text_from_html_file/1)
    |> Stream.map(&write_to_file/1)
    |> Stream.run
  end

  defp write_to_file(%TranslatableList{translatables: list} = translatables_list) when length(list) > 0 do
    File.mkdir_p(Path.dirname(translatables_list.path))
    File.write!(translatables_list.path, Poison.encode!(translatables_list))
    translatables_list
  end

  defp write_to_file(translatables_list) do
    translatables_list
  end
end
