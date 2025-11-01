# ADR 001: Use Base62 Encoding for Short URLs

## Status
Accepted

## Context
We need to generate short, unique codes for URLs. The algorithm must produce short output while avoiding ambiguous characters.

## Decision
Use Base62 encoding (a-z, A-Z, 0-9) with the database ID as input.

## Consequences
- Short, URL-safe codes
- Predictable length growth
- No collision risk (1:1 mapping)
- Reversible for debugging

---

# ADR 002: Use Sidekiq for Background Jobs

## Status
Accepted

## Context
Need async processing for title fetching and analytics.

## Decision
Use Sidekiq with Redis for background job processing.

## Consequences
- High throughput
- Reliable job processing
- Web UI for monitoring
- Requires Redis dependency
