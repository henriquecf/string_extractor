defmodule SearchMap do
  @base_path "/Users/henrique/code/can2/app"
  @wildcard_views "views/**/*.html.erb"

  def process_views() do
    Path.join([@base_path, @wildcard_views])
    |> Path.wildcard
    |> Stream.map(&HtmlContent.map_text_from_html_file/1)
    |> Stream.map(&IO.inspect/1)
    |> Stream.run
  end
end
