# ERC-4626 Tokenized Vault

Build an ERC-4626 compliant vault that accepts deposits and distributes yield to depositors proportionally.

## Requirements

### Smart Contracts
- **Vault** contract implementing the full ERC-4626 interface (deposit, mint, withdraw, redeem)
- Depositors receive shares proportional to their deposit
- Vault holds an underlying ERC-20 asset (e.g., a mock token or USDC)
- Yield is simulated by the owner adding assets to the vault (increasing assets-per-share)
- Include inflation attack protection (virtual shares/assets offset or minimum deposit)
- Proper rounding: round DOWN for shares minted (deposit/mint), round UP for assets needed (withdraw/redeem)
- Emit standard ERC-4626 events (Deposit, Withdraw)

### Key Technical Challenges
- Share math: `shares = assets * totalSupply / totalAssets` with proper rounding
- Inflation attack: first depositor can manipulate share price. Use OpenZeppelin's ERC4626 with virtual offset or require minimum initial deposit
- Rounding direction matters for security (favor the vault, not the user)
- Preview functions must match actual execution (previewDeposit, previewMint, previewWithdraw, previewRedeem)
- Converting between shares and assets in both directions

### Testing
- Test deposit → withdraw cycle with single user
- Test with multiple depositors, verify proportional share distribution
- Test yield accrual: deposit → owner adds yield → verify shares are worth more
- Test inflation attack protection (attacker donates large amount before victim deposits)
- Test rounding: small deposits should not get 0 shares
- Test all four entry/exit points: deposit, mint, withdraw, redeem
- Verify preview functions match actual amounts

### Frontend
- Deposit and withdraw forms
- Display user's shares, share value in underlying asset, and pending yield
- Vault stats: total assets, total shares, current exchange rate
- Yield history or current APY display
