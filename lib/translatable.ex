defmodule Translatable do
  defstruct [:original, :text, :key, :prefix, :suffix]
  @type t :: %Translatable{original: String.t, text: String.t, key: String.t,
                           prefix: String.t, suffix: String.t}

  @prefix_pattern ~r{^(?<prefix>\s*)}
  @suffix_pattern ~r{(?<suffix>:?\s*\*?\,?\s*)$}

  @doc ~S"""
  Extracts the text, prefix, suffix and key from original text

  ## Examples

      iex> Translatable.from_original(" simple text: ")
      %Translatable{original: " simple text: ", text: "simple text", key: "simple_text", prefix: " ", suffix: ": "}

      iex> Translatable.from_original("simple text: ")
      %Translatable{original: "simple text: ", text: "simple text", key: "simple_text", prefix: "", suffix: ": "}

      iex> Translatable.from_original(" simple text")
      %Translatable{original: " simple text", text: "simple text", key: "simple_text", prefix: " ", suffix: ""}

      iex> Translatable.from_original("simple text")
      %Translatable{original: "simple text", text: "simple text", key: "simple_text", prefix: "", suffix: ""}

      iex> Translatable.from_original("simple text *")
      %Translatable{original: "simple text *", text: "simple text", key: "simple_text", prefix: "", suffix: " *"}

      iex> Translatable.from_original("simple text, ")
      %Translatable{original: "simple text, ", text: "simple text", key: "simple_text", prefix: "", suffix: ", "}

  """
  def from_original(original_text) do
    text = extract_text(original_text)
    key = key_from_text(text)
    %Translatable{original: original_text, text: text, prefix: extract_prefix(original_text), suffix: extract_suffix(original_text), key: key}
  end

  defp key_from_text(text) do
    text
    |> String.downcase
    |> String.split(" ")
    |> Enum.join("_")
  end

  defp extract_prefix(original_text) do
    Regex.named_captures(@prefix_pattern, original_text)
    |> Map.get("prefix")
  end

  defp extract_suffix(original_text) do
    Regex.named_captures(@suffix_pattern, original_text)
    |> Map.get("suffix")
  end

  defp extract_text(original_text) do
    text_without_prefix = Regex.replace(@prefix_pattern, original_text, "")
    Regex.replace(@suffix_pattern, text_without_prefix, "")
  end
end
