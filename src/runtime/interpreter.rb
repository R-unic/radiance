require "benchmark"
require_relative "../code_analysis/parser"

class Interpreter
  def interpret(source)
    time = Benchmark.realtime do
      parser = Parser.new(source)
      puts parser.parse
    end
    puts "Parsing took #{(time * 1000).round}ms"
  end
end
