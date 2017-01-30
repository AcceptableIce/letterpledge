class HomeController < ApplicationController
 skip_before_filter :verify_authenticity_token, only: [:charge_week]


	def index
		@user = User.new
	end

	def pledge
		@user = User.new(user_params)

		if params[:limit] == "false"
			@user.pledge_limit = nil
		end 

		if @user.valid?
			customer = Stripe::Customer.create(
				email: @user.email_address,
				source: params[:stripe_token]
			)

			@user.stripe_customer_id = customer.id
			if @user.save
				Stripe::Subscription.create(customer: @user.stripe_customer_id, plan: "tweet_cycle")
				render :success
			else
				render :index
			end
		else
			render :index
		end
	end

	def success
	end

	def unsubscribe
	end

	def do_unsubscribe
		user = User.where(email_address: params[:email_address]).first

		if user != nil
			customer = Stripe::Customer.retrieve(user.stripe_customer_id)

			if params[:last_four_digits] == customer.sources.data[0].last4
				customer.subscriptions.each do |subscription|
					subscription.delete
				end

				render :unsubscribe_success
			else
				flash[:message] = "Last four digits did not match credit card on record."
				render :unsubscribe
			end
		else
			flash[:message] = "No one has pledged under that email address."
			render :unsubscribe
		end
	end


	def charge_week
		logger.debug params.to_s
	end

	private

	def user_params
		params.require(:user).permit(:email_address, :pledge, :pledge_limit, :stripe_customer_id)
	end
end
