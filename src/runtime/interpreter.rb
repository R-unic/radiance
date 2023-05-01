require_relative "../code_analysis/lexer"

class Interpreter
  def interpret(source)
    lexer = Lexer.new(source)
    puts lexer.tokenize
  end
end
