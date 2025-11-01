# Contributing to Short-App

## Development Setup

```bash
# Clone the repository
git clone https://github.com/femi-lawal/short-app.git
cd short-app

# Start development environment
docker compose up -d

# Run migrations
docker compose exec app bin/rails db:migrate

# Verify
curl http://localhost:3000/health
```

## Running Tests

```bash
# RSpec tests
docker compose exec app bundle exec rspec

# E2E tests
cd e2e && npm install && npm test
```

## Code Standards

- Follow Ruby style guide
- Write specs for new features
- Keep services under 100 lines
- Use conventional commits

## Pull Request Process

1. Create a feature branch
2. Write tests
3. Run linter: `bundle exec rubocop`
4. Open PR with description
5. Wait for CI to pass

## Commit Message Format

```
type(scope): description

feat(api): add stats endpoint
fix(redirect): handle expired URLs
docs(readme): update installation steps
```
