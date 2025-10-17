# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create_checkout_session, :webhook]
  
    # POST /create-checkout-session
    def create_checkout_session
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      
      price_id = params[:priceId] || 'price_1SATZaIoRaH50WhR5sShQueN' # <-- use your price id
      # Optionally accept customer_email: params[:customerEmail]
  
      session = Stripe::Checkout::Session.create(
        mode: 'subscription',
        payment_method_types: ['card'],
        line_items: [{ price: price_id, quantity: 1 }],
        allow_promotion_codes: true,
        success_url: "#{ENV['BASE_URL']}/success.html?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "#{ENV['BASE_URL']}/cancel.html"
      )
  
      render json: { id: session.id, url: session.url }
    rescue => e
      Rails.logger.error("Stripe session create error: #{e.message}")
      render json: { error: e.message }, status: 500
    end
  
    # POST /webhook
    # raw body required to verify signature
    def webhook
      payload = request.raw_post
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']
  
      event = nil
      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError => e
        render plain: "Invalid payload", status: 400 and return
      rescue Stripe::SignatureVerificationError => e
        Rails.logger.warn("Webhook signature verification failed: #{e.message}")
        render plain: "Signature verification failed", status: 400 and return
      end
  
      case event['type']
      when 'checkout.session.completed'
        session = event['data']['object']
        # You should lookup your user (by email or metadata) and mark subscription active.
        Rails.logger.info("Checkout completed: #{session['id']}")
        # TODO: save session['subscription'], session['customer'], session['customer_email'] to DB
      when 'invoice.payment_succeeded'
        Rails.logger.info("Invoice paid: #{event['data']['object']['id']}")
      when 'invoice.payment_failed'
        Rails.logger.info("Invoice failed: #{event['data']['object']['id']}")
      else
        Rails.logger.info("Unhandled event: #{event['type']}")
      end
  
      render json: { received: true }
    end

    # Serve the static success page
    def success
      render file: Rails.root.join('public', 'success.html'), layout: false
    end

    # Serve the static cancel page
    def cancel
      render file: Rails.root.join('public', 'cancel.html'), layout: false
    end
  end
  