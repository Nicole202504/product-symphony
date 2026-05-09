defmodule SymphonyElixir.Product.Bootstrap.Brief do
  @moduledoc """
  Parses a markdown product bootstrap brief into Linear-ready tasks.

  Expected format:

      # Project Name

      Project context and goals.

      ### Explore: First user journey
      mode: explore
      deliverable: option memo
      acceptance: recommendation posted to Linear

      ### Build: Save checklist state
      mode: build
      deliverable: production implementation
      acceptance: tests pass

  The heading prefix can infer mode: Bootstrap, Explore, Prototype, Build, Park, or Discard.
  A `mode:` line inside the task body overrides heading inference.
  """

  alias SymphonyElixir.Product.Bootstrap.Task

  @modes ~w(bootstrap explore prototype build park discard)

  @spec parse(String.t()) :: {:ok, map()} | {:error, term()}
  def parse(markdown) when is_binary(markdown) do
    with {:ok, project_name} <- parse_project_name(markdown),
         {:ok, tasks} <- parse_tasks(markdown) do
      {:ok,
       %{
         project_name: project_name,
         overview: parse_overview(markdown),
         tasks: tasks
       }}
    end
  end

  defp parse_project_name(markdown) do
    case Regex.run(~r/^#\s+(.+?)\s*$/m, markdown) do
      [_, name] -> {:ok, String.trim(name)}
      _ -> {:error, :missing_project_heading}
    end
  end

  defp parse_overview(markdown) do
    markdown
    |> String.split(~r/^###\s+/m, parts: 2)
    |> List.first()
    |> String.replace(~r/^#\s+.+?\s*$/m, "")
    |> String.trim()
  end

  defp parse_tasks(markdown) do
    task_blocks =
      Regex.split(~r/^###\s+/m, markdown)
      |> Enum.drop(1)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    tasks =
      task_blocks
      |> Enum.map(&parse_task_block/1)
      |> collect_results()

    case tasks do
      {:ok, []} -> {:error, :missing_tasks}
      other -> other
    end
  end

  defp parse_task_block(block) do
    [heading | body_lines] = String.split(block, "\n")
    body = body_lines |> Enum.join("\n") |> String.trim()

    with {:ok, inferred_mode, title} <- parse_heading(heading),
         {:ok, mode} <- parse_mode(body, inferred_mode) do
      {:ok,
       %Task{
         title: title,
         mode: mode,
         deliverable: parse_field(body, "deliverable"),
         acceptance: parse_field(body, "acceptance"),
         priority: parse_priority(body),
         body: body
       }}
    end
  end

  defp parse_heading(raw_heading) do
    heading = String.trim(raw_heading)

    case Regex.run(~r/^(Bootstrap|Explore|Prototype|Build|Park|Discard)\s*:\s*(.+)$/i, heading) do
      [_, mode, title] ->
        {:ok, normalize_mode(mode), String.trim(title)}

      _ ->
        {:ok, nil, heading}
    end
  end

  defp parse_mode(body, inferred_mode) do
    mode =
      case parse_field(body, "mode") do
        nil -> inferred_mode
        value -> normalize_mode(value)
      end

    cond do
      mode in @modes -> {:ok, mode}
      is_nil(mode) -> {:error, :missing_mode}
      true -> {:error, {:invalid_mode, mode}}
    end
  end

  defp parse_field(body, field) do
    pattern = ~r/^#{Regex.escape(field)}\s*:\s*(.+?)\s*$/im

    case Regex.run(pattern, body) do
      [_, value] -> String.trim(value)
      _ -> nil
    end
  end

  defp parse_priority(body) do
    case parse_field(body, "priority") do
      nil ->
        nil

      value ->
        case Integer.parse(value) do
          {priority, _} when priority in 0..4 -> priority
          _ -> nil
        end
    end
  end

  defp normalize_mode(mode) when is_binary(mode) do
    mode
    |> String.downcase()
    |> String.trim()
    |> String.replace_prefix("mode:", "")
    |> String.trim()
  end

  defp normalize_mode(nil), do: nil

  defp collect_results(results) do
    Enum.reduce_while(results, {:ok, []}, fn
      {:ok, task}, {:ok, tasks} -> {:cont, {:ok, [task | tasks]}}
      {:error, reason}, _ -> {:halt, {:error, reason}}
    end)
    |> case do
      {:ok, tasks} -> {:ok, Enum.reverse(tasks)}
      error -> error
    end
  end
end

