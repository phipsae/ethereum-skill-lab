# Ethereum AI Agent Skills

An opinionated skill that teaches AI agents how to build production Ethereum dApps, plus an automated pipeline to test and improve the skill.

## Repository Structure

```
ethereum-building-skill/   ← The skill (git submodule)
test-runs/                 ← Automated testing pipeline
CLAUDE.md                  ← Instructions for Claude Code
```

### ethereum-building-skill

A meta-router architecture: one root `SKILL.md` routes to 5 phase-specific sub-skills (contracts, testing, security, frontend, deploy). Loaded on demand to keep context lean. Default stack is Scaffold-ETH 2 on a mainnet fork.

See the [skill repo](https://github.com/phipsae/ethereum-building-skills) for full details.

### test-runs

Validates the skill by having AI agents build real projects and review the results. Two agents run in sequence:

1. **Builder** — follows the skill literally to build a project from a brief
2. **Reviewer** — audits the build, runs `forge build` / `forge test` / `npm run build`, writes a consolidated report

9 test projects are included, ordered by difficulty: erc20-staking, nft-marketplace, dao-voting, token-swap, multisig-wallet, erc4626-vault, chainlink-oracle, nft-auction, uniswap-v4-hook.

## Quick Start

```bash
# Clone with submodule
git clone --recurse-submodules https://github.com/phipsae/ethereum-skill-lab.git
cd ethereum-skill-lab

# Prerequisites: forge, anvil, node, npm, claude (Claude Code CLI), jq
# Optional env vars: FORK_RPC, MODEL (default: sonnet), BUILDER_MAX_BUDGET, REVIEWER_MAX_BUDGET

# Run the pipeline against a project
./test-runs/run.sh erc20-staking
```

Reports land in `test-runs/builds/<project-id>/reviewer-report.md`.

## What the Test Loop Does (and Doesn't)

The pipeline spins up a local Anvil fork of mainnet and tests **phases 1–4** end-to-end:

- **Contracts** — Solidity compiles, Foundry tests pass
- **Testing** — test coverage for edge cases, access control, reentrancy
- **Security** — audit patterns applied correctly
- **Frontend** — Next.js + wagmi app builds successfully
- **Anvil deploy** — contracts deploy to the local fork

**Not tested:** real deployment to Sepolia/mainnet/L2s, Etherscan verification, frontend deploy to Vercel/IPFS, and ENS setup. These require real credentials and cost real ETH, so they're covered by the skill's Phase 5 instructions but not validated by the automated pipeline.

## The Improvement Loop

The pipeline isn't just a one-shot test — it's a feedback loop for improving the skill.

### How it works

```
┌─────────────────────────────────────────────────────┐
│  1. Run pipeline        ./test-runs/run.sh <project> │
│                              │                       │
│  2. Builder agent            ▼                       │
│     Follows the skill    Hits a gap or               │
│     literally            unclear instruction          │
│                              │                       │
│  3. Builder reports it       ▼                       │
│     as BLOCKER / MAJOR / builder-report.md           │
│     MINOR / SUGGESTION       │                       │
│                              ▼                       │
│  4. Reviewer agent       Reads builder report +      │
│                          runs forge/npm builds       │
│                              │                       │
│  5. Reviewer writes          ▼                       │
│     consolidated         reviewer-report.md          │
│     ranked report        (prioritized fixes)         │
│                              │                       │
│  6. Human/agent reads        ▼                       │
│     report, edits        skill files updated         │
│     the skill                │                       │
│                              ▼                       │
│  7. Re-run same project  Confirm fixes work          │
│                              │                       │
│  8. Move to next project     ▼                       │
│                          Repeat                      │
└─────────────────────────────────────────────────────┘
```

### Severity levels

The builder agent categorizes every issue it encounters:

| Level | Meaning |
|-------|---------|
| **BLOCKER** | Can't continue — skill instruction is wrong or missing |
| **MAJOR** | Built something, but had to guess or deviate from the skill |
| **MINOR** | Cosmetic or unclear wording, didn't affect the build |
| **SUGGESTION** | Nice-to-have improvement |

The reviewer merges these with its own findings (compile errors, test failures, frontend build issues) into a single ranked list of recommendations. You fix from the top down.
