class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content ,null: false
      t.integer :user_id, null: false
      t.integer :event_id, null: false
      t.timestamps null: false
    end
    add_index :messages, :user_id
    add_index :messages, :event_id
  end
end
