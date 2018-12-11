Payola.configure do |config|
  ##################################################
  # Must config 
  config.publishable_key = "xxxx"
  config.secret_key = "xxxx"
  StripeEvent.signing_secret = "xxxx"
  # NOTE: Must config support_email, otherwise, use support@example.com
  # NOTE: support_mail must match smtp setting, otherwise, exmail rejects. 
  config.support_email = "support@your_domain.com"

  # default USD. set if otherwise 
  # config.default_currency='usd'

  ##################################################
  # charge_verifier interface 
  # 
  # NOTE: event could be sale or subscription. 
  # NOTE: There are two/more ways to find owner
  #   1. pass user_id in the custom_fields. We do this now.  
  #   2. use event.email.This requires that the payment email must match user email.
  config.charge_verifier = lambda do |event, custom_fields|
    if event.is_a?(Payola::Subscription)
      # Prevent more than one active subscription for a given user
      #if user.subscriptions.active.any?
      #  raise "Error: This user already has an active <plan_class>."
      #end
    else # sale
    end
    # Set owner 
    # Method 1
    user = User.find(custom_fields[:user_id])
    # Method 2
    #user = User.find_by(email: event.email)
    # Set user
    if user
      event.owner = user
      event.save!
    else
      raise "Error: Failed to find user by email #{sub.email}."
    end
  end

  ##################################################
  # subscribe interface 
  # NOTE: For unknown reason, email may fail. So it's better to record these information in system as well.
  #
  # Build-in subscribe and email. 
  # NOTE: Refund randomly break, no error on the Rails log, just no email got. 
  #   receipt:       [ 'payola.sale.finished', 'Payola::ReceiptMailer', :receipt ],
  #   refund:        [ 'charge.refunded',      'Payola::ReceiptMailer', :refund  ],
  #   admin_receipt: [ 'payola.sale.finished', 'Payola::AdminMailer',   :receipt ],
  #   admin_refund:  [ 'payola.sale.refunded', 'Payola::AdminMailer',   :refund  ],
  #   admin_failure: [ 'payola.sale.failed',   'Payola::AdminMailer',   :failure ],
  #   admin_dispute: [ 'dispute.created',      'Payola::AdminMailer',   :dispute ],
  config.pdf_receipt = true
  config.send_email_for :receipt, :refund, :admin_receipt, :admin_refund, :admin_dispute, :admin_failure

  # 
  # You can customize it, e.g. 
  #   config.subscribe 'payola.package.sale.finished' do |sale|
  #     EmailSender.send_an_email(sale.email)
  #   end
  # 
  # The events you can subscribe includes strip standard evenvts and payola events. 
  # 
  # The list of strip events is on https://stripe.com/docs/api/events/types?lang=ruby
  # The StripeEvent gem is used for event processing. 
  # 
  # Payold added speical events. 
  #   a. Sale-related events: Each one of these events passes the related Sale instance instead of a Stripe::Event.
  #     Events for general sale class
  #       payola.sale.finished, when a sale completes successfully
  #       payola.sale.failed, when a charge fails
  #       payola.sale.refunded, when a charge is refunded
  #     Events for specific sale class
  #       payola.<sellable class>.sale.finished
  #       payola.<sellable class>.sale.refunded
  #       payola.<sellable class>.sale.failed
  #   b. Subscription-related events: Each one of these events passes the related Subscription instance instead of a Stripe::Event. 
  #     Events for general sale class
  #       payola.subscription.active
  #       payola.subscription.canceled
  #       payola.subscription.failed
  #       payola.subscription.refunded
  #     Events for specific sale class
  #       payola.<plan_class>.subscription.active
  #       payola.<plan_class>.subscription.canceled
  #       payola.<plan_class>.subscription.failed
  #       payola.<plan_class>.subscription.refunded


  #-------------------------------------------------------
  # Payola events, get Sale/Subscription 

#  # The default behavior is to send email both support_email and customers.
#  config.subscribe('payola.sale.finished') do |sale| 
#    Rails.logger.debug("==== Enter payola.sale.finished at #{Time.now()} ====");
#    # Add your action here. 
#    Rails.logger.debug("==== Leave payola.sale.finished at #{Time.now()} ====");
#  end 

  #-------------------------------------------------------
  # Strip standard events, get an StipeEvent::Event instance. 
 
  # Keep this subscription unless you want to disable refund handling
  config.subscribe 'charge.refunded' do |event|
    sale = Payola::Sale.find_by(stripe_id: event.data.object.id)
    sale.refund! unless sale.refunded?
  end

#  config.subscribe 'charge.succeeded' do |event|
#    Rails.logger.debug("==== Enter charge.succeeded at #{Time.now()} ====");
#    # Add you action here
#    Rails.logger.debug("==== Leave charge.charge.succeeded at #{Time.now()} ====");
#  end


#  # Send create subscription email
#  # The input is Event, not sale or subscription
#  config.subscribe("customer.subscription.created") do |event|
#    Rails.logger.debug("==== Enter customer.subscription.created at #{Time.now()} ====");
#    Rails.logger.debug("====   event = #{event.inspect} ====") 
#    s = Payola::Subscription.find_by(stripe_id: event.data.object.id)
#    # Add your action here.
#    Rails.logger.debug("==== Leave customer.subscription.created at #{Time.now()} ====");
#  end
#
#  # TODO: similar for updates
#  config.subscribe("customer.subscription.updated") do |event|
#    Rails.logger.debug("==== Enter customer.subscription.updated at #{Time.now()} ====");
#    subscription = Payola::Subscription.find_by(stripe_id: event.data.object.id)
#    if event.as_json.dig("data", "previous_attributes").key?("items")
#      # Send upgrade subscription email
#      # old_amount = event.as_json.dig("data", "previous_attributes", "items", "data").first.dig("plan").fetch("amount")
#      # SaleMailer.upgrade_<plan_class>_email(old_amount, subscription.id).deliver
#    else
#      # Send cancel subscription email
#      # SaleMailer.cancel_<plan_class>_email(subscription.id).deliver
#    end
#    Rails.logger.debug("==== Leave customer.subscription.updated at #{Time.now()} ====");
#  end

  # called when a subscription is cancelled. 
  # update canceled_at field of the subscription 
  config.subscribe("customer.subscription.deleted") do |event|
    subscription = Payola::Subscription.find_by(stripe_id: event.data.object.id)
    subscription.canceled_at = Time.now()
    subscription.save 
  end
end

# List all Stripe Events. 
#StripeEvent.configure do |events| 
#  events.all do |event| 
#    Rails.logger.debug("==== I got event with type = #{event.type}, id = #{event.data.object.id} ====")
#  end
#end 
