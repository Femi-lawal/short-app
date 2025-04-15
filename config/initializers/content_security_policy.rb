# frozen_string_literal: true

# ==============================================================================
# Content Security Policy Configuration
# Demonstrates: Senior Backend - Security hardening
# ==============================================================================

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data, 'https://fonts.gstatic.com'
    policy.img_src     :self, :data, :blob
    policy.object_src  :none
    policy.script_src  :self, :unsafe_inline
    policy.style_src   :self, :unsafe_inline, 'https://fonts.googleapis.com'
    policy.frame_ancestors :self
    policy.form_action :self

    # Allow connections to observability tools in development
    if Rails.env.development?
      policy.connect_src :self, 
                         'http://localhost:*', 
                         'ws://localhost:*',
                         'http://127.0.0.1:*'
    else
      policy.connect_src :self
    end

    # Report CSP violations
    # policy.report_uri '/csp-reports'
  end

  # Generate session nonces for inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report-only mode for testing
  # config.content_security_policy_report_only = true
end
