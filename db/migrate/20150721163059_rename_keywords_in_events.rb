class RenameKeywordsInEvents < ActiveRecord::Migration
  def change
    rename_column :events, :key_words, :keywords
  end
end
