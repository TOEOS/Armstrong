class AddTagIdToRawPTTArticles < ActiveRecord::Migration
  def change
    add_reference :raw_ptt_articles, :ptt_tag, index: true, foreign_key: true
  end
end
