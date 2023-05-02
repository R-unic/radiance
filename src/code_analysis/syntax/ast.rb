class Node; end

module Expression
  class Expr < Node; end

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

  class VariableReference < Expr
    attr_reader :identifier

    def initialize(identifier)
      super()
      @identifier = identifier
    end

    def to_s
      "VariableReference<identifier: #{@identifier}>"
    end
  end

  class VariableAssignment < Expr
    attr_reader :reference, :expression

    def initialize(reference, expression)
      super()
      @reference = reference
      @expression = expression
    end

    def to_s
      "VariableAssignment<reference: #{@reference}, expression: #{@expression}>"
    end
  end

  class FunctionCall < Expr
    attr_reader :identifier, :arguments

    def initialize(identifier, arguments)
      super()
      @identifier = identifier
      @arguments = arguments
    end

    def to_s
      "FunctionCall<identifier: #{@identifier} arguments: [#{@arguments.map(&:to_s).join(", ")}]>"
    end
  end
end

module Statement
  class Stmt < Node; end

  class Function < Stmt
    attr_reader :identifier, :arguments, :block, :return

    def initialize(identifier, arguments, block, _return)
      super()
      @identifier = identifier
      @arguments = arguments
      @block = block
      @return = _return
    end

    def to_s
      "Function<identifier: #{@identifier}, arguments: [#{@arguments.map(&:to_s).join(", ")}], block: #{@block}, return: #{@return}>"
    end
  end

  class If < Stmt
    attr_reader :condition, :block, :else_branch

    def initialize(condition, block, else_branch)
      super()
      @condition = condition
      @block = block
      @else_branch = else_branch
    end

    def to_s
      "If<condition: #{@condition}, block: #{@block}, else_branch: #{@else_branch}>"
    end
  end

  class ExpressionStmt < Stmt
    attr_reader :expression

    def initialize(expression)
      super()
      @expression = expression
    end

    def to_s
      "ExpressionStmt<expression: #{@expression}>"
    end
  end

  class Return < ExpressionStmt
    def to_s
      "Return<expression: #{@expression}>"
    end
  end

  class Block < Stmt
    attr_reader :statements

    def initialize(statements)
      super()
      @statements = statements
    end

    def to_s
      "Block<statements: [#{@statements.map(&:to_s).join(", ")}]>"
    end
  end
end
