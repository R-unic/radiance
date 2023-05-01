require_relative "syntax/syntax"
require_relative "syntax/token"
require_relative "syntax/keywords"
require_relative "../logger"

def float_from_string(s, radix)
  num = s.to_i(radix).to_f
  return num if s.index('.') == nil

  decimal_places = s.length - s.index('.') - 1
  decimal_part = s.split('.')[1].to_i(radix).to_f
  decimal_part /= radix ** decimal_places
  return num + decimal_part
end


class Lexer
  attr_reader :logger
  attr_reader :tokens, :position, :line

  def initialize(source)
    @source = source
    @position = 0
    @line = 1
    @tokens = []
    @logger = Logger.new
  end

  def peek(offset)
    @source[@position + offset]
  end

  def current_char
    peek(0)
  end

  def match_char(expected)
    return false if finished?
    return false unless char_exists?(1)
    return false unless peek(1) == expected
    advance
    true
  end

  def finished?
    @position >= @source.size
  end

  def char_exists?(offset)
    @source[@position + offset]
  end

  def advance
    char = @source[@position]
    @position += 1
    char
  end

  def add_token(syntax, value)
    @tokens << Token.new(syntax, value, @position, @line)
  end

  def is_hex?
    current_char == "0" &&
      char_exists?(1) &&
      peek(1) == "x" &&
      char_exists?(2) &&
      peek(2).to_i(16)
  end

  def is_binary?
    current_char == "0" &&
      char_exists?(1) &&
      peek(1) == "b" &&
      char_exists?(2) &&
      peek(2).to_i(2)
  end

  def skip_comments(multiline)
    advance
    while !end_of_comment(multiline, @line)
      advance
    end
  end

  def end_of_comment(multiline, current_line)
    if multiline
      match_char(":") &&
        match_char("#") &&
        match_char("#")
    else
      @line == current_line || finished?
    end
  end

  def skip_whitespace
    while !finished? && current_char =~ /\s/
      advance
    end
  end

  def read_number
    num_str = ""
    radix = if is_hex?
      advance
      advance
      16
    elsif is_binary?
      advance
      advance
      2
    else
      10
    end

    decimal_used = false
    while !finished? && (current_char.to_i(radix).to_s(radix) == current_char || (!decimal_used && radix == 10 && current_char === "."))
      if current_char == "."
        decimal_used = true
      end
      num_str << advance.to_s
    end

    value = float_from_string(num_str, radix)
    add_token(:float, PossibleTokenValue.new(:Float, value))
  end

  def read_string(delim)
    advance
    res_str = ""
    while !finished? && current_char != delim
      res_str << advance.to_s
    end
    add_token(:string, value: res_str)
  end

  def read_char(delim)
    advance
    res_str = ""
    while !finished? && current_char != delim
      res_str << advance.to_s
      if res_str.length > 1
        @logger.report_error("Character overflow", "Character literal has more than one character", @position, @line)
        break
      end
    end
    add_token(:char, value: res_str[0])
  end

  def read_identifier
    ident_str = ""
    while !finished?
      if char_exists?(1) && !peek(1).match(/\p{Alnum}/) && peek(1) != "_" && peek(1) != "$"
        ident_str += current_char.to_s
        skip_whitespace
        break
      end
      ident_str += advance.to_s
    end
    if Keywords.is?(ident_str)
      syntax_type = Keywords.get_syntax(ident_str)
      value = Keywords.get_value(ident_str)
      add_token(syntax_type, value)
    elsif Keywords.is_type?(ident_str)
      syntax_type = Keywords.get_type_syntax(ident_str)
      add_token(syntax_type, PossibleTokenValue.new(syntax_type, ident_str))
    else
      add_token(Syntax::Identifier, PossibleTokenValue.new(:String, ident_str))
    end
  end

  def lex
    char = current_char
    case char
    when "."
      if peek(1).match(/\d/)
        read_number
      else
        add_token(Syntax::Dot, nil)
      end
    when "{"
      add_token(Syntax::LeftBrace, nil)
    when "}"
      add_token(Syntax::RightBrace, nil)
    when "["
      add_token(Syntax::LeftBracket, nil)
    when "]"
      add_token(Syntax::RightBracket, nil)
    when "("
      add_token(Syntax::LeftParen, nil)
    when ")"
      add_token(Syntax::RightParen, nil)
    when ","
      add_token(Syntax::Comma, nil)
    when ";"
      advance
    when "\n"
      @line += 1
    when "\""
      read_string(char)
    when "'"
      read_char(char)
    when "#"
      if match_char("#")
        is_multiline = match_char(":")
        skip_comments(is_multiline)
      else
        add_token(Syntax::Hashtag, nil)
      end
    when ":"
      if match_char(":")
        add_token(Syntax::ColonColon, nil)
      else
        add_token(Syntax::Colon, nil)
      end
      advance
    when "+"
      if match_char("=")
        add_token(Syntax::PlusEqual, nil)
      else
        add_token(Syntax::Plus, nil)
      end
      advance
    when "-"
      if match_char("=")
        add_token(Syntax::MinusEqual, nil)
      elsif match_char(">")
        add_token(Syntax::HyphenArrow, nil)
      else
        add_token(Syntax::Minus, nil)
      end
      advance
    when "*"
      if match_char("=")
        add_token(Syntax::StarEqual, nil)
      else
        add_token(Syntax::Star, nil)
      end
      advance
    when "/"
      if match_char("=")
        add_token(Syntax::SlashEqual, nil)
      else
        add_token(Syntax::Slash, nil)
      end
      advance
    when "^"
      if match_char("=")
        add_token(Syntax::CaratEqual, nil)
      else
        add_token(Syntax::Carat, nil)
      end
      advance
    when "%"
      if match_char("=")
        add_token(Syntax::PercentEqual, nil)
      else
        add_token(Syntax::Percent, nil)
      end
      advance
    when "&"
      add_token(Syntax::Ampersand, nil)
      advance
    when "|"
      if match_char("=")
        add_token(Syntax::PipeEqual, nil)
      else
        add_token(Syntax::Pipe, nil)
      end
      advance
    when "!"
      if match_char("=")
        add_token(Syntax::BangEqual, nil)
      else
        add_token(Syntax::Bang, nil)
      end
      advance
    when "="
      if match_char("=")
        add_token(Syntax::EqualEqual, nil)
      else
        add_token(Syntax::Equal, nil)
      end
      advance
    when "<"
      if match_char("=")
        add_token(Syntax::LessEqual, nil)
      else
        add_token(Syntax::Less, nil)
      end
      advance
    when ">"
      if match_char("=")
        add_token(Syntax::GreaterEqual, nil)
      else
        add_token(Syntax::Greater, nil)
      end
      advance
    else
      default_char = @source[@position]
      if default_char.match(/\s/)
        skip_whitespace
        return
      end

      is_ident = default_char.match(/[a-zA-Z_$]/)
      is_number = default_char.match(/\d/) ||
        (default_char == "0" && peek(1) == "x" && peek(2).match(/[0-9a-fA-F]/)) ||
        (default_char == "0" && peek(1) == "b" && peek(2).match(/[01]/))

      if is_number
        read_number
      elsif is_ident
        read_identifier
      else
        @logger.report_error("Unexpected character", default_char.to_s, @position, @line)
      end
    end
    @position += 1
  end

  def tokenize
    while !finished?
      lex
    end

    add_token(Syntax::EOF, nil)
    @tokens
  end
end
