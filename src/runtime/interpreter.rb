require_relative "../code_analysis/parser"

class Interpreter
  def interpret(source)
    parser = Parser.new(source)
    puts parser.parse
  end
end
