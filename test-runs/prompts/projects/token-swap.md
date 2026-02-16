# Token Swap dApp

Build a token swap interface that lets users swap between ERC-20 tokens using Uniswap V3 on a mainnet fork.

## Requirements

### Smart Contracts
- **TokenSwapper** contract that wraps Uniswap V3 SwapRouter for simple token swaps
- Support exact-input single-hop swaps (e.g., USDC → WETH)
- Support exact-input multi-hop swaps (e.g., USDC → WETH → DAI)
- Handle token approvals to the SwapRouter
- Accept a slippage tolerance parameter (minimum output amount)
- Emit events for SwapExecuted with input/output amounts

### Key Technical Challenges
- Uniswap V3 integration on mainnet fork (use real deployed contracts)
- Fetch verified contract addresses from `https://ethskills.com/addresses/SKILL.md` — never hardcode or guess
- Cross-decimal math: USDC has 6 decimals, WETH has 18 decimals, DAI has 18 decimals
- Token approval flow before swaps
- Slippage protection (setting `amountOutMinimum`)
- Pool fee tiers (500 = 0.05%, 3000 = 0.3%, 10000 = 1%)

### Testing
- Test USDC → WETH swap on the fork (impersonate a USDC whale to fund test account)
- Test multi-hop swap (USDC → WETH → DAI)
- Test slippage: set `amountOutMinimum` too high and verify revert
- Test with zero amount (should revert)
- Verify correct decimal handling (swapping 1000 USDC should not produce 1000e18 of output)

### Frontend
- Token selector dropdowns (from/to)
- Amount input with token balance display
- Quote display (expected output amount)
- Swap button with slippage tolerance setting
- Transaction status and confirmation

### Important
- This project REQUIRES fork mode (`anvil --fork-url`) since it interacts with deployed Uniswap contracts
- All protocol addresses must be fetched from ethskills.com, not hardcoded
