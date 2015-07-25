class AddCommentedAtToComments < ActiveRecord::Migration
  def change
    add_column :comments, :commented_at, :datetime
  end
end
