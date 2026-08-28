# Nameserver cutover contract

- Success returns the Gateway `data`/`meta`/`links` envelope in
  `structuredContent`, plus per-step metadata.
- The update step reporting `replayed` as true: an identical retry was
  answered from the idempotency store — the change ran exactly once.
- `IDEMPOTENCY_KEY_REUSED` (`isError`): the same `workflow_retry_key` was
  sent with different input. Generate a new key only after the user confirms
  the new target; never reuse an old key for a different change.
- A failure after the update step with `mutation_state = "completed"` means
  the change WENT THROUGH and only the final read-back failed. Re-read the
  nameservers before any further action; never re-submit.
- An uncertain outcome (transport loss) is not a safe retry. Retry with the
  SAME key: it observes the stored state instead of repeating the mutation.
- Rollback is a new, separately confirmed cutover back to the nameservers
  recorded in preflight — there is no server-side undo.
