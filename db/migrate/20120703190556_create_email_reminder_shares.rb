class CreateEmailReminderShares < ActiveRecord::Migration[4.2]
  def change
    create_table :email_reminder_shares do |t|
      t.references :reminder, :null => false
      t.string :email_address, :null => false
      t.string :name, :null => false
      t.string :state, :null => false, :limit => 16, :default => :pending
      t.string :auth_code, :null => false, :limit => 128

      t.timestamps
    end

    add_index :email_reminder_shares, :reminder_id
    add_index :email_reminder_shares, :auth_code
    add_index :email_reminder_shares, [:reminder_id, :email_address], :unique => true
  end
end
