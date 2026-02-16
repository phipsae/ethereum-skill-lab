# Uniswap V4 Hook

Build a custom Uniswap V4 hook that adds functionality to a liquidity pool.

## Requirements

### Smart Contracts
- **Custom Hook** contract that implements the Uniswap V4 `IHooks` interface
- Implement a meaningful hook (e.g., dynamic fee based on volatility, TWAP oracle, or limit orders)
- Hook must have the correct flags set for which callbacks it uses (beforeSwap, afterSwap, etc.)
- Deploy the hook at an address that encodes the correct flag bits (CREATE2 address mining)
- Initialize a pool with the hook attached
- Test swaps through the hooked pool

### Key Technical Challenges
- Uniswap V4 hooks architecture: PoolManager is singleton, hooks are per-pool
- CREATE2 address mining: hook address must have specific bits set that match the hook's flags
  - Use the `HookMiner` library to find a salt that produces the correct address prefix
- Flag encoding: the hook address's leading bytes encode which callbacks are active
- V4's `PoolKey` structure and pool initialization
- Interacting with PoolManager's singleton architecture (swap router, modify position)

### Testing
- Test hook deployment at correct CREATE2 address
- Test pool initialization with the hook
- Test that hook callbacks fire during swaps
- Test the hook's custom logic (e.g., fee adjustment, oracle update)
- Test swap through the hooked pool and verify expected behavior

### Frontend
- Pool information display (token pair, fee, hook address)
- Swap interface through the hooked pool
- Hook-specific data display (e.g., current dynamic fee, TWAP value)
- Pool liquidity stats

### Important
- This is the hardest project. Uniswap V4 is relatively new and LLMs frequently hallucinate APIs.
- The CREATE2 address mining is a common blocker — the skill must provide clear guidance.
- This project may surface BLOCKERs in the skill that don't appear in simpler projects.
- Fork mode is required to access Uniswap V4 deployed contracts (if using mainnet deployment) or the contracts must be deployed locally.
