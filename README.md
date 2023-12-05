# Regexp

Regex |> Regexp.for_dummies()

## Use

```elixir
Regexp.new()
|> Regexp.literal("abc")
|> Regexp.any_of(["x", "y"])
|> Regexp.anything()
|> Regexp.compile!()

~r/abc[xy]./

```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `regexp` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:regexp, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/regexp>.

