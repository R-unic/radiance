require_relative "../code_analysis/syntax/syntax"
require_relative "../logger"

class Scope
  attr_accessor :parent, :local_variables

  def initialize(parent = nil)
    @parent = parent
    @local_variables = {}
    @logger = Logger.new
  end

  def add_variable(identifier, value)
    @local_variables[identifier] = value
  end

  def lookup_variable(identifier, token)
    value = @local_variables[identifier]
    if value.nil? && @parent.nil?
      @logger.report_error("Undefined variable", token.value, token.position, token.line)
    end
    if value.nil? && !@parent.nil?
      value = @parent.lookup_variable(identifier, token)
    end
    value
  end

  def unwrap
    @parent
  end

  def to_s
    variables = @local_variables
    "Scope<#{@parent ? "parent: " + @parent.to_s + ", " : ""}#{variables}>"
  end
end
