class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :key_words
    end
  end
end
