require 'ostruct'
class JiebaService
  PATH = {
    content_path: "tmp/content.txt",
    pipe_path: "tmp/jieba_pipe",
    pid_path: "tmp/jieba.pid"
  }.freeze

  def initialize
    @content_file = PATH[:content_path]
    @from_pipe = PATH[:pipe_path]
    @pid_file = PATH[:pid_path]
  end

  def keywords(content)
    File.open(@content_file, "w") do |f|
      f.write(content)
    end

    reader = open(@from_pipe, 'r+')
    puts get_pid
    Process.kill("ALRM", get_pid)
    reader.gets.strip.split(',')
  end

  protected
  def get_pid
    File.open(@pid_file, "r") do |f|
      @pid = f.read().to_i
    end
  end
end
