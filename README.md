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
git clone --recurse-submodules https://github.com/phipsae/ethereum-skills.git
cd ethereum-skills

# Prerequisites: forge, anvil, node, npm, claude (Claude Code CLI), jq
# Optional env vars: FORK_RPC, MODEL (default: sonnet), BUILDER_MAX_BUDGET, REVIEWER_MAX_BUDGET

# Run the pipeline against a project
./test-runs/run.sh erc20-staking
```

Reports land in `test-runs/builds/<project-id>/reviewer-report.md`.
