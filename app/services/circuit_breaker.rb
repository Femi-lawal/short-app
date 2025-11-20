# frozen_string_literal: true

# ==============================================================================
# Circuit Breaker Implementation
# Demonstrates: Senior Backend - Resilience patterns
# ==============================================================================

class CircuitBreaker
  def initialize(failure_threshold:, recovery_timeout:)
    @failure_threshold = failure_threshold
    @recovery_timeout = recovery_timeout
    @failures = 0
    @last_failure_time = nil
    @state = :closed
    @mutex = Mutex.new
  end

  def allow_request?
    @mutex.synchronize do
      case @state
      when :closed
        true
      when :open
        if Time.current - @last_failure_time >= @recovery_timeout
          @state = :half_open
          true
        else
          false
        end
      when :half_open
        true
      end
    end
  end

  def record_success
    @mutex.synchronize do
      @failures = 0
      @state = :closed
    end
  end

  def record_failure
    @mutex.synchronize do
      @failures += 1
      @last_failure_time = Time.current

      if @failures >= @failure_threshold
        @state = :open
        Rails.logger.warn("Circuit breaker opened after #{@failures} failures")
      end
    end
  end

  def state
    @state
  end

  def reset!
    @mutex.synchronize do
      @failures = 0
      @last_failure_time = nil
      @state = :closed
    end
  end
end
