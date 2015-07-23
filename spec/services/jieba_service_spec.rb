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
      post1 = File.read(Rails.root.join('spec', 'fixtures', 'posts', 'post_01.txt'))
      expect(JiebaService.new.keywords(post1)).to match_array(["PPM", "不是", "人工", "其實", "台灣", "成本", "機器", "櫻桃", "水果", "農藥"])

      post2 = File.read(Rails.root.join('spec', 'fixtures', 'posts', 'post_02.txt'))
      expect(JiebaService.new.keywords(post2)).to match_array(["弊案", "掏空", "立委", "董事", "議員", "議會", "議長", "賄選", "超貸", "農會"])
    end
  end
end
