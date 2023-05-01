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

class BinaryNode < Node
  attr_reader :operator, :left, :right

  def initialize(operator, left, right)
    super([])
    @operator = operator
    @left = left
    @right = right
  end

  def to_s
    "Binary<operator: #{@operator.syntax_type}, left: #{@left}, right: #{@right}>"
  end
end
