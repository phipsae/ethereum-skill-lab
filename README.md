# Ethereum Skill Lab

A skill that teaches AI agents to build Ethereum dApps, and a pipeline to test and improve it.

## How It Works

The **skill** (`ethereum-building-skill/`) is a set of markdown instructions covering 5 phases: contracts, testing, security, frontend, deploy. An AI agent reads the skill and follows it to build a project.

The **pipeline** (`test-runs/`) validates the skill by running two AI agents against a project brief:

1. **Builder** — follows the skill literally to build the project on a local Anvil fork
2. **Reviewer** — audits the result, runs `forge build` / `forge test` / `npm run build`, writes a report

The builder flags every gap in the skill (BLOCKER / MAJOR / MINOR / SUGGESTION). The reviewer merges those with its own findings into a prioritized list of fixes. You update the skill, re-run, and repeat until it's clean. Then move to the next project.

9 test projects are included, from simple (erc20-staking) to hard (uniswap-v4-hook).

**Coverage:** The pipeline tests phases 1–4 + Anvil deploy. Real deployment (testnet/mainnet, Etherscan verification, Vercel/IPFS) is covered by the skill but not tested by the pipeline.

## Quick Start

```bash
git clone --recurse-submodules https://github.com/phipsae/ethereum-skill-lab.git
cd ethereum-skill-lab

# Requires: forge, anvil, node, npm, claude (Claude Code CLI), jq
./test-runs/run.sh erc20-staking
```

Reports land in `test-runs/builds/<project-id>/reviewer-report.md`.
