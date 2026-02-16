# NFT Auction House

Build an auction house for ERC-721 NFTs with English auctions (ascending price).

## Requirements

### Smart Contracts
- **NFT** contract (ERC-721) for minting test NFTs
- **AuctionHouse** contract that manages English auctions for any ERC-721
- Auction lifecycle: Create → Bid → End/Settle
- Seller sets minimum price and auction duration
- Each new bid must exceed the previous bid by a minimum increment (e.g., 5%)
- Previous bidder's ETH is refunded when outbid (pull pattern preferred over push)
- Anti-sniping: if a bid arrives in the last N minutes, extend the auction
- Settlement: anyone can call `settle()` after auction ends — they receive a small incentive
- Seller receives winning bid minus platform fee
- Emit events for AuctionCreated, BidPlaced, AuctionExtended, AuctionSettled

### Key Technical Challenges
- Time-based logic using `block.timestamp` for auction duration and anti-sniping
- ETH escrow and refunds (pull pattern: losers withdraw their bids, not auto-refunded)
- Anti-sniping extension: bid in last 10 minutes extends deadline by 10 minutes
- Settlement incentive: someone must call settle() — design an incentive (small % of fee)
- NFT custody during auction (marketplace holds NFT until settlement)

### Testing
- Test full auction lifecycle: create → bid → bid higher → settle
- Use `vm.warp()` to test time-based logic (auction expiry, anti-sniping)
- Test anti-sniping: bid near end should extend auction
- Test minimum bid increment enforcement
- Test ETH refund for outbid bidders (pull pattern)
- Test settlement after auction ends
- Test settlement before auction ends (should revert)
- Test auction with no bids (NFT returned to seller)

### Frontend
- Create auction form (select NFT, set minimum price and duration)
- Active auctions gallery with countdown timers
- Bid form with current highest bid display
- User's active bids and claimable refunds
- Settle button for ended auctions
- Auction history / completed auctions
