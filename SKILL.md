---
name: lighthouse-command
description: Automated Lighthouse audits with self-healing fix loop for OpenCode. Run /lighthouse to audit performance, accessibility, and more.
---

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

## When to use

Use this command when you need to:
- Improve your app's Lighthouse scores before a launch
- Fix accessibility issues (alt text, ARIA labels, color contrast)
- Optimize performance (LCP, TBT, CLS)
- Fix SEO problems (meta tags, headings, structured data)
- Run automated audits in CI-like loop during development

## How to install

Run this in your project directory:

```bash
bash <(curl -sL https://raw.githubusercontent.com/darul75/lighthouse-command/main/install.sh)
```

## Prerequisites

- Node.js 22+ (or Bun)
- Google Chrome installed
- OpenCode with a provider configured

## Instructions for the agent

When the user runs `/lighthouse` or asks to fix Lighthouse scores:

1. **Call `run-lighthouse({ path: "/" })`** to start with the homepage
2. **Read the JSON summary** — it contains scores and actionable issues
3. **Fix the highest-priority issues first:**
   - Add `width`/`height` and `alt` to images
   - Add ARIA labels to buttons and interactive elements
   - Add `rel="noopener"` to external links
   - Add `loading="lazy"` to below-the-fold images
   - Set `font-display: swap` for web fonts
   - Fix color contrast issues
4. **Re-run** `run-lighthouse()` to verify improvements
5. **Repeat** until targets are met or 5 iterations reached

## Rules

- Do NOT change visual appearance or remove features
- Explain each fix before applying
- If no improvement after 2 iterations, stop and summarize

## Repository

https://github.com/darul75/lighthouse-command
