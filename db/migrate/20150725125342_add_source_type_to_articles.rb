class AddSourceTypeToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :source_type, :string
  end
end
