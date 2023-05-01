require_relative "syntax"

class PossibleTokenValue
  attr_reader :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    case @type
    when Syntax::Float, Syntax::Boolean
      @value.to_s
    when Syntax::String
      "\"#{@value}\""
    when Syntax::Char
      "'#{@value}'"
    when Syntax::None
      "none"
    when Syntax::Identifier
      "Ident<#{@value.to_s}>"
    else
      @value.to_s
    end
  end
end

class Token
  attr_reader :syntax_type, :value, :position, :line

  def initialize(syntax_type, value = nil, position, line)
    @syntax_type = syntax_type
    @value = value
    @position = position
    @line = line
  end

  def to_s
    value_str = @value.nil? ? "none" : PossibleTokenValue.new(@syntax_type, @value).to_s

    "Token<syntax: #{@syntax_type}, value: #{value_str.start_with?("Ident<") ? value_str : value_str[1..-2]}>"
  end
end
