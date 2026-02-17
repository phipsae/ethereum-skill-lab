# Ethereum Skill Lab

A skill catalogue that teaches AI agents to build Ethereum dApps, and a pipeline to test and improve it.

## How It Works

The **skill catalogue** (`ethskills/`) contains ~22 Ethereum skills. `ship/SKILL.md` orchestrates end-to-end dApp building across 5 phases: plan, contracts, testing, frontend, deploy. An AI agent reads the ship skill and follows it to build a project.

The **pipeline** (`test-runs/`) validates the skills by running two AI agents against project briefs:

1. **Builder** — follows the skill literally to build the project on a local Anvil fork
2. **Reviewer** — audits the result, runs `forge build` / `forge test` / `npm run build`, writes a report

The builder flags every gap in the skill (BLOCKER / MAJOR / MINOR / SUGGESTION). The reviewer merges those with its own findings into a prioritized list of fixes. You update the skill, re-run, and repeat until it's clean. Then move to the next project.

9 test projects are included, from simple (erc20-staking) to hard (uniswap-v4-hook).

**Coverage:** The pipeline tests phases 0–4 on a local Anvil fork. Real deployment (testnet/mainnet, Etherscan verification, Vercel/IPFS) is covered by the skill but not tested by the pipeline.

## Quick Start

```bash
git clone --recurse-submodules https://github.com/phipsae/ethereum-skill-lab.git
cd ethereum-skill-lab

# Requires: forge, anvil, node, npm, claude (Claude Code CLI), jq
./test-runs/run.sh erc20-staking

# Run multiple projects
./test-runs/run.sh erc20-staking nft-marketplace dao-voting
```

Reports land in `test-runs/builds/<project-id>/reviewer-report.md`.

## Submodule

The `ethskills/` directory is a git submodule pointing to [`phipsae/ethskills`](https://github.com/phipsae/ethskills) (branch `refactor-skill-catalogue-add-ship-testing-indexing`).

```bash
# Switch to a different branch
cd ethskills && git checkout <branch> && cd ..

# Pin the new commit
git add ethskills
```

## Improving Skills

1. Run the pipeline on a project
2. Read the builder + reviewer reports
3. Branch in the submodule: `cd ethskills && git checkout -b improve/<topic>`
4. Edit skill files, then push and open a PR on the ethskills repo
5. Re-run the pipeline to verify
