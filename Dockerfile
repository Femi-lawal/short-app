# syntax=docker/dockerfile:1
# ==============================================================================
# Multi-stage Dockerfile for Short-App URL Shortener
# Demonstrates: Senior DevOps - Optimized container builds
# ==============================================================================

# ==============================================================================
# Stage 1: Base image with system dependencies
# ==============================================================================
FROM ruby:3.2.2-slim AS base

# Set environment variables
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    LANG=C.UTF-8 \
    TZ=UTC

# Install base system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    curl \
    libmariadb3 \
    libvips42 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Create non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# ==============================================================================
# Stage 2: Build stage - Install gems and precompile assets
# ==============================================================================
FROM base AS builder

# Install build dependencies (needed for native gems)
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libmariadb-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems first (cacheable layer)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets (if using asset pipeline)
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# ==============================================================================
# Stage 3: Production runtime image
# ==============================================================================
FROM base AS production

WORKDIR /app

# Copy built artifacts from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Set correct ownership
RUN chown -R rails:rails /app db log storage tmp

# Switch to non-root user
USER rails:rails

# Expose port
EXPOSE 3000

# Health check for container orchestrators
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Default entrypoint
ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]

# ==============================================================================
# Stage 4: Development image (optional, for local dev)
# ==============================================================================
FROM base AS development

# Install dev dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libmariadb-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=development \
    BUNDLE_DEPLOYMENT=0 \
    BUNDLE_WITHOUT=""

WORKDIR /app

# Install bundler
RUN gem install bundler

# Used for development - source mounted as volume
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
