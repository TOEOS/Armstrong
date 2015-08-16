class RawPTTArticle < ActiveRecord::Base
  # default scope

  # constant

  # attr macros

  # association macros
  belongs_to :ptt_tag

  # validation macros
  validates :name, presence: true

  # callback macros

  # other macros

  # scope macros
end
