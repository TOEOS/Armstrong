require "rails_helper"
require "rake"

describe 'JiebaService' do
  before(:all) do
    load File.join(Rails.root, 'Rakefile')
    Rake::Task['jieba:start'].execute
    sleep 3
  end
  after(:all) do
    Rake::Task['jieba:stop'].execute
  end
  describe "#keywords" do
    it "returns keywords of the post" do
      post = File.read(Dir[Rails.root.join('spec', 'fixtures', 'posts', '*')].sample)
      expect(JiebaService.new.keywords(post)).to match_array(["PPM", "不是", "人工", "其實", "台灣", "成本", "機器", "櫻桃", "水果", "農藥"])
    end
  end
end
