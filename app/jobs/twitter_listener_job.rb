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

		trump_id = '25073877'

		client.filter({follow: trump_id}) do |object|
			if object.is_a?(Twitter::Tweet)
				if object.user.id == trump_id
					existing_tweet = Tweet.find_by(twitter_id: object.id)
					if not existing_tweet
						logger.info 'Got a new Trump tweet:'
						logger.info YAML::dump(object)
						new_tweet = Tweet.create(
							text: object.text,
							length: object.text.length,
							date: DateTime.now,
							twitter_id: object.id
						)
					else
						logger.info 'Got a dupe Trump tweet'
					end
				end
			end
		end

	end
end

TwitterListenerJob.perform_later