import { writeFile } from "fs/promises";
import { launch } from "chrome-launcher";
import lighthouse from "lighthouse";

const BASE_URL = process.env.LH_BASE_URL || "http://localhost:3000";
const PATH = (process.argv[2] || "/").replace(/^\/*/, "/");
const TIMEOUT = parseInt(process.env.LH_TIMEOUT || "30000", 10);
const OUTPUT = process.argv[3] || "lighthouse-results.json";

const url = `${BASE_URL.replace(/\/+$/, "")}${PATH}`;

async function waitForUrl(target: string, timeout: number): Promise<void> {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    try {
      const res = await fetch(target);
      if (res.ok || res.status === 404) return;
    } catch {}
    await new Promise((r) => setTimeout(r, 1000));
  }
  throw new Error(`URL not ready within ${timeout}ms: ${target}`);
}

await waitForUrl(url, TIMEOUT);

const chrome = await launch({ chromeFlags: ["--headless=new"] });
let result: Awaited<ReturnType<typeof lighthouse>>;

try {
  result = await lighthouse(url, {
    output: "json",
    logLevel: "error",
    port: chrome.port,
  });
} finally {
  await chrome.kill().catch(() => {});
}

if (!result) {
  console.error("Lighthouse returned no result");
  process.exit(1);
}

let report: string;
if (typeof result.report === "string") {
  report = result.report;
} else if (Array.isArray(result.report)) {
  report = result.report[0];
} else {
  report = JSON.stringify(result.lhr, null, 2);
}

await writeFile(OUTPUT, report, "utf-8");

const lhr = JSON.parse(report);
const scores = Object.fromEntries(
  Object.entries(lhr.categories).map(([key, cat]: [string, any]) => [
    key,
    Math.round((cat.score ?? 0) * 100),
  ])
);

console.log(JSON.stringify({ url, scores }));
