require "benchmark"
require_relative "scope"
require_relative "../logger"
require_relative "../code_analysis/parser"

class Interpreter
  def initialize
    @scope = Scope.new
  end

  def interpret(source, repl)
    parser = Parser.new(source)
    ast = parser.parse
    ast.each do |node|
      result = evaluate(node)
      puts result unless !repl
    end
  end

  def evaluate(node)
    case node
    when Expression::BinaryOp
      left = evaluate(node.left)
      right = evaluate(node.right)
      case node.operator.syntax_type
      when Syntax::Plus
        left + right
      when Syntax::Minus
        left - right
      when Syntax::Star
        left + right
      when Syntax::Slash
        left / right
      when Syntax::Carat
        left ** right
      when Syntax::Percent
        left % right
      when Syntax::Ampersand
        left & right
      when Syntax::Pipe
        left || right
      when Syntax::Question
        left == nil ? right : left
      end
    when Expression::UnaryOp
      operand = evaluate(node.operand)
      case node.operator.syntax_type
      when Syntax::Bang
        !operand
      when Syntax::Minus
        -operand
      when Syntax::Plus
        operand
      end
    when Expression::Literal
      case node.token.syntax_type
      when Syntax::Float
        node.token.value.value
      when Syntax::Boolean
        node.token.value.value
      else
        node.token.value.value.to_s
      end
    when Expression::FunctionCall

    when Expression::VariableAssignment
      value = evaluate(node.expression)
      @scope.add_variable(node.reference.identifier.value.value, value)
    when Expression::VariableReference
      @scope.lookup_variable(node.identifier.value.value)
    when Statement::Function

    when Statement::If

    when Statement::While

    when Statement::For

    when Statement::ExpressionStmt

    when Statement::Return

    when Statement::Block
      @scope = Scope.new(@scope)
      node.statements.each { |stmt| evaluate(stmt) }
    else
      logger.report_error("Unhandled AST node: #{node}")
    end
  end
end
