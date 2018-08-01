class CreateAtlassianJwtUsers < ActiveRecord::Migration[5.2]
  def self.up
    if table_exists? :jwt_users
      pp 'Skipping jwt_users table creation...'
    else
      create_table :jwt_users do |t|
        t.integer :jwt_token_id
        t.string :account_id
        t.string :display_name
        t.string :user_key
        t.string :name
      end
    end
  end
end