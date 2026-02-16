# NFT Marketplace

Build an NFT marketplace where users can mint, list, buy, and sell ERC-721 NFTs.

## Requirements

### Smart Contracts
- **NFT** contract (ERC-721) with minting functionality and metadata URI support
- **Marketplace** contract that handles listings, purchases, and fee collection
- Sellers list NFTs with an asking price in ETH
- Buyers purchase listed NFTs by sending the correct ETH amount
- Marketplace charges a fee on each sale (e.g., 250 basis points = 2.5%)
- Seller can cancel their listing and reclaim the NFT
- Use Checks-Effects-Interactions (CEI) pattern for all ETH transfers
- Emit events for Listed, Sold, Cancelled, and FeeCollected

### Key Technical Challenges
- ERC-721 approve/transferFrom flow (seller must approve marketplace before listing)
- ETH payments with correct fee splitting (marketplace fee vs seller proceeds)
- Basis point math for fee calculation (fee = price * bps / 10000)
- CEI pattern to prevent reentrancy on ETH transfers
- Handling the NFT custody model (does marketplace hold the NFT, or does it transfer on sale?)

### Testing
- Test full lifecycle: mint → approve → list → buy
- Test fee calculation with various prices
- Test listing cancellation
- Test buying without sufficient ETH (should revert)
- Test buying an unlisted NFT (should revert)
- Test that seller receives correct proceeds after fee deduction

### Frontend
- Gallery view of all minted NFTs
- List NFT for sale form (select NFT, set price)
- Buy button on listed NFTs
- Show marketplace fee and seller proceeds breakdown
- User's owned NFTs and active listings sections
