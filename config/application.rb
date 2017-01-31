require_relative 'boot'

require 'rails/all'
require 'stripe'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ENV["RAILS_LOG_TO_STDOUT"].present?
	Rails.logger = Logger.new(STDOUT)
end

module Letterpledge
  class Application < Rails::Application
  end
end
