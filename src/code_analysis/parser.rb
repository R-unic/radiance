require_relative "syntax/ast"
require_relative "lexer"
require_relative "../logger"

class Parser
  attr_accessor :position, :tokens, :logger

  def initialize(source)
    lexer = Lexer.new(source)
    @tokens = lexer.tokenize
    @position = 0
    @logger = Logger.new
  end

  def parse
    nodes = []
    while token = @tokens[@position]
      node = case token.syntax_type
      when Syntax::None
      when Syntax::String
      when Syntax::Float
        LiteralNode.new(token)
      else
        logger.report_error("Unexpected token", token.syntax_type, token.position, token.line)
      end
      nodes.push(node)
    end

    @position += 1
    nodes
  end
end
