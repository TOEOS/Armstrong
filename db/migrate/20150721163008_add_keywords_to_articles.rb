class AddKeywordsToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :keywords, :text
  end
end
