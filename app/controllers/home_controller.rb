class HomeController < ApplicationController
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
				email: @user.email_address
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

	def charge_week

	end

	private

	def user_params
		params.require(:user).permit(:email_address, :pledge, :pledge_limit, :stripe_customer_id)
	end
end
