class CreateRawPTTComments < ActiveRecord::Migration
  def change
    create_table :raw_ptt_comments do |t|
      t.integer :comment_type
      t.string :commenter
      t.text :content
      t.datetime :date
      t.belongs_to :raw_ptt_article, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
