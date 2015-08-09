class Fetcher::PTT < Fetcher::Base
  def initialize(board)
    @board = board
  end

  def new_articles

  end

  def articles_by_page(number)

  end

  def articles_until(date)

  end

  def articles(number)

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
