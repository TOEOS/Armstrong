class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.integer :event_id
      t.string :title
      t.string :arthor
      t.timestamp :post_at
      t.text :content
      t.integer :comment_counter
    end
  end
end
