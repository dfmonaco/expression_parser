# Taken from http://lukaszwrobel.pl/blog/math-parser-part-3-implementation
module ExpressionParser

  class Parser
    def parse(input)
      @lexer = Lexer.new(input)

      expression_value = expression
      token = @lexer.get_next_token
      if token.kind == Token::End
        expression_value
      else
        compare_expr(token,expression_value,expression)
      end
    end

    protected
    def compare_expr(token,expression_value,expression)
      case token.kind
      when Token::GThan
        expression_value > expression ? 1 : 0
      when Token::LThan
        expression_value < expression ? 1 : 0
      when Token::Equal
        expression_value == expression ? 1 : 0
      when Token::NotEqual
        expression_value != expression ? 1 : 0
      when Token::GThanE
        expression_value >= expression ? 1 : 0
      when Token::LThanE
        expression_value <= expression ? 1 : 0
      else
        raise ExpressionParser::EndExpectedError, 'End expected'
      end
    end

    def additive_operators
      [Token::Plus, Token::Minus]
    end

    def expression
      component1 = factor

      token = @lexer.get_next_token
      while additive_operators.include?(token.kind)
        component2 = factor

        if token.kind == Token::Plus
          component1 += component2
        else
          component1 -= component2
        end

        token = @lexer.get_next_token
      end
      @lexer.revert

      component1
    end

    def factor
      factor1 = number

      multiplicative_operators = [Token::Multiply, Token::Divide, Token::MOD]

      token = @lexer.get_next_token
      while multiplicative_operators.include?(token.kind)
        factor2 = number

        if token.kind == Token::Multiply
          factor1 *= factor2
        elsif token.kind == Token::MOD
          factor1 %= factor2
        else
          factor1 /= factor2
        end

        token = @lexer.get_next_token
      end
      @lexer.revert

      factor1
    end

    def number
      token = @lexer.get_next_token

      if token.kind == Token::LParen
        value = expression
        expected_rparen = @lexer.get_next_token
        if [Token::GThan,Token::LThan,Token::Equal,Token::NotEqual,Token::GThanE,Token::LThanE].include?(expected_rparen.kind)
          tmp = expression
          value = compare_expr(expected_rparen,value,tmp)
          expected_rparen = @lexer.get_next_token
        end
        expected_rparen

        unless expected_rparen.kind == Token::RParen
          raise ExpressionParser::UnbalancedParenthesisError, "Unbalanced parenthesis"
        end

      elsif token.kind == Token::Number
        value = token.value

      elsif additive_operators.include?(token.kind) && !(@lexer.previous_token && additive_operators.include?(@lexer.previous_token.kind))
        next_token = @lexer.get_next_token
        if next_token.kind == Token::Number
          value = "#{token.value}#{next_token.value}".to_f
        else
          raise ExpressionParser::ExpressionSyntaxError, 'Not a number'
        end

      else
        raise ExpressionParser::ExpressionSyntaxError, 'Not a number'
      end

      value
    end
  end

end
