;; Facility Verification Contract
;; Validates legitimate production sites

(define-data-var admin principal tx-sender)

;; Define facility data structure
(define-map facilities
  { facility-id: (string-ascii 20) }
  {
    owner: principal,
    name: (string-ascii 50),
    location: (string-ascii 100),
    verified: bool,
    timestamp: uint
  }
)

;; Initialize admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)

;; Register a new facility
(define-public (register-facility
    (facility-id (string-ascii 20))
    (name (string-ascii 50))
    (location (string-ascii 100))
  )
  (let
    (
      (facility-data {
        owner: tx-sender,
        name: name,
        location: location,
        verified: false,
        timestamp: block-height
      })
    )
    ;; Check if facility already exists using map-get? instead of map-has?
    (asserts! (is-none (map-get? facilities { facility-id: facility-id })) (err u100))
    (ok (map-set facilities { facility-id: facility-id } facility-data))
  )
)

;; Verify a facility - only admin can verify
(define-public (verify-facility (facility-id (string-ascii 20)))
  (let
    (
      (facility (unwrap! (map-get? facilities { facility-id: facility-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set facilities
          { facility-id: facility-id }
          (merge facility { verified: true })))
  )
)

;; Get facility details
(define-read-only (get-facility (facility-id (string-ascii 20)))
  (map-get? facilities { facility-id: facility-id })
)

;; Check if facility is verified
(define-read-only (is-facility-verified (facility-id (string-ascii 20)))
  (default-to false
    (get verified (map-get? facilities { facility-id: facility-id })))
)
