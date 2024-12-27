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
