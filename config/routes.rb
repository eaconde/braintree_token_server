Rails.application.routes.draw do
  root :to => 'welcome#index'

  get "client" => "braintree#client"
  post "transact" => "braintree#transact"

end
