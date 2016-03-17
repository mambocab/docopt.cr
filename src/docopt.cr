require "./docopt/util"

CASE_INSENSITIVE_STARTS_WITH_OPTIONS_COLON_REGEX = /options\:/i
CASE_INSENSITIVE_STARTS_WITH_USAGE_COLON_REGEX = /usage\:/i
STARTS_WITH_SPACE_OR_TAB_REGEX = /^[ \t]/

module Docopt
  def self.docopt(doc, argv = nil)
    if argv == nil
      argv = ARGV
    end

    Util::OptionUtil.options_and_arg_to_results Parser.parse(doc), argv
  end
end

