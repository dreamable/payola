class CreatePayolaSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :payola_subscriptions do |t|
      # reference
      t.string    :plan_type
      t.integer   :plan_id
      t.string    :owner_type
      t.integer   :owner_id
      t.inteber   :affiliate_id

      # basic info
      t.integer   :quantity
      t.integer   :amount
      t.string    :currency 

      # date
      t.timestamp :start
      t.timestamp :ended_at
      t.timestamp :current_period_start
      t.timestamp :current_period_end
      t.timestamp :trial_start
      t.timestamp :trial_end
      t.boolean   :cancel_at_period_end
      t.timestamp :canceled_at
 
      # status
      t.text      :error
      t.string    :state
      t.string    :status

      # card info
      t.string    :card_last4
      t.date      :card_expiration
      t.string    :card_type
     
      # email & addrss
      t.string    :email
      t.text      :customer_address
      t.text      :business_address

      # stripe related
      t.string    :guid, limit : 191
      t.string    :stripe_customer_id
      t.string    :stripe_id
      t.string    :stripe_token
      t.string    :stripe_status

      # misc
      t.string    :coupon 
      t.integer   :setup_fee
      t.decimal   :tax_percent, precision : 4, scale : 2
      t.text      :signed_custom_fields

      t.timestamps
    end

    add_index :payola_subscriptions, [:plan_id, :plan_type]
    add_index :payola_subscriptions, [:owner_id, :owner_type]
    add_index :payola_subscriptions, [:affiliate_id]
    add_index :payola_subscriptions, :guid
    add_index :payola_subscriptions, [:stripe_customer_id]
    add_index :payola_subscriptions, [:stripe_id]
    add_index :payola_subscriptions, [:stripe_token]
  end
end
