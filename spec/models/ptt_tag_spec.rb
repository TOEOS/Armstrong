require 'rails_helper'

RSpec.describe PTTTag, type: :model do
  context 'association' do
    it{ should have_many :raw_ptt_articles }
  end

  context 'validation' do
    it{ should validate_presence_of :name }
  end

  context 'callback' do

  end

  context 'scope' do

  end
end
