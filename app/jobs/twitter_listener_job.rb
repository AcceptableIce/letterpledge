require 'twitter'

class TwitterListenerJob < ApplicationJob
	queue_as :default

	def perform(*args)
		# Do something later
		client = Twitter::Streaming::Client.new do |config|
			config.consumer_key			= Rails.application.secrets.twitter_consumer_key
			config.consumer_secret		= Rails.application.secrets.twitter_consumer_secret
			config.access_token			= Rails.application.secrets.twitter_oauth_token
			config.access_token_secret	= Rails.application.secrets.twitter_oauth_token_secret
		end

		client.filter({follow: '25073877'}) do |object|
			if object.is_a?(Twitter::Tweet)
				existing_tweet = Tweet.find_by(twitter_id: object.id)
				if not existing_tweet
					logger.info 'Got a new tweet'
					new_tweet = Tweet.create(
						text: object.text,
						length: object.text.length,
						date: DateTime.now,
						twitter_id: object.id.to_s
					)
				else
					logger.info 'Got a dupe tweet'
				end
			end
		end

	end
end

TwitterListenerJob.perform_now()