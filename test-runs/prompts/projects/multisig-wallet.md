# Multisig Wallet

Build an M-of-N multisig wallet where multiple owners must approve transactions before execution.

## Requirements

### Smart Contracts
- **MultisigWallet** contract with configurable owners and approval threshold (M of N)
- Support ETH transfers, ERC-20 token transfers, and arbitrary contract calls
- Transaction lifecycle: Submit → Confirm (by M owners) → Execute
- Owners can revoke their confirmation before execution
- Only owners can submit, confirm, revoke, and execute transactions
- The wallet can receive ETH via `receive()` function
- Emit events for Submit, Confirm, Revoke, Execute, and Deposit

### Key Technical Challenges
- M-of-N access control (tracking which owners have confirmed each transaction)
- Storing and executing arbitrary calldata via low-level `call`
- ETH and ERC-20 token transfer support through the same execution mechanism
- Preventing double-confirmation by the same owner
- Owner management (adding/removing owners should itself require multisig approval)

### Testing
- Test full lifecycle: submit → confirm (M times) → execute
- Test ETH transfer execution
- Test ERC-20 token transfer execution (wallet holds tokens, multisig sends them)
- Test execution with insufficient confirmations (should revert)
- Test confirmation revocation
- Test non-owner access (should revert on all functions)
- Test arbitrary contract call execution (e.g., calling another contract's function)

### Frontend
- Display wallet ETH and token balances
- Submit new transaction form (recipient, value, calldata)
- Pending transactions list showing confirmation count vs threshold
- Confirm / Revoke / Execute buttons per transaction
- Owner list and current threshold display
