# DeFi Insurance Pool Smart Contract

This smart contract implements a decentralized insurance platform with DAO-based governance for claims processing. The contract allows users to create insurance pools, stake funds, submit claims, and participate in the voting process to approve or reject claims.

## Features

1. **Insurance Pools**: Create and manage pools with specific coverage limits and premium rates.
2. **Staking**: Users can stake funds in pools to earn rewards and participate in governance.
3. **Claims Management**: Users can submit claims with evidence for evaluation and voting by pool participants.
4. **DAO Governance**: Claims are voted on by pool participants based on their stake, ensuring decentralized decision-making.
5. **Voting Period and Thresholds**: Configurable voting periods, minimum votes, and approval thresholds.

## Constants

### Contract Ownership
- **`CONTRACT-OWNER`**: The contract creator, who has certain administrative privileges.

### Error Codes
- **`ERR-UNAUTHORIZED`**: Action is unauthorized.
- **`ERR-INVALID-AMOUNT`**: Provided amount is invalid.
- **`ERR-INSUFFICIENT-BALANCE`**: Insufficient balance for the action.
- **`ERR-POOL-NOT-FOUND`**: Pool does not exist.
- **`ERR-CLAIM-NOT-FOUND`**: Claim does not exist.
- **`ERR-INVALID-POOL-STATE`**: Invalid pool status for the operation.
- **`ERR-ALREADY-VOTED`**: User has already voted on the claim.
- **`ERR-VOTING-CLOSED`**: Voting period has ended.
- **`ERR-INSUFFICIENT-VOTES`**: Not enough votes to process the claim.

### Pool Status
- **`POOL-ACTIVE`**: The pool is active and operational.
- **`POOL-PAUSED`**: The pool is temporarily paused.
- **`POOL-LIQUIDATED`**: The pool is liquidated.

### Claim Status
- **`CLAIM-PENDING`**: The claim is awaiting evaluation.
- **`CLAIM-APPROVED`**: The claim has been approved.
- **`CLAIM-REJECTED`**: The claim has been rejected.
- **`CLAIM-PAID`**: The claim has been paid.

### Governance Parameters
- **`VOTING-PERIOD`**: Duration of the voting period (~24 hours in blocks).
- **`MIN-VOTES-REQUIRED`**: Minimum votes required to process a claim.
- **`APPROVAL-THRESHOLD`**: Percentage of votes needed to approve a claim.

## Data Structures

### Maps

#### `InsurancePools`
Stores details of each insurance pool.
- **Keys**: `{ pool-id }`
- **Values**:
  - `name`: Pool name.
  - `status`: Pool status.
  - `total-staked`: Total funds staked in the pool.
  - `coverage-limit`: Maximum coverage amount.
  - `premium-rate`: Premium rate for the pool.
  - `claim-count`: Number of claims submitted.
  - `creation-height`: Block height at creation.

#### `PoolStakes`
Tracks staking details for each user in a pool.
- **Keys**: `{ pool-id, staker }`
- **Values**:
  - `amount`: Staked amount.
  - `rewards`: Accumulated rewards.
  - `last-reward-height`: Block height of the last reward update.

#### `InsuranceClaims`
Manages claim submissions and voting.
- **Keys**: `{ claim-id }`
- **Values**:
  - `pool-id`: Pool ID associated with the claim.
  - `claimer`: User who submitted the claim.
  - `amount`: Claim amount.
  - `evidence`: Supporting evidence.
  - `status`: Current claim status.
  - `yes-votes`: Votes in favor.
  - `no-votes`: Votes against.
  - `voters`: List of users who voted.
  - `claim-height`: Block height of claim submission.
  - `voting-end-height`: Block height when voting ends.

#### `StakerTotalStake`
Aggregates total stake for a user across pools.
- **Keys**: `{ staker }`
- **Values**:
  - `total-stake`: User’s total stake.

### Variables
- **`next-pool-id`**: ID for the next pool.
- **`next-claim-id`**: ID for the next claim.
- **`total-pools`**: Total number of pools.
- **`total-staked`**: Total funds staked across all pools.

## Functions

### Pool Management

#### `create-insurance-pool`
Creates a new insurance pool.
- **Parameters**:
  - `name`: Name of the pool.
  - `coverage-limit`: Maximum coverage amount.
  - `premium-rate`: Premium rate.
- **Returns**: Pool ID.

#### `stake-in-pool`
Allows users to stake funds in a pool.
- **Parameters**:
  - `pool-id`: ID of the pool.
  - `amount`: Amount to stake.
- **Returns**: `true` on success.

#### `unstake-from-pool`
Enables users to withdraw staked funds.
- **Parameters**:
  - `pool-id`: ID of the pool.
  - `amount`: Amount to unstake.
- **Returns**: `true` on success.

### Claim Management

#### `submit-claim`
Submits a claim for evaluation.
- **Parameters**:
  - `pool-id`: ID of the pool.
  - `amount`: Claim amount.
  - `evidence`: Supporting evidence.
- **Returns**: Claim ID.

#### `vote-on-claim`
Allows users to vote on a claim.
- **Parameters**:
  - `claim-id`: ID of the claim.
  - `approve`: Boolean indicating approval or rejection.
- **Returns**: `true` on success.

#### `process-claim`
Processes a claim based on voting results.
- **Parameters**:
  - `claim-id`: ID of the claim.
- **Returns**: `true` on success.

### Read-Only Functions

#### `get-pool-info`
Retrieves information about a pool.
- **Parameters**: `pool-id`
- **Returns**: Pool details.

#### `get-stake-info`
Retrieves staking information for a user in a pool.
- **Parameters**: `pool-id`, `staker`
- **Returns**: Stake details.

#### `get-claim-info`
Retrieves information about a claim.
- **Parameters**: `claim-id`
- **Returns**: Claim details.

#### `get-staker-total`
Retrieves the total stake of a user.
- **Parameters**: `staker`
- **Returns**: Total stake.

## Governance

- Claims are approved or rejected based on the votes of pool participants.
- Each participant's voting power is proportional to their stake in the pool.
- A claim requires a minimum number of votes and a majority threshold for approval.

## Security Considerations

- Only the contract owner can create insurance pools.
- Funds are securely transferred using the `stx-transfer?` function.
- Strict checks ensure valid operations, such as preventing duplicate votes and unauthorized actions.
- Voting periods are enforced to prevent manipulation.

## Deployment

1. Deploy the contract to the Stacks blockchain.
2. Initialize the contract by setting the contract owner.
3. Create insurance pools and allow users to participate.

## Future Enhancements

- Support for dynamic governance parameters.
- Integration with off-chain oracles for automated claim validation.
- Enhanced reward mechanisms for stakers.
- User-friendly front-end interface for interaction with the contract.

