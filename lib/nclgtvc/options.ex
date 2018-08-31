defmodule NcLGTVc.Options do
  @switches [
    host: :string
  ]

  @aliases [
    h: :host
  ]

  @enforce_keys [:host]
  defstruct(host: nil)

  def parse(args) do
    {opts, other, invalid} = OptionParser.parse(args, strict: @switches, aliases: @aliases)

    errors =
      []
      |> check_other_args(other)
      |> check_invalid_opts(invalid)
      |> check_enforced_keys(opts)

    if Enum.empty?(errors) do
      {:ok, struct!(__MODULE__, opts)}
    else
      {:error, errors}
    end
  end

  defp check_other_args(errs, []), do: errs

  defp check_other_args(errs, other),
    do: ["Unknown extra arguments: #{inspect(other)}" | errs]

  defp check_invalid_opts(errs, []), do: errs

  defp check_invalid_opts(errs, invalid) do
    names = Enum.map(invalid, fn {n, _} -> n end)
    ["Unknown options: #{inspect(names)}" | errs]
  end

  defp check_enforced_keys(errs, opts) do
    missing =
      @enforce_keys
      |> Enum.filter(&(!Keyword.has_key?(opts, &1)))
      |> Enum.map(&"--#{&1}")

    if Enum.empty?(missing) do
      errs
    else
      ["Missing required options: #{Enum.join(missing, ", ")}" | errs]
    end
  end
end
