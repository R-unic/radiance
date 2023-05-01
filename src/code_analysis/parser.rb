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
      when
      Syntax::Float,
      Syntax::String,
      Syntax::Boolean,
      Syntax::None,
      Syntax::Identifier,
      Syntax::LeftParen
        nodes << parse_expression
      when
      Syntax::Plus,
      Syntax::Minus,
      Syntax::Bang
        nodes << parse_primary_expression
      when Syntax::EOF
        break
      else
        nodes << parse_stmt
      end
    end

    nodes
  end

  def parse_stmt
    token = @tokens[@position]
    case token.syntax_type
    when Syntax::If
      parse_if_stmt
    when
    Syntax::Identifier,
    Syntax::Float,
    Syntax::String,
    Syntax::Boolean,
    Syntax::None
      parse_expression_stmt
    else
      logger.report_error("Invalid syntax", token.syntax_type, token.position, token.line)
    end
  end

  def parse_expression_stmt
    expr = parse_expression
    Statement::Expression.new(expr)
  end

  def parse_if_stmt
    advance
    consume(Syntax::LeftParen, "Expected '(' after 'if', got")
    condition = parse_expression
    block = parse_block
    if @tokens[@position].syntax_type == Syntax::Else
      advance
      else_branch = parse_if_stmt
    else
      else_branch = nil
    end
    Statement::If.new(condition, block, else_branch)
  end

  def parse_block
    consume(Syntax::LeftBrace, "Expected '{' to begin block")
    statements = []
    while !finished? && @tokens[@position].syntax_type != Syntax::RightBrace
      statement = parse_stmt
      statements << statement if statement
    end
    consume(Syntax::RightBrace, "Expected '}' to end block")
    Statement::Block.new(statements)
  end

  def parse_expression
    left = parse_primary_expression

    while token = @tokens[@position]
      case token.syntax_type
      when
      Syntax::Plus,
      Syntax::Minus,
      Syntax::Star,
      Syntax::Slash,
      Syntax::Carat,
      Syntax::Percent,
      Syntax::PlusEqual,
      Syntax::MinusEqual,
      Syntax::StarEqual,
      Syntax::SlashEqual,
      Syntax::CaratEqual,
      Syntax::PercentEqual,
      Syntax::Equal,
      Syntax::EqualEqual,
      Syntax::BangEqual,
      Syntax::Less,
      Syntax::Greater,
      Syntax::Ampersand,
      Syntax::Pipe,
      Syntax::Question,
      Syntax::HyphenArrow,
        advance
        advance
        left = Expression::BinaryOp.new(left, token, parse_primary_expression)
      when Syntax::LeftParen
        parse_expression
      when Syntax::RightParen
        left
        break
      when Syntax::EOF
        break
      else
        logger.report_error("Invalid syntax", token.syntax_type, token.position, token.line)
        break
      end
    end

    left
  end

  def parse_function_call_expression(identifier)
    first = advance
    arg_expressions = []
    if !first.nil? && first.syntax_type != Syntax::RightParen
      arg_expressions << first
      current = advance
      while !current.nil? && current.syntax_type != Syntax::RightParen
        if current.syntax_type != Syntax::Comma
          expr = parse_expression
          arg_expressions << expr if expr
        end
        current = advance
      end
    end
    Expression::FunctionCall.new(identifier, arg_expressions)
  end

  def parse_primary_expression
    token = @tokens[@position]
    case token.syntax_type
    when Syntax::Float, Syntax::String, Syntax::Boolean, Syntax::None
      advance
      Expression::Literal.new(token)
    when Syntax::Identifier
      next_token = advance
      if !next_token.nil? && next_token.syntax_type == Syntax::LeftParen
        parse_function_call_expression(token)
      else
        Expression::Literal.new(token)
      end
    when
    Syntax::Plus,
    Syntax::Minus,
    Syntax::Bang
      advance
      Expression::UnaryOp.new(token, parse_primary_expression)
    when Syntax::LeftParen
      advance
      node = parse_expression
      @position -= 2
      consume(Syntax::RightParen, "Expected ')', got")
      node
    when Syntax::EOF
    else
      logger.report_error("Invalid syntax", token.syntax_type, token.position, token.line)
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

  def finished?
    @tokens[@position].nil?
  end

  def peek
    @tokens[@position + 1]
  end

  def advance
    @position += 1
    @tokens[@position]
  end
end
