class PTTTag < ActiveRecord::Base
  # default scope

  # constant

  # attr macros

  # association macros
  has_many :raw_ptt_articles

  # validation macros
  validates :url, presence: true

  # callback macros

  # other macros

  # scope macros
end
