class UpdateTwitterIdTypeAgain < ActiveRecord::Migration[5.0]
  def change
		remove_column :tweets, :twitter_id
		add_column :tweets, :twitter_id, :bigint
  end
end
