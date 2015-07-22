class RenameCommentCounterToCommentsCount < ActiveRecord::Migration
  def change
    rename_column :articles, :comment_counter, :comments_count
  end
end
