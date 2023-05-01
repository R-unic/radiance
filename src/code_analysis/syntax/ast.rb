class Node; end

class LiteralNode < Node
  attr_reader :token

  def initialize(token)
    super()
    @token = token
  end

  def to_s
    "Literal<syntax: #{@token.syntax_type}, value: #{@token.value}>"
  end
end

class BinaryOpNode < Node
  attr_reader :left, :operator, :right

  def initialize(left, operator, right)
    super()
    @left = left
    @operator = operator
    @right = right
  end

  def to_s
    "Binary<left: #{@left}, operator: #{@operator.syntax_type}, right: #{@right}>"
  end
end

class UnaryOpNode < Node
  attr_reader :operator, :operand

  def initialize(operator, operand)
    super()
    @operator = operator
    @operand = operand
  end

  def to_s
    "Unary<operator: #{@operator}, operand: #{@operand}>"
  end
end
