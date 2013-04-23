module ExpressionParser
  class Error < StandardError; end
  class UnknownTokenError < Error; end
  class EndExpectedError < Error; end
  class UnbalancedParenthesisError < Error; end
  class ExpressionSyntaxError < Error; end
end
