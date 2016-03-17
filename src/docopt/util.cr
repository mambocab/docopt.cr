module Util
  # Utilities for processing data structures representing options and
  # arguments
  module OptionUtil
    def self.options_and_arg_to_results(options, argv)
      Hash.zip options, options.map do |name|
        if name.starts_with? '-'
          argv.includes? name
        else
          argv[0]
        end
      end
    end
  end

  # Utilities for extracting data structures from strings
  module ParseUtil
    def self.tokenize_option_line(line)
      stripped = line.strip
      stripped == "" ? "" : stripped.split("  ").first
    end

    def self.parse_option_lines(lines)
      #  remove "option:" prefix and get the rest
      lines.map { |line| Util::ParseUtil.tokenize_option_line(line.split(':', 2).last) }
    end

    def self.parse_usage_lines(lines)
      #  remove "usage:" prefix and program name and get the rest
      lines.map { |line| line.strip.split(':', 2).last.split }.flatten[1..-1].reject { |token| token == "[options]" }
    end
  end

  # Utilities for manipulating strings
  module StringUtil
    private def self.get_section_lines(s, section_start_regex)
      split = s.split('\n').reject { |x| x == "" }
      ArrayUtil.take_chunks_starting_with_selected(split) do |line|
        STARTS_WITH_SPACE_OR_TAB_REGEX.match(line) == nil
      end.select do |section_chunk|
        section_start_regex.match(section_chunk.first)
      end
    end

    def self.get_option_lines(s)
      get_section_lines(s, CASE_INSENSITIVE_STARTS_WITH_OPTIONS_COLON_REGEX)
    end

    def self.get_usage_lines(s)
      get_section_lines(s, CASE_INSENSITIVE_STARTS_WITH_USAGE_COLON_REGEX)
    end
  end

  # Utilities for manipulating arrays and other {Iter,Enumer}ables
  module ArrayUtil
    # Given an Iterable or Enumerable xs, return its elements in the same order
    # but chunked into arrays that start with an element e for which func(e)
    # is true, but for which func(f) is false for each subsequent value f. For
    # example:
    #
    #     ary = [0, 1, 2, 3, 1, 4, 5, 1]
    #     take_chunks_starting_with_selected(ary, { |x| x == 1 }) #=> [[1, 2, 3], [1, 4, 5], [1]]
    def self.take_chunks_starting_with_selected(xs : (Iterable(T) | Enumerable(T)),
                                                &block : T -> _)
      xs = xs.to_a
      # generate pairs denoting the beginning and end of each range
      # append 0 to make sure we include xs.last...
      range_pairs = (self.indices_where(xs, &block) + [0]).each.cons(2)
      # then bring the last index of each range back 1 to avoid including
      # the n+1th match in the nth chunk
      range_pairs = range_pairs.map { |p| {p.first, p.last - 1} }

      # generate and return chunks
      range_pairs.map do |range_pair|
        from, up_to = range_pair
        xs[from..up_to].to_a
      end.to_a
    end

    def self.indices_where(xs : (Iterable(T) | Enumerable(T)),
                           &block : T -> _)
      xs.each.with_index.select { |x| block.call(x.first) }.to_a.map { |x| x.last }
    end
  end
end
