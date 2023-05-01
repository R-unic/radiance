class Logger
  attr_accessor :errored

  def initialize
    @errored = false
  end

  def report_error(error_type, message, pos, line)
    $stderr.puts "[#{line}:#{pos + 1}] #{error_type}: #{message}"
    @errored = true
    exit(1)
  end
end
