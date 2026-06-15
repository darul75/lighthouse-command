import { readFile, writeFile } from "fs/promises";

const INPUT = process.argv[2] || "lighthouse-results.json";
const OUTPUT = process.argv[3] || "lighthouse-summary.json";

const raw = await readFile(INPUT, "utf-8");
const lhr = JSON.parse(raw);

const categories = Object.fromEntries(
  Object.entries(lhr.categories).map(([key, cat]: [string, any]) => [
    key,
    { title: cat.title, score: Math.round((cat.score ?? 0) * 100) },
  ])
);

type Issue = {
  id: string;
  title: string;
  description: string;
  impact: string;
  score: number | null;
  selector?: string;
  snippets?: string[];
};

const issues: Issue[] = [];

for (const [id, audit] of Object.entries(lhr.audits) as [string, any][]) {
  if (audit.scoreDisplayMode === "notApplicable" || audit.scoreDisplayMode === "informative") continue;
  if (audit.score === 1 || audit.score === null) continue;

  let selector: string | undefined;
  const snippets: string[] = [];

  const items = audit.details?.items;
  if (items && Array.isArray(items)) {
    const first = items[0];
    if (first?.node) {
      selector = first.node.selector || first.node.path || first.node.xpath;
    }
    if (first?.snippet) {
      snippets.push(first.snippet);
    }
    for (const item of items.slice(0, 3)) {
      if (item.node && item.node.selector && item.node.selector !== selector) {
        selector = item.node.selector;
      }
      if (item.snippet && !snippets.includes(item.snippet)) {
        snippets.push(item.snippet);
      }
    }
  }

  issues.push({
    id,
    title: audit.title,
    description: audit.description?.split(".")[0] ?? "",
    impact:
      audit.scoreDisplayMode === "error"
        ? "error"
        : audit.score === 0
          ? "fail"
          : "needs-improvement",
    score: audit.score !== null ? Math.round(audit.score * 100) : null,
    selector,
    snippets: snippets.length > 0 ? snippets.slice(0, 2) : undefined,
  });
}

issues.sort((a, b) => {
  const order: Record<string, number> = { error: 0, fail: 1, "needs-improvement": 2 };
  return (order[a.impact] ?? 3) - (order[b.impact] ?? 3);
});

const summary = {
  url: lhr.finalDisplayedUrl ?? lhr.requestedUrl,
  categories,
  totalIssues: issues.length,
  issues,
};

await writeFile(OUTPUT, JSON.stringify(summary, null, 2), "utf-8");
console.log(JSON.stringify(summary, null, 2));
