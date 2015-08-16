class CreatePTTTags < ActiveRecord::Migration
  def change
    create_table :ptt_tags do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
