require "braintree"

class BraintreeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :transact
  before_action :gateway

  def client
    customer_id = params[:customer_id] || ''
    customer_params = { customer_id: customer_id }
    @client_token = customer_id != '' ?
      @gateway.client_token.generate(customer_params) :
      @gateway.client_token.generate

    render json: { client_token: @client_token }
  end

  def transact
    unit_price = "1.00"

    result = @gateway.transaction.sale(
      :amount => unit_price,
      :payment_method_nonce => params[:nonce],
      :options => {
        :submit_for_settlement => true
      }
    )

    if result.success?
      # See result.transaction for details
      p "result.transaction :: #{result.transaction.inspect}"
      # store SOME info from transaction to the DB as per req
      # result.transaction :: #<Braintree::Transaction
      # id: \"cdk0ewqg\",
      # type: \"sale\",
      # amount: \"1.0\",
      # status: \"submitted_for_settlement\",
      # created_at: 2018-02-14 04:07:12 UTC,
      # credit_card_details: #<token: nil,
      #   bin: nil,
      #   last_4: nil,
      #   card_type: nil,
      #   expiration_date: \"/\",
      #   cardholder_name: nil,
      #   customer_location: nil,
      #   prepaid: \"Unknown\",
      #   healthcare: \"Unknown\",
      #   durbin_regulated: \"Unknown\",
      #   debit: \"Unknown\",
      #   commercial: \"Unknown\",
      #   payroll: \"Unknown\",
      #   product_id: \"Unknown\",
      #   country_of_issuance: \"Unknown\",
      #   issuing_bank: \"Unknown\",
      #   image_url: \"https://assets.braintreegateway.com/payment_method_logo/unknown.png?environment=sandbox\",
      #   unique_number_identifier: nil>,
      # customer_details: #<id: nil,
      #   first_name: nil,
      #   last_name: nil,
      #   email: nil,
      #   company: nil,
      #   website: nil,
      #   phone: nil,
      #   fax: nil>,
      # subscription_details: #<Braintree::Transaction::SubscriptionDetails:0x007feb4140c908
      #   @billing_period_end_date=nil,
      #   @billing_period_start_date=nil>,
      # updated_at: 2018-02-14 04:07:12 UTC>
      render json: { message: "Successfully processed subscription.", success: true }
    else
      # Handle errors
      p "result.errors :: #{result.errors.inspect}"
      render json: { message: result.errors.message, success: false }
    end
  end

  private

  def gateway
    @gateway = Braintree::Gateway.new(
      environment: Rails.application.config.braintree_env,
      merchant_id: ENV['BRAINTREE_MERCHANT_ID'],
      public_key:  ENV['BRAINTREE_PUBLIC_KEY'],
      private_key: ENV['BRAINTREE_PRIVATE_KEY']
    )
  end
end
