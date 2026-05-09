#!/usr/bin/env node

const LINEAR_ENDPOINT = "https://api.linear.app/graphql";

const MODE_LABELS = {
  bug: { name: "tool-bug", color: "#EF4444" },
  feature: { name: "tool-feature", color: "#2563EB" },
  question: { name: "tool-question", color: "#8E6CEF" },
};

function parseArgs(argv) {
  const args = {
    type: "bug",
    priority: undefined,
    dryRun: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];

    if (arg === "--dry-run") {
      args.dryRun = true;
    } else if (arg.startsWith("--")) {
      const key = arg.slice(2).replace(/-([a-z])/g, (_, letter) => letter.toUpperCase());
      const value = argv[i + 1];

      if (!value || value.startsWith("--")) {
        throw new Error(`Missing value for ${arg}`);
      }

      args[key] = value;
      i += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  return args;
}

function usage() {
  return `Usage:
  scripts/report-product-symphony-issue.sh \\
    --type bug|feature|question \\
    --title "Short title" \\
    --source-project "Business project name" \\
    --details details.md

Environment:
  LINEAR_API_KEY                         required unless --dry-run
  PRODUCT_SYMPHONY_FEEDBACK_TEAM_KEY     required, e.g. ENG
  PRODUCT_SYMPHONY_FEEDBACK_PROJECT_SLUG optional Linear project slug

Optional:
  --command "command that failed"
  --expected "expected behavior"
  --actual "actual behavior"
  --commit "product-symphony commit"
  --priority 1|2|3|4
  --dry-run`;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  validateArgs(args);

  const body = await buildIssueBody(args);
  const payload = {
    title: `[Product Symphony] ${args.title}`,
    type: args.type,
    sourceProject: args.sourceProject,
    priority: parsePriority(args.priority),
    body,
  };

  if (args.dryRun) {
    console.log(JSON.stringify(payload, null, 2));
    return;
  }

  const apiKey = requireEnv("LINEAR_API_KEY");
  const teamKey = requireEnv("PRODUCT_SYMPHONY_FEEDBACK_TEAM_KEY");
  const projectSlug = process.env.PRODUCT_SYMPHONY_FEEDBACK_PROJECT_SLUG;

  const team = await fetchTeam(apiKey, teamKey);
  const project = projectSlug ? await fetchProject(apiKey, projectSlug) : null;
  const label = await ensureLabel(apiKey, MODE_LABELS[args.type]);
  const issue = await createIssue(apiKey, {
    teamId: team.id,
    projectId: project?.id,
    labelIds: [label.id],
    title: payload.title,
    description: body,
    priority: payload.priority,
  });

  console.log(`Created Linear issue ${issue.identifier}: ${issue.url}`);
}

function validateArgs(args) {
  if (!["bug", "feature", "question"].includes(args.type)) {
    throw new Error("--type must be bug, feature, or question");
  }

  if (!args.title) {
    throw new Error("--title is required");
  }

  if (!args.sourceProject) {
    throw new Error("--source-project is required");
  }

  if (!args.details && !args.actual && !args.expected) {
    throw new Error("Provide --details, --actual, or --expected");
  }
}

async function buildIssueBody(args) {
  const details = args.details ? await readText(args.details) : "";

  return [
    "## Source",
    "",
    `Business project: ${args.sourceProject}`,
    `Product Symphony commit: ${args.commit || "unknown"}`,
    "",
    "## Type",
    "",
    args.type,
    "",
    "## Command / Situation",
    "",
    args.command || "Not provided.",
    "",
    "## Expected",
    "",
    args.expected || "Not provided.",
    "",
    "## Actual",
    "",
    args.actual || "Not provided.",
    "",
    "## Details",
    "",
    details || "Not provided.",
    "",
    "## Requested Follow-up",
    "",
    "Please triage and fix in the Product Symphony repository, then release/push the update for downstream projects.",
  ].join("\n");
}

async function readText(path) {
  const fs = await import("node:fs/promises");
  return fs.readFile(path, "utf8");
}

function parsePriority(priority) {
  if (priority === undefined) return 3;
  const parsed = Number.parseInt(priority, 10);
  if (![1, 2, 3, 4].includes(parsed)) {
    throw new Error("--priority must be 1, 2, 3, or 4");
  }
  return parsed;
}

async function fetchTeam(apiKey, key) {
  const query = `
    query FeedbackTeam($key: String!) {
      teams(filter: {key: {eq: $key}}, first: 1) {
        nodes { id key name }
      }
    }
  `;

  const response = await graphql(apiKey, query, { key });
  const team = response.data?.teams?.nodes?.[0];
  if (!team) throw new Error(`Linear team not found: ${key}`);
  return team;
}

async function fetchProject(apiKey, slug) {
  const query = `
    query FeedbackProject($slug: String!) {
      projects(filter: {slugId: {eq: $slug}}, first: 1) {
        nodes { id name slugId url }
      }
    }
  `;

  const response = await graphql(apiKey, query, { slug });
  const project = response.data?.projects?.nodes?.[0];
  if (!project) throw new Error(`Linear project not found: ${slug}`);
  return project;
}

async function ensureLabel(apiKey, labelSpec) {
  const existing = await fetchLabels(apiKey);
  const current = existing.find((label) => label.name.toLowerCase() === labelSpec.name.toLowerCase());
  if (current) return current;

  const mutation = `
    mutation CreateFeedbackLabel($input: IssueLabelCreateInput!) {
      issueLabelCreate(input: $input) {
        success
        issueLabel { id name }
      }
    }
  `;

  const response = await graphql(apiKey, mutation, {
    input: {
      name: labelSpec.name,
      color: labelSpec.color,
      description: "Product Symphony feedback routing label",
    },
  });

  const result = response.data?.issueLabelCreate;
  if (!result?.success) throw new Error(`Failed to create label ${labelSpec.name}`);
  return result.issueLabel;
}

async function fetchLabels(apiKey) {
  const query = `
    query FeedbackLabels {
      issueLabels(first: 250) {
        nodes { id name }
      }
    }
  `;

  const response = await graphql(apiKey, query, {});
  return response.data?.issueLabels?.nodes || [];
}

async function createIssue(apiKey, input) {
  const mutation = `
    mutation CreateFeedbackIssue($input: IssueCreateInput!) {
      issueCreate(input: $input) {
        success
        issue { id identifier title url }
      }
    }
  `;

  const response = await graphql(apiKey, mutation, { input: removeNil(input) });
  const result = response.data?.issueCreate;
  if (!result?.success) throw new Error("Linear issue creation failed");
  return result.issue;
}

async function graphql(apiKey, query, variables) {
  const response = await fetch(LINEAR_ENDPOINT, {
    method: "POST",
    headers: {
      authorization: apiKey,
      "content-type": "application/json",
    },
    body: JSON.stringify({ query, variables }),
  });

  const body = await response.json();
  if (!response.ok) {
    throw new Error(`Linear HTTP ${response.status}: ${JSON.stringify(body)}`);
  }

  if (body.errors) {
    throw new Error(`Linear GraphQL error: ${JSON.stringify(body.errors)}`);
  }

  return body;
}

function requireEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is required`);
  return value;
}

function removeNil(object) {
  return Object.fromEntries(Object.entries(object).filter(([, value]) => value !== undefined && value !== null));
}

main().catch((error) => {
  console.error(error.message);
  console.error("");
  console.error(usage());
  process.exit(1);
});

