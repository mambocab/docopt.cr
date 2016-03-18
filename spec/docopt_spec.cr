require "./spec_helper"
require "../src/docopt.cr"

describe Docopt do
  describe ".docopt" do
    it "works for the empty program" do
      Docopt.docopt("Usage: prog\n\n", argv: [] of String).should eq({} of String => String)
    end

    it "allows specifying arguments via usage:" do
      Docopt.docopt("Usage: prog <arg>\n\n", argv: ["10"]).should eq({"<arg>" => "10"})
    end

    it "parses option names" do
      docstring = "Usage: prog [options]\n"\
                  "\n"\
                  "Options: -a  All.\n"\
                  "\n"
      Docopt.docopt(docstring, argv: [] of String).should eq({"-a" => false})
    end

    it "parses arbitrary option names" do
      docstring = "Usage: prog [options]\n"\
                  "\n"\
                  "Options: -b  All.\n"\
                  "\n"
      Docopt.docopt(docstring, argv: [] of String).should eq({"-b" => false})
    end

    it "can take multiple option names" do
      docstring = "Usage: prog [options]\n"\
                  "Options: -a\n"\
                  "         -z\n"\
                  "\n"
      Docopt.docopt(docstring, argv: [] of String).should eq({"-a" => false, "-z" => false})
    end

    it "detects the presence of specified options in argv" do
      docstring = "Usage: prog [options]\n"\
                  "Options: -a\n"
      Docopt.docopt(docstring, argv: ["-a"]).should eq({"-a" => true})
    end
  end
end

describe Util::OptionUtil do
  describe ".options_and_arg_to_results" do
    it "returns an empty result given empty options" do
      Util::OptionUtil.options_and_arg_to_results(
        [] of Types::Argument | Types::Option,
        [] of String
      ).should eq({} of String => Bool | String)
    end

    it "returns a map to false for an option that isn't in argv" do
      Util::OptionUtil.options_and_arg_to_results(
        [Types::Argument.new "-a", nil],
        [] of String
      )
    end

    it "returns a map to true for an option that is in argv" do
      Util::OptionUtil.options_and_arg_to_results(
        [Types::Argument.new "-a", nil],
        ["-a"]
      )
    end

    it "will correctly detect 2 options in argv" do
      Util::OptionUtil.options_and_arg_to_results(
        [Types::Argument.new("-a", nil), Types::Argument.new("-b", nil)],
        ["-a", "-b"]
      )
    end
  end
end

describe Util::StringUtil do
  describe ".get_option_lines" do
    it "returns the empty string if there is no 'options:' section" do
      Util::StringUtil.get_option_lines("Usage: prog\n\n").should eq([] of Array(String))
    end

    it "finds the 'options:' line in simple 2-part docstring" do
      docstring = "Usage: prog [options]\nOptions: -b  All."
      Util::StringUtil.get_option_lines(docstring).should eq(
        [["Options: -b  All."]]
      )
    end

    it "finds the 'options:' line case-insensitively" do
      ["OPTIONS:", "options:", "oPtIoNs:"].map do |docstring|
        docstring += " -a  All."
        Util::StringUtil.get_option_lines(docstring).should eq([[docstring]])
      end
    end

    it "finds multiple lines in multi-line 'options:' section" do
      docstring = "Options: -a  All.\n"\
                  "         -v  Verbose."
      Util::StringUtil.get_option_lines(docstring).should eq(
        [["Options: -a  All.",
          "         -v  Verbose."]]
      )
    end

    it "skips section between multiple 'options:' lines" do
      docstring = "Options: -a   All.\n"\
                  "         -v   Verbose.\n"\
                  "\n"\
                  "Usage:\n"\
                  "         lol nobody cares about usage\n"\
                  "Options: -b   Boy, oh boy.\n"\
                  "         -vv  Very verbose.\n"
      Util::StringUtil.get_option_lines(docstring).should eq(
        [["Options: -a   All.",
          "         -v   Verbose."],
         ["Options: -b   Boy, oh boy.",
          "         -vv  Very verbose."]]
      )
    end
  end

  describe ".get_usage_lines" do
    it "extracts section between multiple 'options:' lines" do
      docstring = "Options: -a   All.\n"\
                  "         -v   Verbose.\n"\
                  "\n"\
                  "Usage:\n"\
                  "         lol nobody cares about usage\n"\
                  "Options: -b   Boy, oh boy.\n"\
                  "         -vv  Very verbose.\n"
      Util::StringUtil.get_usage_lines(docstring).should eq(
        [["Usage:",
          "         lol nobody cares about usage"]]
      )
    end
  end
end

describe Util::ArrayUtil do
  describe ".take_chunks_starting_with_selected" do
    it "returns the empty array on the empty array" do
      Util::ArrayUtil.take_chunks_starting_with_selected([] of String) { |x| true }
        .should eq([] of Array(String))
    end

    it "skips all elements if func(e) is always false" do
      Util::ArrayUtil.take_chunks_starting_with_selected([1, 1, 1, 1, 1]) { |x| false }
        .should eq([] of Array(Int32))
    end

    it "skips initial elements if func(e) starts false" do
      Util::ArrayUtil.take_chunks_starting_with_selected([10, 11]) { |x| x == 11 }
        .should eq([[11]])
    end

    it "gives back [array] if the first element and no others pass conditional" do
      Util::ArrayUtil.take_chunks_starting_with_selected([10, 11, 12, 13]) { |x| x == 10 }
        .should eq([[10, 11, 12, 13]])
    end

    it "gives back 2 arrays if 2 elements pass conditional" do
      Util::ArrayUtil.take_chunks_starting_with_selected([10, 11, 10, 12]) { |x| x == 10 }
        .should eq([[10, 11], [10, 12]])
    end

    it "both skips initial elements and makes multiple chunks" do
      Util::ArrayUtil.take_chunks_starting_with_selected(
        [10, 10, 10, 10, 1, 2, 3, 1, 2, 10, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7]
      ) { |x| x == 1 }.should eq(
        [[1, 2, 3],
         [1, 2, 10],
         [1], [1], [1],
         [1, 2, 3, 4, 5, 6, 7]
        ]
      )
    end

    it "allows the final chunk to be a single element" do
      Util::ArrayUtil.take_chunks_starting_with_selected(
        [1, 2, 3, 1, 2, 10, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 1, 1]
      ) { |x| x == 1 }.should eq(
        [[1, 2, 3],
         [1, 2, 10],
         [1], [1], [1],
         [1, 2, 3, 4, 5, 6, 7],
         [1], [1]
        ]
      )
    end
  end

  describe ".indices_where" do
    it "returns the empty array given the empty array" do
      Util::ArrayUtil.indices_where([] of String) { |x| true }
        .should eq([] of Int32)
    end

    it "returns all indices if the condition is always true" do
      Util::ArrayUtil.indices_where([1, 2, "foo"]) { |x| true }.should eq([0, 1, 2])
    end

    it "returns indices where the condition is true" do
      Util::ArrayUtil.indices_where([1, 2, 3, 4, 5]) { |x| x % 2 == 0 }
        .should eq([1, 3])
    end
  end
end

