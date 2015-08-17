class RawPTTComment < ActiveRecord::Base
  # default scope

  # constant

  # attr macros

  # association macros
  belongs_to :raw_ptt_article

  # validation macros
  validates :raw_ptt_article_id, presence: true

  # callback macros

  # other macros

  # scope macros
end
