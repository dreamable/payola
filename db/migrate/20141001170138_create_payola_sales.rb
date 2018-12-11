class CreatePayolaSales < ActiveRecord::Migration[4.2]
  def change
    create_table :payola_sales do |t|
      # refernce 
      t.integer  :owner_id
      t.string   :owner_type, limit: 100
      t.integer  :product_id
      t.string   :product_type,  limit: 100
      t.integer  :coupon_id
      t.integer  :affiliate_id

      # basic
      t.integer  :amount
      t.string   :currency
      t.integer  :fee_amount

      # state
      t.string   :state
      t.text     :error

      # card info
      t.string   :card_last4
      t.date     :card_expiration
      t.string   :card_type

      # email & addr
      t.string   :email,         limit: 191
      t.text     :customer_address
      t.text     :business_address


      # stripe info
      t.string   :guid,          limit: 191
      t.string   :stripe_customer_id, limit: 191
      t.string   :stripe_id
      t.string   :stripe_token
 
      # misc
      t.boolean  :opt_in
      t.integer  :download_count
      t.text     :signed_custom_fields

      t.timestamps
    end

    add_index :payola_sales, [:product_id, :product_type]
    add_index :payola_sales, [:owner_id, :owner_type]
    add_index :payola_sales, [:coupon_id]
    add_index :payola_sales, [:affiliate_id]
    add_index :payola_sales, [:email]
    add_index :payola_sales, [:guid]
    add_index :payola_sales, [:stripe_customer_id]
    add_index :payola_sales, [:stripe_id]
    add_index :payola_sales, [:stripe_token]
  end
end
