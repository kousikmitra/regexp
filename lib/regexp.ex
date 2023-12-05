defmodule Regexp do
  defmodule LiteralExpr do
    @type t :: %__MODULE__{literal: String.t()}

    defstruct literal: ""

    @spec to_regex(t) :: String.t()
    def to_regex(expr), do: Regex.escape(expr.literal)
  end

  defmodule WildcardExpr do
    @type t :: %__MODULE__{expr: String.t()}

    defstruct expr: ""

    @spec to_regex(t) :: String.t()
    def to_regex(%_{expr: expr}), do: expr
  end

  defmodule CharactersExpr do
    @type t :: %__MODULE__{chars: list(String.t()), negated: boolean()}

    defstruct chars: [], negated: false

    @spec to_regex(t) :: String.t()
    def to_regex(%__MODULE__{negated: false} = expr), do: "[#{Enum.join(expr.chars)}]"
    def to_regex(expr), do: "[^#{Enum.join(expr.chars)}]"
  end

  defmodule GroupExpr do
    @type expr :: CharactersExpr.t() | LiteralExpr.t() | t()
    @type t :: %__MODULE__{expr: list(expr)}

    defstruct expr: []

    @spec to_regex(t) :: String.t()
    def to_regex(%__MODULE__{expr: expr}) do
      expr =
        expr
        |> Enum.reverse()
        |> Enum.map(fn
          %module{} = expr -> module.to_regex(expr)
          str when is_binary(str) -> str
        end)
        |> Enum.join()

      "(#{expr})"
    end
  end

  @type expression :: LiteralExpr.t() | CharactersExpr.t() | GroupExpr.t()
  @type t :: %__MODULE__{
          expr: list(expression)
        }

  defstruct expr: []

  @doc """
  Creates a new Regexp Builder.

  ## Examples

      iex> new()
      %Regexp{expr: []}

      iex> new() |> compile!()
      ~r//

  """
  @spec new() :: t
  def new(), do: %__MODULE__{}

  @doc """
  Add a new literal in the regex pattern

  ## Examples

      iex> new() |> literal("abc") |> compile!()
      ~r/abc/

  """
  @spec literal(t, String.t()) :: t
  def literal(regexp, str),
    do: %{regexp | expr: [%LiteralExpr{literal: str} | regexp.expr]}

  @doc """
  Add a new Characters Expression in the regex pattern using given list of characters.

  ## Examples

      iex> new() |> any_of(["a", "x"]) |> compile!()
      ~r/[ax]/

  """
  @spec any_of(t, list(String.t())) :: t
  def any_of(regexp, chars),
    do: %{regexp | expr: [%CharactersExpr{chars: chars} | regexp.expr]}

  @doc """
  Add a new Characters Expression in the regex pattern with negation using given list of characters.

  ## Examples

      iex> new() |> none_of(["a", "x"]) |> compile!()
      ~r/[^ax]/

  """
  @spec none_of(t, list(String.t())) :: t
  def none_of(regexp, chars),
    do: %{regexp | expr: [%CharactersExpr{chars: chars, negated: true} | regexp.expr]}

  @doc """
  Wildcard to match any character.

  ## Examples

      iex> new() |> anything() |> compile!()
      ~r/./

  """
  @spec anything(t) :: t
  def anything(regexp),
    do: %{regexp | expr: [%WildcardExpr{expr: "."} | regexp.expr]}

  @doc """
  Wildcard to match any character.

  ## Examples

      iex> new() |> anydigit() |> compile!()
      ~r/\d/

  """
  @spec anydigit(t) :: t
  def anydigit(regexp),
    do: %{regexp | expr: [%WildcardExpr{expr: "\d"} | regexp.expr]}

  @doc """
  Wildcard to match any alphanumeric + underscore.

  ## Examples

      iex> new() |> anywordchar() |> compile!()
      ~r/\w/

  """
  @spec anywordchar(t) :: t
  def anywordchar(regexp),
    do: %{regexp | expr: [%WildcardExpr{expr: "\w"} | regexp.expr]}

  @doc """
  Create a new group with the complete pipeline.

  ## Examples

      iex> new() |>  literal("abc") |> any_of(["a", "x"]) |> group() |> compile!()
      ~r/(abc[ax])/

  """
  @spec group(t) :: t
  def group(regexp), do: %{regexp | expr: [%GroupExpr{expr: regexp.expr}]}

  @spec to_regex(t) :: String.t()
  def to_regex(regexp) do
    regexp.expr
    |> Enum.reverse()
    |> Enum.map(fn
      %module{} = expr -> module.to_regex(expr)
      str when is_binary(str) -> str
    end)
    |> Enum.join()
  end

  @spec compile!(t | term()) :: Regex.t()
  def compile!(%__MODULE__{} = regexp) do
    to_regex(regexp)
    |> Regex.compile!()
  end

  def compile!(anything), do: Regex.compile!(anything)
end
