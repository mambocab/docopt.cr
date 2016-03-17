require "./docopt/util"

CASE_INSENSITIVE_STARTS_WITH_OPTIONS_COLON_REGEX = /options\:/i
CASE_INSENSITIVE_STARTS_WITH_USAGE_COLON_REGEX = /usage\:/i
STARTS_WITH_SPACE_OR_TAB_REGEX = /^[ \t]/

module Docopt
  def self.docopt(doc, argv = nil)
    if argv == nil
      argv = ARGV
    end

    usage_lines = DocoptUtil::StringUtil.get_usage_lines(doc).flatten
    usage_names = DocoptUtil::ParseUtil.parse_usage_lines usage_lines

    option_lines = DocoptUtil::StringUtil.get_option_lines(doc).flatten
    option_names = DocoptUtil::ParseUtil.parse_option_lines option_lines

    DocoptUtil::OptionUtil.options_and_arg_to_results option_names + usage_names, argv
  end
end

