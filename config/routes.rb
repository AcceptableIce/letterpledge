Rails.application.routes.draw do
	root "home#index"

	get "success", to: "home#success"

	get "pledge", to: "home#index"
	post "pledge", to: "home#pledge"

	get "unsubscribe", to: "unsubscribe#index"
	post "unsubscribe", to: "unsubscribe#do_unsubscribe"

	mount StripeEvent::Engine, at: "/hooks"

	get '.well-known/acme-challenge/i1YCWrFVckKvb8xxD8yPupwDSRU8ydD6kaKZOEOol3A' => 'home#letsencrypt'
end
