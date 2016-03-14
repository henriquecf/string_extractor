defmodule TranslatableList do
  @type translatables_list :: [Translatable.t]

  defstruct [:translatables, :file_path, :yml_path]

  @type t :: %TranslatableList{translatables: translatables_list, file_path: String.t, yml_path: String.t}
end
