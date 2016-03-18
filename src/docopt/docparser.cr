require "../docopt/types.cr"
require "./util.cr"

module DocParser
  def self.parse(doc : String) : Array(Types::InputWord)
    if doc == ""
      raise Errors::InvalidDocstringException.new("Cannot use an empty docstring")
    end

    sections = Util::StringUtil.get_sections doc
    extracted = sections.map do |section|
      first_line = section.first.downcase
      if first_line.starts_with? "usage:"
        DocParser::Util.parse_usage_lines section
      elsif first_line.starts_with? "options:"
        DocParser::Util.parse_option_lines section
      else
        raise Errors::InvalidDocstringException.new(
          "Section must start with 'usage:' or 'options:', "\
          "section was:\n#{section.join('\n')}")
      end
    end.flatten

    extracted.map do |word|
      if word.starts_with? '<'
        Types::Argument.new word, nil
      elsif word.starts_with? '-'
        Types::Option.new word, nil
      else
        raise Errors::InvalidDocstringException.new("Invalid input word #{word}")
      end
    end
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
      lines.map { |line| DocParser::Util.tokenize_option_line(line.split(':', 2).last) }
    end

    def self.parse_usage_lines(lines)
      #  remove "usage:" prefix and program name and get the rest
      lines.map { |line| line.strip.split(':', 2).last.split }.flatten[1..-1].reject { |token| token == "[options]" }
    end
  end
end
