require "benchmark"
require_relative "scope"
require_relative "../logger"
require_relative "../code_analysis/parser"

class Interpreter
  def initialize(source)
    parser = Parser.new(source)
    @source = source
    @ast = parser.parse
    puts @ast
    @scope = Scope.new
  end

  def interpret(repl)
    @ast.each do |node|
      result = evaluate(node)
      puts result unless !repl
    end
  end

  def evaluate(node)
    case node
    when Expression::BinaryOp

    when Expression::UnaryOp

    when Expression::Literal
      node.token.value
    when Expression::VariableReference
      @scope.lookup_variable(node.identifier)
    when Expression::VariableAssignment
      value = evaluate(node.expression)
      @scope.add_variable(node.identifier, value)
    when Expression::FunctionCall

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
