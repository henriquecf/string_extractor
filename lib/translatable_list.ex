defmodule TranslatableList do
  @derive [Poison.Encoder]
  defstruct [:translatables, :file_path, :yml_file_str, :yml_path, :path]

  @type translatables_list :: [Translatable.t]
  @type t :: %TranslatableList{translatables: translatables_list, path: String.t,
    file_path: String.t, yml_file_str: String.t, yml_path: String.t}

  @base_path "/Users/henrique/code/can2/app"
  @yml_path @base_path <> "/locales"
  @path "/Users/henrique/code/html_content/translatables/can"

  def from_list(list, file_path) do
    yml_file_str(%TranslatableList{translatables: list, file_path: file_path})
  end

  def file_map(translatable_list) do
    values = Enum.map(translatable_list.translatables, fn (translatable) -> translatable.text end)
    Enum.map(translatable_list.translatables, fn (translatable) -> translatable.key end)
    |> Enum.zip(values)
    |> Enum.into(%{})
  end

  defp yml_file_str(translatable_list, lang \\ "pt_BR") do
    path_list =
      translatable_list.file_path
      |> Path.relative_to(@base_path)
      |> Path.rootname(".html.erb")
      |> Path.split
    path = Path.join(@path, Path.join(path_list)) <> ".json"
    new_translatable_list = case File.read(path) do
      {:ok, json_str} ->
        old_translatable_list = Poison.decode!(json_str,  as: %TranslatableList{translatables: [%Translatable{}]}, keys: :atoms!)
        IO.inspect(old_translatable_list)
        %TranslatableList{translatable_list | translatables: old_translatable_list.translatables ++ translatable_list.translatables}
      {:error, _reason} ->
        translatable_list
    end
    str = create_yml_str(new_translatable_list.translatables, path_list, lang)
    yml_path = Path.join(@yml_path, Path.join(path_list)) <> ".yml"
    %TranslatableList{new_translatable_list | yml_file_str: str, yml_path: yml_path, path: path}
  end

  defp create_yml_str(translatables, path_list, lang) do
    {initial_str_list, final_index} = base_yml_str(path_list)
    values = Enum.map(translatables, fn (translatable) ->
      String.duplicate(" ", final_index) <> "#{translatable.key}: \"#{translatable.text}\""
    end)
    Enum.join(["#{lang}:"] ++ initial_str_list ++ values, "\n")
  end

  defp base_yml_str(list) do
    Enum.map_reduce(list, 1, fn (item, acc) ->
      {String.duplicate(" ", acc) <> "#{item}:", acc + 1}
    end)
  end
end
