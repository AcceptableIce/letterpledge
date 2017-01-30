Rails.configuration.stripe = {
    :publishable_key => Rails.application.secrets.stripe_publishable_key,
    :secret_key      => Rails.application.secrets.stripe_secret_key
}

Stripe.api_key = Rails.application.secrets.stripe_secret_key

StripeEvent.configure do |events|
	events.subscribe "invoice.created" do |event|
		Rails.logger.debug event.type
		Rails.logger.debug event.object.to_s
	end
end