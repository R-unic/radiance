require_relative "logger"
require_relative "code_analysis/lexer"

lexer = Lexer.new("const var = 0xf;")
puts lexer.tokenize
