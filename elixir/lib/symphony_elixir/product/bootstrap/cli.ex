defmodule SymphonyElixir.Product.Bootstrap.CLI do
  @moduledoc """
  CLI entrypoint for creating a Product Symphony Linear project from a markdown brief.
  """

  alias SymphonyElixir.Product.Bootstrap.{Brief, Linear}

  @switches [
    team: :string,
    project: :string,
    brief: :string,
    dry_run: :boolean
  ]

  @spec run([String.t()]) :: :ok | {:error, String.t()}
  def run(args) do
    with {:ok, opts} <- parse_args(args),
         {:ok, _apps} <- Application.ensure_all_started(:req),
         {:ok, markdown} <- read_brief(opts[:brief]),
         {:ok, brief} <- Brief.parse(markdown),
         {:ok, result} <-
           Linear.create_project_with_tasks(brief,
             team: opts[:team],
             project: opts[:project],
             dry_run: Keyword.get(opts, :dry_run, false)
           ) do
      IO.puts(format_result(result))
      :ok
    else
      {:error, message} when is_binary(message) -> {:error, message}
      {:error, reason} -> {:error, "Product bootstrap failed: #{inspect(reason)}"}
    end
  end

  defp parse_args(args) do
    case OptionParser.parse(args, strict: @switches) do
      {opts, [], []} ->
        cond do
          blank?(opts[:team]) -> {:error, usage_message()}
          blank?(opts[:brief]) -> {:error, usage_message()}
          true -> {:ok, opts}
        end

      _ ->
        {:error, usage_message()}
    end
  end

  defp read_brief(path) do
    expanded = Path.expand(path)

    case File.read(expanded) do
      {:ok, markdown} -> {:ok, markdown}
      {:error, reason} -> {:error, "Could not read brief #{expanded}: #{inspect(reason)}"}
    end
  end

  defp format_result(%{dry_run: true} = result) do
    Jason.encode!(result, pretty: true)
  end

  defp format_result(%{project: project, issues: issues}) do
    issue_lines =
      Enum.map(issues, fn issue ->
        "- #{issue["identifier"]}: #{issue["title"]} #{issue["url"]}"
      end)

    [
      "Product Symphony bootstrap complete.",
      "",
      "Project: #{project.name}",
      "URL: #{project.url}",
      "",
      "Issues:",
      issue_lines
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp blank?(value), do: is_nil(value) or String.trim(to_string(value)) == ""

  defp usage_message do
    """
    Usage:
      symphony product.bootstrap --team <TEAM_KEY> --brief <brief.md> [--project <NAME>] [--dry-run]

    Environment:
      LINEAR_API_KEY must be set unless --dry-run is used.
    """
    |> String.trim()
  end
end

