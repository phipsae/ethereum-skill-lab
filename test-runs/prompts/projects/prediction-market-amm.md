# AMM Prediction Market

## User Request

"Build a prediction market with an AMM so users can trade positions before the market resolves. I want tokenized YES/NO positions that people can buy and sell, not just a simple betting pool."

## Follow-up Answers

- Binary outcomes (Yes/No). Positions are ERC-1155 tokens (token ID 0 = YES, token ID 1 = NO).
- Use a constant product market maker (x * y = k) for the AMM — users swap ETH for YES or NO tokens through the pool.
- Market creator seeds initial liquidity when creating a market (mints equal YES and NO tokens into the pool).
- Liquidity providers can add and remove liquidity proportionally.
- Fee: swap fee on each trade (e.g. 2%), not on winnings.
- Trusted EOA resolver — keep resolution simple since the AMM is the main complexity.
- Resolution: winning tokens are redeemable 1:1 for the underlying ETH, losing tokens become worthless.
- If the resolver never acts, anyone can cancel the market after the deadline so funds aren't stuck. On cancel, both YES and NO tokens are redeemable equally.
- Anyone can create a market with a question, resolution deadline, resolver address, and initial liquidity amount.
