class HomeController < ApplicationController
 skip_before_action :verify_authenticity_token, only: [:charge_week]


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
				begin
					Stripe::Subscription.create(customer: @user.stripe_customer_id, plan: "LPTest")
					render :success
				rescue Stripe::CardError => e
					@user.errors.add(:base, e.message.to_s)

					@user.destroy
					customer.delete

					render :index
				end
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


	def test
		event_invoice = Struct.new(:id, :closed, :paid, :period_start, :period_end, :customer)
			.new("sub_A20ZRXGQrUkzm9", false, false, 1485721972, 1486336772, "cus_A1Ux72SWJZfhxY")
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

					render plain: "#{full_tweets} full-length tweets at #{user.pledge} cents each."
				end
			end
		end
	
		render plain: "other path"
	end

	private

	def user_params
		params.require(:user).permit(:email_address, :pledge, :pledge_limit, :stripe_customer_id)
	end
end
