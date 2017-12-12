Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  resources :registrations

  resources :contact_details_forms,
            only: [:new, :create],
            path: "contact-details",
            path_names: { new: "/:id" }

  resources :renewal_start_forms,
            only: [:new, :create],
            path: "renew",
            path_names: { new: "/:reg_identifier" }

  resources :business_type_forms,
            only: [:new, :create],
            path: "business-type",
            path_names: { new: "/:reg_identifier" }

  resources :smart_answers_forms,
            only: [:new, :create],
            path: "smart-answers",
            path_names: { new: "/:reg_identifier" }

  root "registrations#index"
end
