# Prediction Market

## User Request

"Build a prediction market where users can create markets on any topic, bet on outcomes, and claim winnings after resolution."

## Follow-up Answers

- Binary outcomes only (Yes or No) for the MVP.
- Anyone can create a market with a question, resolution deadline, and designated resolver address.
- Users bet with ETH — winnings come proportionally from the losing side's pool.
- The resolver calls a function to declare the outcome after the deadline. Trusted EOA is fine for the MVP.
- If the resolver never acts, anyone should be able to cancel the market after the resolution deadline so funds aren't stuck.
- No position trading needed — users just bet and claim. Pool-based is fine.
- If nobody bet on the losing side, winners just get their original stake back. If nobody bet on the winning side, cancel the market.
- 2% fee on winnings goes to the market creator.
