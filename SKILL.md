# Lighthouse Command

An OpenCode `/lighthouse` command that runs Google Lighthouse audits and automatically fixes performance, accessibility, best-practices, and SEO issues in a self-healing loop.

```
/lighthouse
    │
    ▼
run-lighthouse({ path: "/" })
    │
    ▼
Lighthouse audit → scores + issues summary
    │
    ▼
Agent fixes code → re-audits → repeats
    │
    ▼
Stops when targets met or 5 iterations
```

**Scores targeted:** performance ≥ 90, accessibility ≥ 95, best-practices ≥ 95, seo ≥ 95

## How to install

Run this in your project directory:

```bash
bash <(curl -sL https://raw.githubusercontent.com/darul75/lighthouse-command/main/install.sh)
```

This installs the scripts, OpenCode tool, command, and dependencies.

## Prerequisites

- Node.js 22+ (or Bun)
- Google Chrome installed
- OpenCode with a provider configured

## Usage

1. Start your dev server: `bun run dev` (or npm/pnpm/yarn)
2. In OpenCode TUI: `/lighthouse`
3. The agent audits the page, reads issues, fixes them, and repeats

To audit a specific route: `run-lighthouse({ path: "/emploi" })`

## Common fixes the agent applies

- Adds `width` and `height` to images, `alt` text, ARIA labels
- Adds `rel="noopener"` to external links
- Removes unused CSS/JS imports
- Adds `loading="lazy"` to below-the-fold images
- Sets `font-display: swap` for web fonts
- Fixes color contrast

## Repository

https://github.com/darul75/lighthouse-command
