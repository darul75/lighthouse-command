# Lighthouse Command

An OpenCode command + tool that runs Lighthouse audits and auto-fixes performance, accessibility, best-practices, and SEO issues in a self-healing loop.

```
/lighthouse
```

## How it works

```
You type /lighthouse
        │
        ▼
OpenCode loads the lighthouse-fix agent
        │
        ▼
Agent calls run-lighthouse({ path: "/" })
        │
        ▼
  chrome-launcher → Lighthouse → raw JSON (~400KB)
        │
        ▼
  lighthouse-summary.ts → compact summary (~3KB)
        │
        ▼
Agent reads: { scores: { performance: 64, ... }, issues: [...] }
        │
        ▼
Agent edits source files (alt text, image dims, ARIA labels, etc.)
        │
        ▼
Agent calls run-lighthouse() again
        │
        ▼
  ... repeat until targets met or 5 iterations ...
```

## Quick install

```bash
# In your project directory, run:
bash <(curl -sL https://raw.githubusercontent.com/<your-username>/lighthouse-command/main/install.sh)

# Or with a local clone:
git clone https://github.com/<your-username>/lighthouse-command.git
cd lighthouse-command
./install.sh /path/to/your/project
```

## Prerequisites

- **Node.js 22+** (or Bun)
- **Google Chrome** installed (Lighthouse uses it via `chrome-launcher`)
- **OpenCode** with a provider configured
- Your dev server running (e.g. `bun run dev` on `localhost:3000`)

## What gets installed

| File | Purpose |
|---|---|
| `scripts/lighthouse-audit.ts` | Waits for URL, launches Chrome, runs Lighthouse, saves raw JSON |
| `scripts/lighthouse-summary.ts` | Extracts scores + actionable issues into a compact AI-friendly JSON |
| `.opencode/commands/lighthouse.md` | Registers the `/lighthouse` command |
| `.opencode/tools/run-lighthouse.ts` | Custom OpenCode tool — agent calls `run-lighthouse({ path })` |
| `.opencode/prompts/lighthouse-fix.md` | Agent instructions for the fix loop |
| `opencode.json` | Agent configuration (merged if exists) |

Dependencies added: `lighthouse`, `@opencode-ai/plugin`

## Usage

### 1. Start your dev server

```bash
bun run dev    # or npm/pnpm/yarn
```

### 2. Run the command in OpenCode

In the OpenCode TUI:

```
/lighthouse
```

The agent will:
1. Call `run-lighthouse()` to audit `/`
2. Read the scores and issues
3. Fix the highest-priority problems
4. Re-run the audit
5. Repeat until targets are met

### Or audit a specific route

```
run-lighthouse({ path: "/emploi" })
```

### Manual run

```bash
npm run lighthouse:all
# → lighthouse-results.json (full report)
# → lighthouse-summary.json (AI-friendly summary)
```

## Targets

| Category | Target |
|---|---|
| Performance | ≥ 90 |
| Accessibility | ≥ 95 |
| Best Practices | ≥ 95 |
| SEO | ≥ 95 |

## What gets fixed automatically

Safe, common fixes the agent applies:

- Add `width` and `height` to `<img>` elements
- Add `alt` text to images
- Add ARIA labels to interactive elements
- Add `<meta name="description">` and `<title>`
- Add `rel="noopener"` to external links
- Remove unused CSS/JS imports
- Add `loading="lazy"` to below-the-fold images
- Set `font-display: swap` for web fonts
- Fix color contrast issues

## Configuration

Environment variables:

| Variable | Default | Description |
|---|---|---|
| `LH_BASE_URL` | `http://localhost:3000` | Base URL of your app |
| `LH_TIMEOUT` | `30000` | Max wait time for URL (ms) |

## Project structure

```
lighthouse-command/
├── scripts/
│   ├── lighthouse-audit.ts       # Runs Lighthouse via Node API
│   └── lighthouse-summary.ts     # Compacts results for AI
├── command/
│   ├── commands/
│   │   └── lighthouse.md         # /lighthouse command definition
│   ├── tools/
│   │   └── run-lighthouse.ts     # OpenCode custom tool
│   └── prompts/
│       └── lighthouse-fix.md     # Agent instructions
├── install.sh                    # One-command installer
├── package.json
└── README.md
```

## Uninstall

```bash
rm scripts/lighthouse-audit.ts scripts/lighthouse-summary.ts
rm -rf .opencode/commands/lighthouse.md .opencode/tools/run-lighthouse.ts .opencode/prompts/lighthouse-fix.md
npm uninstall lighthouse @opencode-ai/plugin
# Remove "lighthouse-fix" agent from opencode.json
# Remove npm scripts from package.json
```

## License

MIT
