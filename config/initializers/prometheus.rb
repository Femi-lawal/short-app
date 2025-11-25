# frozen_string_literal: true

# AppMetrics - Simple metrics collection
module AppMetrics
  @data = { counters: {}, gauges: {} }
  @mutex = Mutex.new

  class << self
    def counter(name, value = 1)
      @mutex.synchronize do
        @data[:counters][name] ||= 0
        @data[:counters][name] += value
      end
    end

    def gauge(name, value)
      @mutex.synchronize do
        @data[:gauges][name] = value
      end
    end

    def to_prometheus_format
      lines = ["# Short-App Metrics\n"]
      
      @mutex.synchronize do
        @data[:counters].each do |name, value|
          lines << "# TYPE #{name} counter"
          lines << "#{name} #{value}"
        end
        @data[:gauges].each do |name, value|
          lines << "# TYPE #{name} gauge"
          lines << "#{name} #{value}"
        end
      end
      
      lines << "# TYPE http_requests_total counter"
      lines << "http_requests_total 0"
      lines.join("\n")
    end
  end
end
