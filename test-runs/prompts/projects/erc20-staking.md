# ERC-20 Staking dApp

Build a staking dApp where users can stake an ERC-20 token and earn rewards over time.

## Requirements

### Smart Contracts
- **StakingVault** contract that accepts deposits of a specific ERC-20 token
- Users can stake tokens, withdraw tokens, and harvest (claim) accumulated rewards
- Rewards accrue linearly over time based on the user's share of the total staked amount
- Reward rate is configurable by the owner
- Include a `harvest()` function that lets users claim their pending rewards without unstaking
- Use ReentrancyGuard on all external functions that transfer tokens
- Emit events for Stake, Withdraw, Harvest, and RewardRateUpdated

### Key Technical Challenges
- ERC-20 approve/transferFrom flow (users must approve before staking)
- Time-based reward math using `block.timestamp`
- Precision handling to avoid rounding errors (use 1e18 scaling)
- Reentrancy protection on withdraw and harvest

### Testing
- Test the full stake → accrue → harvest → withdraw cycle
- Test with multiple stakers to verify fair reward distribution
- Use `vm.warp()` to advance time and test reward accumulation
- Test edge cases: staking zero, withdrawing more than staked, harvesting with no rewards
- Test the approve flow (staking without approval should revert)

### Frontend
- Connect wallet button
- Display user's token balance, staked amount, and pending rewards
- Stake and withdraw forms with amount inputs
- Harvest rewards button
- Show total staked in the vault and current reward rate

### Token
- Use a real ERC-20 token on the Anvil fork (e.g., USDC or DAI), OR deploy a simple mock ERC-20 for testing
- If using a mock token, include a faucet function so testers can mint tokens
