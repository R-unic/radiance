require_relative "../code_analysis/syntax/syntax"
require_relative "../logger"

class Scope
  attr_accessor :parent, :local_variables

  def initialize(parent = nil)
    @parent = parent
    @local_variables = {}
  end

  def add_variable(identifier, value)
    @local_variables[identifier] = value
  end

  def lookup_variable(identifier)
    @local_variables[identifier]
  end

  def to_s
    variables = @local_variables.transform_keys { |key| key.value }
    "Scope<#{@parent ? "parent: " + @parent.to_s + ", " : ""}#{variables}>"
  end
end
