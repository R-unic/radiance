require "benchmark"
require_relative "../code_analysis/parser"
require_relative "scope"

class Interpreter
  def initialize(source)
    parser = Parser.new(@source)
    @source = source
    @ast = parser.parse
    @scope = Scope.new
  end

  def interpret
    ast.each { |node| walk(node) }
  end

  def walk

  end
end
