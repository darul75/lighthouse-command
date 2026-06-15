import { tool } from "@opencode-ai/plugin"
import { readFile } from "fs/promises"
import path from "path"

export default tool({
  description: "Run a Lighthouse audit on a given URL path. Waits for the dev server, runs performance/accessibility/best-practices/seo audits, and returns a compact summary of scores and actionable issues.",
  args: {
    path: tool.schema.string().default("/").describe("URL path to audit (e.g. '/' or '/emploi')"),
    timeout: tool.schema.number().default(30000).describe("Max time to wait for the URL in ms"),
  },
  async execute(args, context) {
    const worktree = context.worktree || context.directory || process.cwd()
    const auditScript = path.join(worktree, "scripts/lighthouse-audit.ts")
    const summaryScript = path.join(worktree, "scripts/lighthouse-summary.ts")

    const { exitCode: auditExit, stderr: auditErr } = await Bun.$`bun run ${auditScript} ${args.path}`.quiet()
    if (auditExit !== 0) {
      return `Lighthouse audit failed:\n${auditErr.toString().trim()}`
    }

    const { exitCode: summaryExit, stderr: summaryErr } = await Bun.$`bun run ${summaryScript}`.quiet()
    if (summaryExit !== 0) {
      return `Summary generation failed:\n${summaryErr.toString().trim()}`
    }

    const summaryPath = path.join(worktree, "lighthouse-summary.json")
    const summaryContent = await readFile(summaryPath, "utf-8")

    return summaryContent
  },
})
