require "sidekiq"
require "sentry-ruby"
require "sentry/integrable"
require "sentry/sidekiq/version"
require "sentry/sidekiq/error_handler"
require "sentry/sidekiq/sentry_context_middleware"

module Sentry
  module Sidekiq
    extend Sentry::Integrable

    register_integration name: "sidekiq", version: Sentry::Sidekiq::VERSION

    if defined?(::Rails)
      class Railtie < ::Rails::Railtie
        config.after_initialize do
          next unless Sentry.initialized?

          Sentry.configuration.rails.ignored_active_job_adapters << "ActiveJob::QueueAdapters::SidekiqAdapter"
        end
      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.error_handlers << Sentry::Sidekiq::ErrorHandler.new
  config.server_middleware do |chain|
    chain.add Sentry::Sidekiq::SentryContextMiddleware
  end
end

