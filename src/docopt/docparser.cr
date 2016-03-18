require "./util.cr"

module Parser
  def self.parse(doc)
    if doc == ""
      raise Errors::InvalidDocstringException.new("Cannot use an empty docstring")
    end

    usage_lines = Util::StringUtil.get_usage_lines(doc).flatten
    usage_names = Parser::Util.parse_usage_lines usage_lines

    option_lines = Util::StringUtil.get_option_lines(doc).flatten
    option_names = Parser::Util.parse_option_lines option_lines
    option_names + usage_names
  end

  module Errors
    class InvalidDocstringException < Exception
    end
  end

  # Utilities for extracting data structures from strings
  module Util
    def self.tokenize_option_line(line)
      stripped = line.strip
      stripped == "" ? "" : stripped.split("  ").first
    end

    def self.parse_option_lines(lines)
      #  remove "option:" prefix and get the rest
      lines.map { |line| Parser::Util.tokenize_option_line(line.split(':', 2).last) }
    end

    def self.parse_usage_lines(lines)
      #  remove "usage:" prefix and program name and get the rest
      lines.map { |line| line.strip.split(':', 2).last.split }.flatten[1..-1].reject { |token| token == "[options]" }
    end
  end
end
