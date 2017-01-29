Rails.application.routes.draw do
	root "home#index"

	get "success", to: "home#success"

	get "pledge", to: "home#index"
	post "pledge", to: "home#pledge"

	get "unsubscribe", to: "home#unsubscribe"
	post "unsubscribe", to: "home#do_unsubscribe"

	post "charge_week", to: "home#charge_week"
end
