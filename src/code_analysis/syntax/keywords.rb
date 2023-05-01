require_relative "syntax"
require_relative "token"

module Keywords
  extend self

  KEYWORDS = {
    "true" => Syntax::Boolean,
    "false" => Syntax::Boolean,
    "none" => Syntax::None,
    "fn" => Syntax::Function,
    "if" => Syntax::If,
    "else" => Syntax::Else,
    "for" => Syntax::For,
    "foreach" => Syntax::ForEach,
    "while" => Syntax::While,
    "break" => Syntax::Break,
    "next" => Syntax::Next,
    "match" => Syntax::Match,
    "global" => Syntax::Global,
    "const" => Syntax::Constant,
  }.freeze

  TYPE_KEYWORDS = {
    "bool" => Syntax::BooleanType,
    "string" => Syntax::StringType,
    "char" => Syntax::CharType,
    "float" => Syntax::FloatType,
    "void" => Syntax::VoidType,
    "none" => Syntax::NoneType,
  }.freeze

  def is_type?(s)
    TYPE_KEYWORDS.key?(s)
  end

  def get_type_syntax(s)
    TYPE_KEYWORDS.fetch(s) { raise "Invalid type keyword #{s}" }
  end

  def is?(s)
    KEYWORDS.key?(s)
  end

  def get_syntax(s)
    KEYWORDS.fetch(s) { raise "Invalid keyword #{s}" }
  end

  def get_value(s)
    case s
    when "true"
      PossibleTokenValue.new(:Boolean, true)
    when "false"
      PossibleTokenValue.new(:Boolean, false)
    when "none"
      PossibleTokenValue.new(:None, nil)
    else
      nil
    end
  end
end
