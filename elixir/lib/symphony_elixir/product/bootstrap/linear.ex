defmodule SymphonyElixir.Product.Bootstrap.Linear do
  @moduledoc """
  Linear GraphQL operations for Product Symphony bootstrap.
  """

  alias SymphonyElixir.Product.Bootstrap.Task

  @endpoint "https://api.linear.app/graphql"

  @team_query """
  query ProductSymphonyTeam($key: String!) {
    teams(filter: {key: {eq: $key}}, first: 1) {
      nodes {
        id
        key
        name
      }
    }
  }
  """

  @labels_query """
  query ProductSymphonyLabels {
    issueLabels(first: 250) {
      nodes {
        id
        name
      }
    }
  }
  """

  @label_create_mutation """
  mutation ProductSymphonyCreateLabel($input: IssueLabelCreateInput!) {
    issueLabelCreate(input: $input) {
      success
      issueLabel {
        id
        name
      }
    }
  }
  """

  @project_create_mutation """
  mutation ProductSymphonyCreateProject($input: ProjectCreateInput!) {
    projectCreate(input: $input) {
      success
      project {
        id
        name
        slugId
        url
      }
    }
  }
  """

  @issue_create_mutation """
  mutation ProductSymphonyCreateIssue($input: IssueCreateInput!) {
    issueCreate(input: $input) {
      success
      issue {
        id
        identifier
        title
        url
      }
    }
  }
  """

  @mode_colors %{
    "bootstrap" => "#8E6CEF",
    "explore" => "#0F8B8D",
    "prototype" => "#F59E0B",
    "build" => "#2563EB",
    "park" => "#6B7280",
    "discard" => "#EF4444"
  }

  @spec create_project_with_tasks(map(), keyword()) :: {:ok, map()} | {:error, term()}
  def create_project_with_tasks(brief, opts) when is_map(brief) and is_list(opts) do
    dry_run? = Keyword.get(opts, :dry_run, false)
    team_key = Keyword.fetch!(opts, :team)
    project_name = Keyword.get(opts, :project) || brief.project_name

    if dry_run? do
      {:ok, dry_run_payload(brief, team_key, project_name)}
    else
      with {:ok, team} <- fetch_team(team_key),
           {:ok, labels} <- ensure_mode_labels(),
           {:ok, project} <- create_project(team.id, project_name, brief.overview),
           {:ok, issues} <- create_issues(team.id, project.id, labels, brief.tasks) do
        {:ok,
         %{
           team: team,
           project: project,
           issues: issues
         }}
      end
    end
  end

  defp dry_run_payload(brief, team_key, project_name) do
    %{
      dry_run: true,
      team_key: team_key,
      project: %{
        name: project_name,
        description: brief.overview
      },
      labels: Enum.map(@mode_colors, fn {mode, color} -> %{name: mode_label(mode), color: color} end),
      issues: Enum.map(brief.tasks, &task_payload(&1, "TEAM_ID", "PROJECT_ID", %{}))
    }
  end

  defp fetch_team(team_key) do
    with {:ok, response} <- graphql(@team_query, %{key: team_key}),
         %{"id" => id, "key" => key, "name" => name} <-
           get_in(response, ["data", "teams", "nodes", Access.at(0)]) do
      {:ok, %{id: id, key: key, name: name}}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, {:team_not_found, team_key}}
    end
  end

  defp ensure_mode_labels do
    with {:ok, existing} <- fetch_labels() do
      Enum.reduce_while(@mode_colors, {:ok, existing}, fn {mode, color}, {:ok, labels} ->
        name = mode_label(mode)

        case Map.fetch(labels, String.downcase(name)) do
          {:ok, _id} ->
            {:cont, {:ok, labels}}

          :error ->
            case create_label(name, color) do
              {:ok, id} -> {:cont, {:ok, Map.put(labels, String.downcase(name), id)}}
              {:error, reason} -> {:halt, {:error, reason}}
            end
        end
      end)
    end
  end

  defp fetch_labels do
    with {:ok, response} <- graphql(@labels_query, %{}),
         labels when is_list(labels) <- get_in(response, ["data", "issueLabels", "nodes"]) do
      labels =
        Map.new(labels, fn %{"id" => id, "name" => name} ->
          {String.downcase(name), id}
        end)

      {:ok, labels}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, :label_lookup_failed}
    end
  end

  defp create_label(name, color) do
    input = %{
      name: name,
      color: color,
      description: "Product Symphony #{name} routing label"
    }

    with {:ok, response} <- graphql(@label_create_mutation, %{input: input}),
         true <- get_in(response, ["data", "issueLabelCreate", "success"]) == true,
         id when is_binary(id) <- get_in(response, ["data", "issueLabelCreate", "issueLabel", "id"]) do
      {:ok, id}
    else
      false -> {:error, {:label_create_failed, name}}
      {:error, reason} -> {:error, reason}
      _ -> {:error, {:label_create_failed, name}}
    end
  end

  defp create_project(team_id, project_name, overview) do
    input = %{
      name: project_name,
      teamIds: [team_id],
      description: overview || ""
    }

    with {:ok, response} <- graphql(@project_create_mutation, %{input: input}),
         true <- get_in(response, ["data", "projectCreate", "success"]) == true,
         project when is_map(project) <- get_in(response, ["data", "projectCreate", "project"]) do
      {:ok,
       %{
         id: project["id"],
         name: project["name"],
         slug_id: project["slugId"],
         url: project["url"]
       }}
    else
      false -> {:error, {:project_create_failed, project_name}}
      {:error, reason} -> {:error, reason}
      _ -> {:error, {:project_create_failed, project_name}}
    end
  end

  defp create_issues(team_id, project_id, labels, tasks) do
    Enum.reduce_while(tasks, {:ok, []}, fn task, {:ok, issues} ->
      payload = task_payload(task, team_id, project_id, labels)

      case graphql(@issue_create_mutation, %{input: payload}) do
        {:ok, response} ->
          case get_in(response, ["data", "issueCreate"]) do
            %{"success" => true, "issue" => issue} ->
              {:cont, {:ok, [issue | issues]}}

            _ ->
              {:halt, {:error, {:issue_create_failed, task.title}}}
          end

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, issues} -> {:ok, Enum.reverse(issues)}
      error -> error
    end
  end

  defp task_payload(%Task{} = task, team_id, project_id, labels) do
    label_id = Map.get(labels, String.downcase(mode_label(task.mode)))

    %{
      teamId: team_id,
      projectId: project_id,
      title: task.title,
      description: issue_description(task),
      priority: task.priority || default_priority(task.mode)
    }
    |> maybe_put_label(label_id)
  end

  defp issue_description(%Task{} = task) do
    [
      "## Mode",
      "mode: #{task.mode}",
      "",
      "## Deliverable",
      task.deliverable || "Not specified.",
      "",
      "## Acceptance Criteria",
      task.acceptance || "Not specified.",
      "",
      "## Source Notes",
      strip_control_fields(task.body || "")
    ]
    |> Enum.join("\n")
    |> String.trim()
  end

  defp strip_control_fields(body) do
    body
    |> String.split("\n")
    |> Enum.reject(&String.match?(&1, ~r/^\s*(mode|deliverable|acceptance|priority)\s*:/i))
    |> Enum.join("\n")
    |> String.trim()
  end

  defp maybe_put_label(input, nil), do: input
  defp maybe_put_label(input, label_id), do: Map.put(input, :labelIds, [label_id])

  defp default_priority("build"), do: 3
  defp default_priority("prototype"), do: 3
  defp default_priority("explore"), do: 4
  defp default_priority("bootstrap"), do: 3
  defp default_priority(_), do: 4

  defp mode_label(mode), do: "mode: #{mode}"

  defp graphql(query, variables) do
    api_key = System.get_env("LINEAR_API_KEY")

    if is_nil(api_key) or api_key == "" do
      {:error, :missing_linear_api_key}
    else
      Req.post(@endpoint,
        headers: [
          {"authorization", api_key},
          {"content-type", "application/json"}
        ],
        json: %{
          query: query,
          variables: variables
        }
      )
      |> case do
        {:ok, %{status: 200, body: %{"errors" => errors}}} -> {:error, {:linear_graphql_errors, errors}}
        {:ok, %{status: 200, body: body}} -> {:ok, body}
        {:ok, %{status: status, body: body}} -> {:error, {:linear_http_error, status, body}}
        {:error, reason} -> {:error, reason}
      end
    end
  end
end

