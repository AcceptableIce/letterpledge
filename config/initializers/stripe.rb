Rails.configuration.stripe = {
    :publishable_key => Rails.application.secrets.stripe_publishable_key,
    :secret_key      => Rails.application.secrets.stripe_secret_key
}

Stripe.api_key = Rails.application.secrets.stripe_secret_key

StripeEvent.configure do |events|
	events.subscribe "invoice.created" do |event|
		event_invoice = event.data.object
		if !(event_invoice.closed && event_invoice.paid && event_invoice.total == 0) 

			# If a new invoice occurs when the previous one is not paid, the old one will be closed.
			# Reopen it so it can get paid!
			if event_invoice.closed and !event_invoice.paid
				event_invoice.closed = false
				event_invoice.save()
			else 
				user = User.where(stripe_customer_id: event_invoice.customer).first

				if user != nil
					period_start = Time.at(event_invoice.period_start).to_datetime
					period_end = Time.at(event_invoice.period_end).to_datetime

					characters = Tweet.where(created_at: period_start..period_end).sum(:length)
					full_tweets = characters / 140

					cost = user.pledge * full_tweets

					Rails.logger.info "Added invoice item for #{user.email_address}: #{full_tweets} tweets @ #{user.pledge * 0.01} ea. = #{cost * 0.01}"

					if user.pledge_limit != nil && cost > user.pledge_limit
						cost = user.pledge_limit
						Rails.logger.info " ↳ Limited to #{user.pledge_limit}"
					end

					Stripe::InvoiceItem.create(
						invoice: event_invoice.id,
						customer: user.stripe_customer_id,
						amount: cost,
						currency: "usd",
						description: "#{full_tweets} full-length tweets at #{user.pledge} cents each."
					)
				end

			end
		end
	end
end