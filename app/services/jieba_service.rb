
class JiebaService
  PATH = {
    content_path: "tmp/content.txt",
    pipe_path: "tmp/jieba_pipe",
    pid_path: "tmp/pids/jieba.pid"
  }.freeze

  def initialize
    @content_path = PATH[:content_path]
    @from_pipe = PATH[:pipe_path]
    @pid_path = PATH[:pid_path]

  end

  def keywords(content)
    init_fd
    write_content(content)
    notify_jieba
    read_keywords
    close_fd
    return @keywords
  end

  protected
  def get_pid
    File.open(@pid_path, "r") do |f|
      @pid = f.read().to_i
    end
  end

  def notify_jieba
    Process.kill("ALRM", get_pid)
  end

  def init_fd
    @content_fd = File.new(@content_path, "w")
    @reader_fd = open(@from_pipe, 'r+')
  end

  def write_content(content)
    @content_fd.flock(File::LOCK_EX)
    @content_fd.write(content)
    @content_fd.flush
  end

  def read_keywords
    @keywords = @reader_fd.gets.strip.split(',')
  end

  def close_fd
    @reader_fd.close
    @content_fd.close
  end
end
