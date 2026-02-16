# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## What This Is

An Ethereum AI agent skill and its automated testing pipeline:

1. **`ethereum-building-skill/`** — Opinionated playbook for building production Ethereum dApps (git submodule, lives at `github.com/phipsae/ethereum-building-skills`). Meta-router architecture: root `SKILL.md` routes to 5 phase-specific sub-skills (contracts, testing, security, frontend, deploy).

2. **`test-runs/`** — Automated pipeline that validates the skill by having AI agents build real projects and review the results.

## No Build/Test Commands

The skill is a pure markdown knowledge base — no dependencies, no build system. To check content size: `wc -c <file>`.

The pipeline has a shell script runner — see Testing Pipeline below.

## Architecture

### ethereum-building-skill (submodule)

```
SKILL.md                 ← Meta router, always loaded first
├── contracts/SKILL.md      Phase 1: Solidity + Foundry patterns
├── testing/SKILL.md        Phase 2: What agents forget to test
├── security/SKILL.md       Phase 3: Audit checklist + historical hacks
├── frontend/SKILL.md       Phase 4: Next.js + wagmi v2 + viem
├── deploy/SKILL.md         Phase 5: Production deployment
└── docs/SPEC.md            Full specification (maintainer reference)
```

Full build: phases 1→2→3→4→5. Partial workflows load only the relevant sub-skill. Content constraints: sub-skills 150-200 lines, hard max 250 lines per file.

### test-runs/

```
test-runs/
├── run.sh                       ← Pipeline script (portable, no hardcoded paths)
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

**Usage:** `./test-runs/run.sh <project-id>` — starts Anvil (mainnet fork), runs builder agent, stops Anvil, runs reviewer agent.

**Config:** `MODEL` (default: sonnet), `FORK_RPC`, `BUILDER_MAX_BUDGET` / `REVIEWER_MAX_BUDGET`. Requires: forge, anvil, node, npm, claude, jq.

**9 test projects by difficulty:** erc20-staking, nft-marketplace, dao-voting, token-swap, multisig-wallet, erc4626-vault, chainlink-oracle, nft-auction, uniswap-v4-hook.

## Key Conventions

- **Contract addresses** must be verified on-chain via `eth_getCode` — never add unverified addresses
- **Only include what LLMs get wrong** — don't repeat what models already know
- **Accuracy over everything** — all data must be verified against on-chain reality
- Core philosophy: "NOTHING IS AUTOMATIC ON ETHEREUM" — always design incentives for function callers
- Default stack: Scaffold-ETH 2 with fork mode, never blank local chains
- Changes to sub-skills should reflect patterns from `docs/SPEC.md`
- Never load all 5 sub-skills at once — the meta router picks the right one
