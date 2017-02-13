require "cltk/lexer"

module GraphQl
  module Language
    class Lexer < CLTK::Lexer
      # Skip whitespace.
      rule(/\n/)
      rule(/\s/)

      rule(/:/)	  { :COLON   }

      rule(/[_A-Za-z][_0-9A-Za-z]*/) { :IDENTIFIER}

      rule(/[\c\r\n]/)           { :NEWLINE }
      rule(/[, \t]+/)            { :BLANK }
      rule(/# [^\n\r]*/)         { |t| {:COMMENT, t} }
      rule(/on/)                 { :ON }
      rule(/fragment/)           { :FRAGMENT }
      rule(/true/)               { :TRUE }
      rule(/false/)              { :FALSE }
      rule(/null/)               { :NULL }
      rule(/query/)              { :QUERY }
      rule(/mutation/)           { :MUTATION }
      rule(/subscription/)       { :SUBSCRIPTION }
      rule(/schema/)             { :SCHEMA }
      rule(/scalar/)             { :SCALAR }
      rule(/type/)               { :TYPE }
      rule(/implements/)         { :IMPLEMENTS }
      rule(/interface/)          { :INTERFACE }
      rule(/union/)              { :UNION }
      rule(/enum/)               { :ENUM }
      rule(/input/)              { :INPUT }
      rule(/directive/)          { :DIRECTIVE }
      rule(/\{/)                 { :LCURLY }
      rule(/\}/)                 { :RCURLY }
      rule(/\(/)                 { :LPAREN }
      rule(/\)/)                 { :RPAREN }
      rule(/\[/)                 { :LBRACKET }
      rule(/\]/)                 { :RBRACKET }
      rule(/:/)                  { :COLON }
      rule(/\$/)                 { :VAR_SIGN }
      rule(/\@/)                 { :DIR_SIGN }
      rule(/\.\.\./)             { :ELLIPSIS }
      rule(/\=/)                 { :EQUALS }
      rule(/\!/)                 { :BANG }
      rule(/\|/)                 { :PIPE }

      rule(/\-?(0|[1-9][0-9]*)(\.[0-9]+)?((e|E)?(\+|\-)?[0-9]+)?/) { |t| {:FLOAT, t} }

      rule(/"(?:[^"\\]|\\.)*"/)  do |t|
        escaped = replace_escaped_characters_in_place(t[1...-1]);
        if escaped  !~ VALID_STRING
          {:BAD_UNICODE_ESCAPE, escaped }
        else
          {:QUOTED_STRING, escaped}
        end
      end

      ESCAPES = /\\["\\\/bfnrt]/
      ESCAPES_REPLACE = {
        %{\\"} => '"',
        "\\\\" => "\\",
        "\\/" => '/',
        "\\b" => "\b",
        "\\f" => "\f",
        "\\n" => "\n",
        "\\r" => "\r",
        "\\t" => "\t",
      }

      UTF_8 = /\\u[\dAa-f]{4}/i
      UTF_8_REPLACE = ->(m : String ) { [m[-4..-1].to_i(16)] }

      VALID_STRING = /\A(?:[^\\]|#{ESCAPES}|#{UTF_8})*\z/

      def self.replace_escaped_characters_in_place(raw_string)
        raw_string.gsub(ESCAPES, ESCAPES_REPLACE).gsub(UTF_8, &UTF_8_REPLACE)
      end

    end
  end
end