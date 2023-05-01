class Logger
  attr_accessor :errored

  def initialize
    @errored = false
  end

  def report_error(error_type, message, pos, line)
    puts "[#{line}:#{pos + 1}] #{error_type}: #{message}"
    @errored = true
  end
end
