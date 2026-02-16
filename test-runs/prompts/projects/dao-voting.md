# DAO Voting System

Build a DAO governance system where token holders can create proposals, vote, and execute on-chain actions.

## Requirements

### Smart Contracts
- **GovernanceToken** (ERC-20 with ERC20Votes extension) for voting power
- **Governor** contract that manages proposals, voting, and execution
- Proposal lifecycle: Pending → Active → Succeeded/Defeated → Executed
- Voting options: For, Against, Abstain
- Proposals have a voting delay (blocks before voting starts) and voting period (blocks during which voting is open)
- Quorum requirement (minimum votes needed for a proposal to pass)
- Execution via low-level `call` to execute arbitrary on-chain actions
- Emit events for ProposalCreated, VoteCast, ProposalExecuted

### Key Technical Challenges
- State machine for proposal lifecycle (proper status transitions)
- Block-based timing using `block.number` (use `vm.roll()` in tests)
- ERC20Votes delegation (users must delegate to themselves or others before voting power counts)
- Low-level `call` for proposal execution (encoding calldata, handling return values)
- Quorum calculation based on total supply or total delegated votes

### Testing
- Test full lifecycle: create proposal → vote → execute
- Use `vm.roll()` to advance blocks through voting delay and voting period
- Test quorum: proposal with insufficient votes should not pass
- Test delegation: votes only count after delegation
- Test execution of an on-chain action (e.g., transferring tokens from a treasury)
- Test double-voting prevention

### Frontend
- Create proposal form (target contract, function, arguments, description)
- Active proposals list with vote counts
- Vote buttons (For / Against / Abstain)
- Proposal status display (Pending, Active, Succeeded, Defeated, Executed)
- User's voting power and delegation controls
