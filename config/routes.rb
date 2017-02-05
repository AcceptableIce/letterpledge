Rails.application.routes.draw do
	root "home#index"

	get "success", to: "home#success"

	get "pledge", to: "home#index"
	post "pledge", to: "home#pledge"

	get "unsubscribe", to: "unsubscribe#index"
	post "unsubscribe", to: "unsubscribe#do_unsubscribe"
	
	mount StripeEvent::Engine, at: "/hooks"
end
