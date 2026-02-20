# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## What This Is

An Ethereum AI agent skill catalogue and its automated testing pipeline:

1. **`ethskills/`** — Flat catalogue of ~22 Ethereum skills (git submodule, lives at `github.com/phipsae/ethskills`, branch `refactor-skill-catalogue-add-ship-testing-indexing`). `ship/SKILL.md` is the orchestrator that routes to other skills for end-to-end dApp building.

2. **`test-runs/`** — Automated pipeline that validates the skill by having AI agents build real projects and review the results.

## No Build/Test Commands

The skill is a pure markdown knowledge base — no dependencies, no build system. To check content size: `wc -c <file>`.

The pipeline has a shell script runner — see Testing Pipeline below.

## Architecture

### ethskills (submodule)

```
SKILL.md                 ← Catalogue root
ship/SKILL.md            ← Builder entry point: orchestrates end-to-end dApp building
contracts/SKILL.md       ← Solidity + Foundry patterns
testing/SKILL.md         ← What agents forget to test
security/SKILL.md        ← Audit checklist + historical hacks
frontend-playbook/...    ← Next.js + wagmi v2 + viem
...                      ← ~22 skills total (flat catalogue)
```

Build workflow: `ship/SKILL.md` drives Phase 0 (plan) → Phase 1 (contracts) → Phase 2 (test) → Phase 3 (frontend) → Phase 4 (deploy), loading the relevant skill for each phase.

### test-runs/

```
test-runs/
├── run.sh                       ← Pipeline script (supports multiple projects)
├── prompts/
│   ├── builder-system.md        ← Builder agent system prompt
│   ├── reviewer-system.md       ← Reviewer agent system prompt
│   └── projects/                ← 9 project briefs
├── builds/<project-id>/         ← Build outputs
│   ├── project/                 ← Built code
│   ├── builder-report.md
│   ├── reviewer-report.md
│   └── run-meta.json
└── reports/latest.md            ← Symlink to most recent report
```

**Usage:** `./test-runs/run.sh <project-id> [project-id...]` — starts Anvil (mainnet fork), runs builder + reviewer agents for each project. Anvil stays running across all projects.

**Config:** `MODEL` (default: sonnet), `FORK_RPC`, `BUILDER_MAX_BUDGET` / `REVIEWER_MAX_BUDGET`. Requires: forge, anvil, node, npm, claude, jq.

**9 test projects by difficulty:** erc20-staking, nft-marketplace, dao-voting, token-swap, multisig-wallet, erc4626-vault, chainlink-oracle, nft-auction, uniswap-v4-hook.

## Improvement Workflow

1. Run the pipeline: `./test-runs/run.sh <project-id>`
2. Read the reports in `test-runs/builds/<project-id>/`
3. Edit skill files on the current ethskills branch
4. Commit and push changes

## Submodule Management

The `ethskills/` submodule points to `https://github.com/phipsae/ethskills`. Currently on branch `refactor-skill-catalogue-add-ship-testing-indexing`.

```bash
# Switch branch
cd ethskills && git checkout <branch> && cd ..

# Pin new commit in parent repo
git add ethskills && git commit -m "Update ethskills submodule"

# After fresh clone, init submodule
git submodule update --init --recursive
```

## Key Conventions

- **Contract addresses** must be verified on-chain via `eth_getCode` — never add unverified addresses
- **Only include what LLMs get wrong** — don't repeat what models already know
- **Accuracy over everything** — all data must be verified against on-chain reality
- Core philosophy: "NOTHING IS AUTOMATIC ON ETHEREUM" — always design incentives for function callers
- Default stack: Next.js + wagmi v2 + viem + RainbowKit, always fork mode (never blank local chains)
- `ship/SKILL.md` is the builder entry point — it orchestrates which skills to load per phase
