class UnsubscribeController < ApplicationController
	def index
	end

	def do_unsubscribe
		user = User.where(email_address: params[:email_address]).first

		if user != nil
			customer = Stripe::Customer.retrieve(user.stripe_customer_id)

			if customer.sources.data.length > 0 && params[:last_four_digits] == customer.sources.data[0].last4
				customer.subscriptions.each do |subscription|
					subscription.delete
				end

				customer.delete
				user.destroy

				render :success
			else
				flash[:message] = "Last four digits did not match credit card on record."
				render :index
			end
		else
			flash[:message] = "No one has pledged under that email address."
			render :index
		end
	end
end
