require 'rails_helper'

RSpec.describe RawPTTArticle, type: :model do
  context 'association' do
    it{ should belong_to :ptt_tag }
  end

  context 'validation' do
    it{ should validate_presence_of(:url) }
  end

  context 'callback' do
  end

  context 'scope' do
  end
end
