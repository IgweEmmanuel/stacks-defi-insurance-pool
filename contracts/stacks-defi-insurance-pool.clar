;; DeFi Insurance Pool Contract
;; Implements pooled insurance with DAO governance for claims

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INVALID-AMOUNT (err u2))
(define-constant ERR-INSUFFICIENT-BALANCE (err u3))
(define-constant ERR-POOL-NOT-FOUND (err u4))
(define-constant ERR-CLAIM-NOT-FOUND (err u5))
(define-constant ERR-INVALID-POOL-STATE (err u6))
(define-constant ERR-ALREADY-VOTED (err u7))
(define-constant ERR-VOTING-CLOSED (err u8))
(define-constant ERR-INSUFFICIENT-VOTES (err u9))

;; Pool status
(define-constant POOL-ACTIVE u1)
(define-constant POOL-PAUSED u2)
(define-constant POOL-LIQUIDATED u3)

;; Claim status
(define-constant CLAIM-PENDING u1)
(define-constant CLAIM-APPROVED u2)
(define-constant CLAIM-REJECTED u3)
(define-constant CLAIM-PAID u4)

;; Governance parameters
(define-constant VOTING-PERIOD u144) ;; ~24 hours in blocks
(define-constant MIN-VOTES-REQUIRED u10)
(define-constant APPROVAL-THRESHOLD u7) ;; 70% approval needed

;; Variables
(define-data-var next-pool-id uint u0)
(define-data-var next-claim-id uint u0)
(define-data-var total-pools uint u0)
(define-data-var total-staked uint u0)


;; Data Maps
(define-map InsurancePools
    { pool-id: uint }
    {
        name: (string-ascii 50),
        status: uint,
        total-staked: uint,
        coverage-limit: uint,
        premium-rate: uint,
        claim-count: uint,
        creation-height: uint
    }
)

(define-map PoolStakes
    { pool-id: uint, staker: principal }
    {
        amount: uint,
        rewards: uint,
        last-reward-height: uint
    }
)

(define-map InsuranceClaims
    { claim-id: uint }
    {
        pool-id: uint,
        claimer: principal,
        amount: uint,
        evidence: (string-ascii 256),
        status: uint,
        yes-votes: uint,
        no-votes: uint,
        voters: (list 100 principal),
        claim-height: uint,
        voting-end-height: uint
    }
)

(define-map StakerTotalStake
    { staker: principal }
    { total-stake: uint }
)


;; Pool Management Functions
(define-public (create-insurance-pool 
    (name (string-ascii 50))
    (coverage-limit uint)
    (premium-rate uint))
    (let
        ((pool-id (+ (var-get next-pool-id) u1)))

        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        (asserts! (> coverage-limit u0) ERR-INVALID-AMOUNT)
        (asserts! (> premium-rate u0) ERR-INVALID-AMOUNT)

        (map-set InsurancePools
            { pool-id: pool-id }
            {
                name: name,
                status: POOL-ACTIVE,
                total-staked: u0,
                coverage-limit: coverage-limit,
                premium-rate: premium-rate,
                claim-count: u0,
                creation-height: stacks-block-height
            })

        (var-set next-pool-id pool-id)
        (var-set total-pools (+ (var-get total-pools) u1))
        (ok pool-id)))

(define-public (stake-in-pool (pool-id uint) (amount uint))
    (let
        ((pool (unwrap! (map-get? InsurancePools { pool-id: pool-id }) ERR-POOL-NOT-FOUND))
         (current-stake (default-to { amount: u0, rewards: u0, last-reward-height: stacks-block-height }
            (map-get? PoolStakes { pool-id: pool-id, staker: tx-sender })))
         (staker-total (default-to { total-stake: u0 }
            (map-get? StakerTotalStake { staker: tx-sender }))))

        (asserts! (is-eq (get status pool) POOL-ACTIVE) ERR-INVALID-POOL-STATE)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)

        ;; Transfer stake
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

        ;; Update pool stakes
        (map-set PoolStakes
            { pool-id: pool-id, staker: tx-sender }
            {
                amount: (+ (get amount current-stake) amount),
                rewards: (get rewards current-stake),
                last-reward-height: stacks-block-height
            })

        ;; Update total stakes
        (map-set InsurancePools
            { pool-id: pool-id }
            (merge pool {
                total-staked: (+ (get total-staked pool) amount)
            }))

        (map-set StakerTotalStake
            { staker: tx-sender }
            { total-stake: (+ (get total-stake staker-total) amount) })

        (var-set total-staked (+ (var-get total-staked) amount))
        (ok true)))

(define-public (unstake-from-pool (pool-id uint) (amount uint))
    (let
        ((pool (unwrap! (map-get? InsurancePools { pool-id: pool-id }) ERR-POOL-NOT-FOUND))
         (stake (unwrap! (map-get? PoolStakes { pool-id: pool-id, staker: tx-sender }) ERR-UNAUTHORIZED))
         (staker-total (unwrap! (map-get? StakerTotalStake { staker: tx-sender }) ERR-UNAUTHORIZED)))

        (asserts! (is-eq (get status pool) POOL-ACTIVE) ERR-INVALID-POOL-STATE)
        (asserts! (>= (get amount stake) amount) ERR-INSUFFICIENT-BALANCE)

        ;; Transfer stake back
        (as-contract (try! (stx-transfer? amount tx-sender tx-sender)))

        ;; Update pool stakes
        (map-set PoolStakes
            { pool-id: pool-id, staker: tx-sender }
            {
                amount: (- (get amount stake) amount),
                rewards: (get rewards stake),
                last-reward-height: stacks-block-height
            })

        ;; Update total stakes
        (map-set InsurancePools
            { pool-id: pool-id }
            (merge pool {
                total-staked: (- (get total-staked pool) amount)
            }))

        (map-set StakerTotalStake
            { staker: tx-sender }
            { total-stake: (- (get total-stake staker-total) amount) })

        (var-set total-staked (- (var-get total-staked) amount))
        (ok true)))
