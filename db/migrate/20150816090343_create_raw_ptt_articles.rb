class CreateRawPTTArticles < ActiveRecord::Migration
  def change
    create_table :raw_ptt_articles do |t|
      t.string :url
      t.string :title
      t.boolean :is_re
      t.string :author
      t.datetime :date
      t.text :content
      t.text :signature_line
      t.inet :author_ip

      t.timestamps null: false
    end
  end
end
