require_relative 'boot'

require 'rails/all'
require 'stripe'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Rails.logger = Logger.new(STDOUT)

module Letterpledge
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq
  end
end
