class AddPicLinksToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :pic_links, :text
  end
end
