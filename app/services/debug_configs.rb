module DebugConfigs
  LOG_DEBUG_MSG = true

  class << self
    def extended(base)
      base.include(self)
    end
  end

  def debug(msg, output_strategy = :puts)
    send(output_strategy, "#{Process.pid}: #{msg}") if LOG_DEBUG_MSG
  end
end
