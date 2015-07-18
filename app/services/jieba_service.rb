class JiebaService
  def initialize
    @content_file = Settings.jieba.content_path
    @from_pipe = Settings.jieba.pipe_path
    @pid_file = Settings.jieba.pid_path
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
