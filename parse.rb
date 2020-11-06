#!/usr/bin/env ruby

class String
  def numeric?
    Float(self) != nil rescue false
  end
end

def tokenize(string)
  string.scan(/\(|\)|'|[^) ;\n]+|;.+\z/)
end

def type(token)
  if token.numeric?
    [:int, token.to_i]
  elsif token =~ /^"(.*)"$/
    [:str, $1]
  else
    [:sym, token]
  end
end

def parse_sexp(tokens, l=0)
  sexp = []
  loop do
    tok = tokens.shift
    case tok
    when -> t { t and t[0] == ';' }
      next # comment
    when '('
      sexp << parse_sexp(tokens, l+1)
    when "'"
      sexp << [:quote, parse_sexp(tokens, l+1)[0]]
    when ')', nil
      return sexp
    else
      sexp << type(tok)
    end
  end
end

def to_lisp(string)
  parse_sexp(tokenize(string))
end

if __FILE__ == $PROGRAM_NAME
  p to_lisp("(+ 1 1) (+ 2 2)")

  p to_lisp(<<~EOF)
    (defn inc (a)
      (+ a 1))
  EOF

  p to_lisp(<<~EOF)
    (lambda (a) "abc")
  EOF

  p to_lisp(<<~EOF)
    '(lambda (a) "abc")
  EOF
end
