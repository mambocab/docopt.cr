require "./util.cr"

module Parser
  def self.parse(doc)
    usage_lines = Util::StringUtil.get_usage_lines(doc).flatten
    usage_names = Util::ParseUtil.parse_usage_lines usage_lines

    option_lines = Util::StringUtil.get_option_lines(doc).flatten
    option_names = Util::ParseUtil.parse_option_lines option_lines
    option_names + usage_names
  end
end
