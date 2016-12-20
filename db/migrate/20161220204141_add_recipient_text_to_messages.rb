class AddRecipientTextToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :recipient_text, :string
  end
end
