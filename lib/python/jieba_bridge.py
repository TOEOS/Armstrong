import signal, os, time, sys
import jieba
import jieba.analyse

PID_PATH = "tmp/pids/jieba.pid"

class JiebaBridge(object):
    CONTENT_PATH = "tmp/content.txt"
    PIPE_PATH = "tmp/jieba_pipe"
    def __init__(self, prefix):
        self.tfidf = jieba.analyse.TFIDF(prefix + '/idf.txt.big')
        self._init_pipe()


    def keywords(self, content, topK=10):
        return self.tfidf.extract_tags(content, topK)

    def sig_handler(self, signum, frame):
        try:
            self.read_content()
            tags = self.keywords(self.content, topK=10)
            self.write_keywords(",".join(tags)+"\n")
        except:
            print "Unexpected error:", sys.exc_info()[0]

    def read_content(self):
        f = open(JiebaBridge.CONTENT_PATH, 'r')
        self.content = f.read()
        f.close()

    def write_keywords(self, keywords):
        #print(keywords)
        os.write(self.pipeout, keywords.encode('UTF-8'))
        os.fsync(self.pipeout)

    def close(self):
        os.close(self.pipeout)

    def _init_pipe(self):
        try:
            os.mkfifo(JiebaBridge.PIPE_PATH)
        except OSError as e:
            print "errno: " + str(e.errno)
            if e.errno != 17:
                raise e
        self.pipeout = os.open(JiebaBridge.PIPE_PATH, os.O_RDWR)

def write_pid():
    pid = os.getpid()
    #print pid
    f= open(PID_PATH, 'w')
    f.write(str(pid))
    f.close()

if __name__ == '__main__':
    prefix = "."
    if len(sys.argv) >= 2:
        prefix = sys.argv[1]
    print("prefix: " + prefix)
    jieba_bridge = JiebaBridge(prefix)
    signal.signal(signal.SIGALRM, jieba_bridge.sig_handler)
    write_pid()
    while True:
        time.sleep(10)
    jieba_bridge.close()
