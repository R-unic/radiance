class Node; end

class LiteralNode < Node
  attr_reader :token

  def initialize(token)
    super([])
    @token = token
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
end
