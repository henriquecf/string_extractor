defmodule TranslatableList do
  @type translatables_list :: [Translatable.t]

  defstruct [:translatables, :file_path, :yml_root]

  @type t :: %TranslatableList{translatables: translatables_list, file_path: String.t, yml_root: String.t}

  def from_list(list, file_path, yml_root \\ "/Users/henrique/code/can2/config/locales") do
    %TranslatableList{translatables: list, file_path: file_path, yml_root: yml_root}
  end

  def file_map(translatable_list) do
    values = Enum.map(translatable_list.translatables, fn (translatable) -> translatable.text end)
    Enum.map(translatable_list.translatables, fn (translatable) -> translatable.key end)
    |> Enum.zip(values)
    |> Enum.into(%{})
  end
end
