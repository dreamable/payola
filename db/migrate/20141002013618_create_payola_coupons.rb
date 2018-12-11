class CreatePayolaCoupons < ActiveRecord::Migration[4.2]
  def change
    create_table :payola_coupons do |t|
      t.string :code
      t.integer :percent_off
      t.boolean :active, default: true 

      t.timestamps
    end
  end
end
