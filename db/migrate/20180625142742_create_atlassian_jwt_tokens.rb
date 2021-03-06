class CreateAtlassianJwtTokens < ActiveRecord::Migration[5.2]
  def self.up
    if table_exists? :jwt_tokens
      pp 'Skipping jwt_tokens table creation...'
    else
      create_table :jwt_tokens do |t|
        t.string :addon_key
        t.string :client_key
        t.string :shared_secret
        t.string :oauth_client_id
        t.string :product_type
        t.string :base_url
        t.string :api_base_url
      end

      add_index(:jwt_tokens, :client_key)
    end
  end
end