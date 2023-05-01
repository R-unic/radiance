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
      when Syntax::Float, Syntax::String, Syntax::None, Syntax::LeftParen
        nodes.push(parse_expression)
      when Syntax::EOF
        break
      else
        logger.report_error("Unexpected token", token.syntax_type, token.position, token.line)
      end
    end

    nodes
  end

  def parse_expression
    left = parse_primary_expression

    while token = @tokens[@position]
      case token.syntax_type
      when Syntax::Plus, Syntax::Minus
        advance
        left = BinaryNode.new(left, token, parse_primary_expression)
      else
        break
      end
    end

    left
  end

  def parse_primary_expression
    token = @tokens[@position]
    case token.syntax_type
    when Syntax::Float, Syntax::String, Syntax::None
      advance
      LiteralNode.new(token)
    when Syntax::LeftParen
      advance
      node = parse_expression
      consume(Syntax::RightParen, "Expected ')'")
      node
    else
      logger.report_error("Unexpected token", token.syntax_type, token.position, token.line)
    end
  end

  def consume(syntax, error_msg)
    token = @tokens[@position]
    if token.syntax_type == syntax
      advance
    else
      logger.report_error(error_msg, token.syntax_type, token.position, token.line)
    end
    token
  end

  def advance
    @position += 1
  end
end
