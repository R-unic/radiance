class Node; end

module Expression
  class Expr < Node; end

  class Literal < Expr
    attr_reader :token

    def initialize(token)
      super()
      @token = token
    end

    def to_s
      "Literal<syntax: #{@token.syntax_type}, value: #{@token.value}>"
    end
  end

  class BinaryOp < Node
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

  class UnaryOp < Node
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
end

module Statement
  class Stmt < Node; end

  class If < Stmt
    attr_reader :condition, :block, :else_branch

    def initialize(condition, block, else_branch)
      super()
      @condition = condition
      @block = block
      @else_branch = else_branch
    end

    def to_s
      "If<condition: #{@condition},block: #{@block}, else_branch: #{@else_branch}>"
    end
  end
end
