(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-SCORE (err u101))
(define-constant ERR-ALREADY-REVIEWED (err u102))
(define-constant ERR-PAPER-NOT-FOUND (err u103))
(define-constant ERR-NOT-VERIFIED (err u104))

(define-data-var admin principal tx-sender)

(define-map verified-researchers 
  principal 
  {institution: (string-ascii 64), verified-at: uint}
)

(define-map research-papers
  uint
  {
    author: principal,
    title: (string-ascii 128),
    ipfs-hash: (string-ascii 64),
    created-at: uint,
    total-score: uint,
    review-count: uint
  }
)

(define-map paper-reviews
  {paper-id: uint, reviewer: principal}
  {
    score: uint,
    review-hash: (string-ascii 64),
    timestamp: uint
  }
)

(define-map institution-funding
  {paper-id: uint, institution: principal}
  {
    amount: uint,
    funded-at: uint
  }
)

(define-data-var paper-id-nonce uint u0)

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))
  )
)

(define-public (verify-researcher (researcher principal) (institution (string-ascii 64)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (ok (map-set verified-researchers researcher {
      institution: institution,
      verified-at: burn-block-height
    }))
  )
)

(define-public (publish-paper (title (string-ascii 128)) (ipfs-hash (string-ascii 64)))
  (let ((researcher-data (map-get? verified-researchers tx-sender))
        (new-id (+ (var-get paper-id-nonce) u1)))
    (asserts! (is-some researcher-data) ERR-NOT-VERIFIED)
    (var-set paper-id-nonce new-id)
    (ok (map-set research-papers new-id {
      author: tx-sender,
      title: title,
      ipfs-hash: ipfs-hash,
      created-at: burn-block-height,
      total-score: u0,
      review-count: u0
    }))
  )
)

(define-public (submit-review (paper-id uint) (score uint) (review-hash (string-ascii 64)))
  (let ((paper (map-get? research-papers paper-id))
        (reviewer-data (map-get? verified-researchers tx-sender))
        (existing-review (map-get? paper-reviews {paper-id: paper-id, reviewer: tx-sender})))
    (asserts! (is-some paper) ERR-PAPER-NOT-FOUND)
    (asserts! (is-some reviewer-data) ERR-NOT-VERIFIED)
    (asserts! (is-none existing-review) ERR-ALREADY-REVIEWED)
    (asserts! (and (>= score u0) (<= score u100)) ERR-INVALID-SCORE)
    (map-set paper-reviews {paper-id: paper-id, reviewer: tx-sender} {
      score: score,
      review-hash: review-hash,
      timestamp: burn-block-height
    })
    (map-set research-papers paper-id 
      (merge (unwrap-panic paper)
        {
          total-score: (+ (get total-score (unwrap-panic paper)) score),
          review-count: (+ (get review-count (unwrap-panic paper)) u1)
        }
      )
    )
    (ok true)
  )
)

(define-public (fund-research (paper-id uint) (amount uint))
  (let ((paper (map-get? research-papers paper-id)))
    (asserts! (is-some paper) ERR-PAPER-NOT-FOUND)
    (try! (stx-transfer? amount tx-sender (get author (unwrap-panic paper))))
    (ok (map-set institution-funding 
      {paper-id: paper-id, institution: tx-sender}
      {amount: amount, funded-at: burn-block-height}
    ))
  )
)

(define-read-only (get-paper-details (paper-id uint))
  (ok (map-get? research-papers paper-id))
)

(define-read-only (get-paper-score (paper-id uint))
  (match (map-get? research-papers paper-id)
    paper (ok (/ (get total-score paper) (get review-count paper)))
    (err ERR-PAPER-NOT-FOUND)
  )
)

(define-read-only (is-verified-researcher (address principal))
  (is-some (map-get? verified-researchers address))
)