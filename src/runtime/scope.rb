require_relative "../logger"

class Scope
  attr_accessor :parent, :local_variables

  def initialize(parent = nil)
    @parent = parent
    @local_variables = {}
  end

  def add_local_variable(name, index)
    @local_variables[name] = index
  end

  def lookup_local_variable(name)
    @local_variables[name]
  end

  def lookup_variable(name)
    index = lookup_local_variable(name)
    if index
      [:get_local, index]
    elsif @parent
      @parent.lookup_variable(name)
    else
      @logger.report_error("Undefined variable", name, @position, @line)
    end
  end
end
