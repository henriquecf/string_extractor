defmodule Translatable do
  defstruct [:original, :text, :key, :prefix, :suffix]
  @type t :: %Translatable{original: String.t, text: String.t, key: String.t,
                           prefix: String.t, suffix: String.t}
end
