class AddSenderTextToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sender_text, :string
  end
end
