require "benchmark"
require_relative "scope"
require_relative "types"
require_relative "../logger"
require_relative "../code_analysis/parser"

class Interpreter
  def initialize
    @scope = Scope.new
    @logger = Logger.new
    define_intrinsics
  end

  def define_intrinsics
    @scope.add_variable("print", RuntimeTypes::Function.new { |m| puts m })
  end

  def interpret(source, repl)
    parser = Parser.new(source)
    ast = parser.parse
    ast.each do |node|
      result = evaluate(node)
      puts result == nil ? "none" : result unless !repl
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
      when Syntax::Less
        left < right
      when Syntax::LessEqual
        left <= right
      when Syntax::Greater
        left > right
      when Syntax::GreaterEqual
        left >= right
      when Syntax::EqualEqual
        left == right
      when Syntax::BangEqual
        left != right
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
      when Syntax::None
        nil
      else
        node.token.value.value.to_s
      end
    when Expression::FunctionCall
      fn = @scope.lookup_variable(node.identifier.value.value, node.identifier)
      args = node.arguments.map { |arg| evaluate(arg) }
      fn.call(args)
    when Expression::VariableAssignment
      value = evaluate(node.expression)
      @scope.add_variable(node.reference.identifier.value.value, value)
    when Expression::VariableReference
      @scope.lookup_variable(node.identifier.value.value, node.identifier)
    when Statement::Function
      arg_names = node.arguments.map { |a| a.identifier.value.value }
      callback = lambda do |*args|
        @scope = Scope.new(@scope)
        args.each_with_index do |arg, i|
          @scope.add_variable(arg_names[i], arg)
        end

        puts node.block.statements
        result = node.block.statements.pop
        node.block.statements.each do |stmt|
          evaluate(stmt)
        end

        result = node.return ? evaluate(node.return) : evaluate(result)
        @scope = @scope.unwrap

        result
      end
      @scope.add_variable(node.identifier.value.value, RuntimeTypes::Function.new(&callback))
    when Statement::If
      condition = evaluate(node.condition)
      if condition
        evaluate(node.block)
      else
        evaluate(node.else_branch)
      end
    # when Statement::While

    # when Statement::For

    when Statement::ExpressionStmt, Statement::Return
      evaluate(node.expression)
    when Statement::Block
      @scope = Scope.new(@scope)
      node.statements.each { |stmt| evaluate(stmt) }
      @scope = @scope.unwrap
    else
      @logger.report_error("Unhandled AST node", node, 0, 0)
    end
  end
end
