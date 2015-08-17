class Fetcher::PTT < Fetcher::Base
  def initialize(board)
    @board = board
  end

  def new_articles

  end

  private

  def board
    @board.capitalize
  end

  def board_url(page=nil)
    if page
      "https://www.ptt.cc/bbs/#{board}/index#{paeg}.html"
    else
      "https://www.ptt.cc/bbs/#{board}/index.html"
    end
  end
end
