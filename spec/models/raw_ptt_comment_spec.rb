require 'rails_helper'

RSpec.describe RawPTTComment, type: :model do
  context 'association' do
    it{ should belong_to :raw_ptt_article }
  end

  context 'validation' do
    it{ should validate_presence_of :raw_ptt_article_id }
  end

  context 'callback' do

  end

  context 'scope' do

  end
end
