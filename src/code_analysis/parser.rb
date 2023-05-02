require_relative "syntax/ast"
require_relative "lexer"
require_relative "../logger"

class Parser
  attr_accessor :position, :tokens, :logger
  OPERATOR_PRECEDENCE = {
    Syntax::Question => 1,
    Syntax::Equal => 2,
    Syntax::Pipe => 3,
    Syntax::Ampersand => 4,
    Syntax::EqualEqual => 5,
    Syntax::BangEqual => 5,
    Syntax::Less => 6,
    Syntax::LessEqual => 6,
    Syntax::Greater => 6,
    Syntax::GreaterEqual => 6,
    Syntax::Plus => 7,
    Syntax::Minus => 7,
    Syntax::Star => 8,
    Syntax::Slash => 8,
    Syntax::Percent => 8,
    Syntax::Carat => 9
  }

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
    when Syntax::Return
      parse_return_stmt
    when Syntax::Function
      identifier = advance
      advance
      arg_expressions = parse_def_args
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
    else
      logger.report_error("Invalid syntax", token.syntax_type, token.position, token.line)
    end
  end

  def build_expression(queue)
    stack = []
    while !queue.empty?
      token = queue.shift
      case token.syntax_type
      when
      Syntax::Float,
      Syntax::String,
      Syntax::Boolean,
      Syntax::None
        stack << Expression::Literal.new(token)
      when
      Syntax::Plus,
      Syntax::Minus,
      Syntax::Star,
      Syntax::Slash,
      Syntax::Carat,
      Syntax::Percent,
      Syntax::Question,
      Syntax::EqualEqual,
      Syntax::BangEqual,
      Syntax::Greater,
      Syntax::GreaterEqual,
      Syntax::Less,
      Syntax::LessEqual
        right = stack.pop
        left = stack.pop
        stack << Expression::BinaryOp.new(left, token, right)
      when Syntax::Equal
        right = stack.pop
        left = stack.pop
        if left.is_a?(Expression::VariableReference)
          stack << Expression::VariableAssignment.new(left, right)
        else
          logger.report_error("Invalid assignment target", left.value, left.position, left.line)
        end
      when Syntax::Identifier
        stack << Expression::VariableReference.new(token)
      else
        logger.report_error("Invalid syntax", token.syntax_type, token.position, token.line)
      end
    end
    if stack.length > 1
      logger.report_error("Invalid syntax", "Too many values", -1, -1)
    else
      stack.first
    end
  end

  def parse_expression
    output_queue = []
    operator_stack = []
    while token = @tokens[@position]
      case token.syntax_type
      when
      Syntax::Float,
      Syntax::String,
      Syntax::Boolean,
      Syntax::None,
      Syntax::Identifier
        output_queue << token
        advance
      when Syntax::LeftParen
        operator_stack << token
        advance
      when Syntax::RightParen
        while !operator_stack.empty? && operator_stack.last.syntax_type != Syntax::LeftParen
          output_queue << operator_stack.pop
        end
        if operator_stack.empty?
          logger.report_error("Unmatched ')'", token.value, token.position, token.line)
        else
          operator_stack.pop
        end
        advance
      when
      Syntax::Plus,
      Syntax::Minus,
      Syntax::Star,
      Syntax::Slash,
      Syntax::Carat,
      Syntax::Percent,
      Syntax::Question,
      Syntax::EqualEqual,
      Syntax::BangEqual,
      Syntax::Greater,
      Syntax::GreaterEqual,
      Syntax::Less,
      Syntax::LessEqual,
      Syntax::Equal
        precedence = OPERATOR_PRECEDENCE[token.syntax_type]
        while !operator_stack.empty? &&
            operator_stack.last.syntax_type != Syntax::LeftParen &&
            precedence >= OPERATOR_PRECEDENCE[operator_stack.last.syntax_type]
          output_queue << operator_stack.pop
        end
        operator_stack << token
        advance
      when Syntax::EOF
        break
      else
        logger.report_error("Invalid syntax", token.syntax_type, token.position, token.line)
      end
    end
    while !operator_stack.empty?
      if operator_stack.last.syntax_type == Syntax::LeftParen
        logger.report_error("Unmatched '('", operator_stack.last.value, operator_stack.last.position, operator_stack.last.line)
      end
      output_queue << operator_stack.pop
    end
    build_expression(output_queue)
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
        Expression::VariableReference.new(token)
      end
    when
    Syntax::Plus,
    Syntax::Minus,
    Syntax::Bang
      advance
      Expression::UnaryOp.new(token, parse_primary_expression)
    when Syntax::LeftParen
      advance
      expr = parse_expression
      consume(Syntax::RightParen, "Expected ')' after expression, got")
      expr
    when Syntax::Return
      parse_stmt
    when Syntax::EOF
    else
      logger.report_error("Invalid syntax", token.syntax_type, token.position, token.line)
    end
  end

  def parse_def_args
    parse_call_args
  end

  def parse_call_args
    consume(Syntax::LeftParen, "Expected '(' after function name, got")
    first_time = true
    arg_expressions = []
    while !@tokens[@position].nil? && @tokens[@position].syntax_type != Syntax::RightParen
      consume(Syntax::Comma, "Expected ',' to separate arguments, got") unless first_time
      arg_expressions << parse_expression
      first_time = false
    end
    consume(Syntax::RightParen, "Expected ')' after argument list, got")
    arg_expressions
  end

  def parse_function_call_expression(identifier)
    Expression::FunctionCall.new(identifier, parse_call_args)
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

  def parse_if_stmt
    advance
    condition = parse_expression
    block = parse_block
    if @tokens[@position].syntax_type == Syntax::Else
      branch = advance
      else_branch = branch.syntax_type == Syntax::If ? parse_if_stmt : parse_block
    else
      else_branch = nil
    end
    Statement::If.new(condition, block, else_branch)
  end

  def consume(syntax, error_msg, offset = 0)
    token = @tokens[@position]
    unless token.syntax_type == syntax
      shown_token = @tokens[@position + offset]
      logger.report_error(error_msg, shown_token.syntax_type, shown_token.position, shown_token.line)
    else
      advance
    end
    token
  end

  def finished?
    @tokens[@position].nil?
  end

  def peek(offset = 1)
    @tokens[@position + offset]
  end

  def advance
    @position += 1
    @tokens[@position]
  end
end
