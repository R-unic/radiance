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
      case token.syntax_type
      when Syntax::Float, Syntax::String, Syntax::None
        nodes.push(LiteralNode.new(token))
      when Syntax::EOF
        break
      else
        puts token
        logger.report_error("Unexpected token", token.syntax_type, token.position, token.line)
      end
      @position += 1
    end

    nodes
  end
end
