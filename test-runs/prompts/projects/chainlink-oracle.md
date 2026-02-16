# Chainlink Oracle Lending Protocol

Build a simple lending protocol that uses Chainlink price feeds to determine collateral values and trigger liquidations.

## Requirements

### Smart Contracts
- **LendingPool** contract where users deposit collateral (ETH or WETH) and borrow a stablecoin
- Use Chainlink ETH/USD price feed for real-time collateral valuation
- Collateralization ratio requirement (e.g., 150% — must deposit $150 of ETH to borrow $100)
- Liquidation mechanism: if collateral ratio drops below threshold, anyone can liquidate
- Liquidator receives a bonus (e.g., 5% liquidation incentive) for calling liquidate
- Oracle staleness check: reject prices older than a threshold (e.g., 1 hour)
- Emit events for Deposit, Borrow, Repay, Liquidate

### Key Technical Challenges
- Chainlink price feed integration (AggregatorV3Interface, `latestRoundData()`)
- Cross-decimal math: ETH price feed returns 8 decimals, USDC has 6 decimals, ETH has 18 decimals
- Staleness checks: `updatedAt` must be recent enough, `answeredInRound >= roundId`
- Liquidation incentive design: liquidator must be financially motivated to call the function
- Collateral ratio calculation with correct decimal normalization

### Testing
- Test deposit collateral and borrow stablecoin
- Test collateral ratio calculation with real Chainlink prices (on fork)
- Test liquidation when price drops (use `vm.mockCall` or manipulate price feed)
- Test oracle staleness rejection
- Test liquidation incentive: verify liquidator receives bonus
- Test borrowing more than collateral allows (should revert)
- Test repayment and collateral withdrawal

### Frontend
- Deposit collateral form (ETH amount)
- Borrow stablecoin form with max borrowable display
- Current collateral ratio display with health indicator (green/yellow/red)
- Repay and withdraw buttons
- Liquidatable positions list (for liquidators)
- Live ETH/USD price from Chainlink

### Important
- This project REQUIRES fork mode for real Chainlink price feeds
- Fetch Chainlink feed addresses from ethskills.com, not hardcoded
