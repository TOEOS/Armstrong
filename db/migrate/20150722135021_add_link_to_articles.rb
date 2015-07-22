class AddLinkToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :link, :text
  end
end
