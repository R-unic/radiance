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
      when Syntax::LeftBrace
        nodes << parse_block
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
    when Syntax::Function
      identifier = advance
      advance
      arg_expressions = parse_def_args
      consume(Syntax::RightParen, "Expected ')' after function arguments, got")
      block = parse_block
      if block.statements.count { |s| s.is_a?(Statement::Return) } > 1
        logger.report_error("Function with multiple returns", identifier.value, identifier.position, identifier.line)
      end
      if block.statements.last.is_a?(Statement::Return)
        returns = block.statements.pop.expression
      else
        returns = block.statements.pop
      end
      Statement::Function.new(identifier, arg_expressions, block, returns)
    when Syntax::Return
      parse_return_stmt
    else
      logger.report_error("Invalid syntax", token.syntax_type, token.position, token.line)
    end
  end

  def parse_return_stmt
    advance
    expr = parse_expression
    Statement::Return.new(expr)
  end

  def parse_expression_stmt
    expr = parse_expression
    Statement::ExpressionStmt.new(expr)
  end

  def parse_if_stmt
    advance
    consume(Syntax::LeftParen, "Expected '(' after 'if', got")
    condition = parse_expression
    block = parse_block
    if @tokens[@position].syntax_type == Syntax::Else
      branch = advance
      if branch.syntax_type == Syntax::If
        else_branch = parse_if_stmt
      else
        else_branch = parse_block
      end
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
      when Syntax::RightBrace
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

  def parse_def_args
    parse_call_args
  end

  def parse_call_args
    consume(Syntax::LeftParen, "Expected '(' after function name, got")
    first = @tokens[@position]
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
    arg_expressions
  end

  def parse_function_call_expression(identifier)
    Expression::FunctionCall.new(identifier, parse_call_args)
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
    when Syntax::Return
      parse_stmt
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
