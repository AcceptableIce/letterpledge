require 'tweetstream'

class TwitterListenerJob < ApplicationJob
	queue_as :default

	def perform(*args)
		# Do something later
		logger.debug 'hi'
		TweetStream.configure do |config|
			config.consumer_key			= Rails.application.secrets.twitter_consumer_key,
			config.consumer_secret		= Rails.application.secrets.twitter_consumer_secret,
			config.oauth_token			= Rails.application.secrets.twitter_oauth_token,
			config.oauth_token_secret	= Rails.application.secrets.twitter_oauth_token_secret,
			config.auth_method			= :oauth
		end

		TweetStream::Client.new.sample do |status|
			
			logger.debug status.text
		end
	end
end

TwitterListenerJob.perform_now()