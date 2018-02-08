require "braintree"

class BraintreeController < ApplicationController

  def client
    gateway = Braintree::Gateway.new(
      environment: Rails.application.config.braintree_env,
      merchant_id: ENV['BRAINTREE_MERCHANT_ID'],
      public_key:  ENV['BRAINTREE_PUBLIC_KEY'],
      private_key: ENV['BRAINTREE_PRIVATE_KEY']
    )

    customer_id = params[:customer_id] || ''
    customer_params = { customer_id: customer_id }
    @client_token = customer_id ?
      gateway.client_token.generate(customer_params) :
      gateway.client_token.generate

    render json: { client_token: @client_token }
  end
end
