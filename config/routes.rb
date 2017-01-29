Rails.application.routes.draw do
	root "home#index"

	post "pledge", to: "home#pledge"

end
