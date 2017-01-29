class CreateUsersTable < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
			t.string :email_address, null: false
			t.string :stripe_customer_id
			t.integer :pledge, null: false
			t.integer :pledge_limit
			t.timestamps
    end
  end
end
