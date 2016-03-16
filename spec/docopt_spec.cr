require "./spec_helper"
require "../src/docopt.cr"

describe Docopt do
  describe ".docopt" do
    it "works for the empty program" do
      Docopt.docopt("Usage: prog\n\n", argv: [] of String).should eq({} of String => String)
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

describe DocoptUtil::OptionUtil do
  describe ".options_and_arg_to_results" do
    describe "empty options returns empty result" do
      DocoptUtil::OptionUtil.options_and_arg_to_results([] of String, [] of String).should eq({} of String => Bool)
    end
  end
end

describe DocoptUtil::StringUtil do
  describe ".get_option_lines" do
    it "returns the empty string if there is no 'options:' section" do
      DocoptUtil::StringUtil.get_option_lines("Usage: prog\n\n").should eq([] of Array(String))
    end

    it "finds the 'options:' line in simple 2-part docstring" do
      docstring = "Usage: prog [options]\nOptions: -b  All."
      DocoptUtil::StringUtil.get_option_lines(docstring).should eq(
        [["Options: -b  All."]]
      )
    end

    it "finds the 'options:' line case-insensitively" do
      ["OPTIONS:", "options:", "oPtIoNs:"].map do |docstring|
        docstring += " -a  All."
        DocoptUtil::StringUtil.get_option_lines(docstring).should eq([[docstring]])
      end
    end

    it "finds multiple lines in multi-line 'options:' section" do
      docstring = "Options: -a  All.\n"\
                  "         -v  Verbose."
      DocoptUtil::StringUtil.get_option_lines(docstring).should eq(
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
      DocoptUtil::StringUtil.get_option_lines(docstring).should eq(
        [["Options: -a   All.",
          "         -v   Verbose."],
         ["Options: -b   Boy, oh boy.",
          "         -vv  Very verbose."]]
      )
    end
  end
end

describe DocoptUtil::ArrayUtil do
  describe ".take_chunks_starting_with_selected" do
    it "returns the empty array on the empty array" do
      DocoptUtil::ArrayUtil.take_chunks_starting_with_selected([] of String) { |x| true }
        .should eq([] of Array(String))
    end

    it "skips all elements if func(e) is always false" do
      DocoptUtil::ArrayUtil.take_chunks_starting_with_selected([1, 1, 1, 1, 1]) { |x| false }
        .should eq([] of Array(Int32))
    end

    it "skips initial elements if func(e) starts false" do
      DocoptUtil::ArrayUtil.take_chunks_starting_with_selected([10, 11]) { |x| x == 11 }
        .should eq([[11]])
    end

    it "gives back [array] if the first element and no others pass conditional" do
      DocoptUtil::ArrayUtil.take_chunks_starting_with_selected([10, 11, 12, 13]) { |x| x == 10 }
        .should eq([[10, 11, 12, 13]])
    end

    it "gives back 2 arrays if 2 elements pass conditional" do
      DocoptUtil::ArrayUtil.take_chunks_starting_with_selected([10, 11, 10, 12]) { |x| x == 10 }
        .should eq([[10, 11], [10, 12]])
    end

    it "both skips initial elements and makes multiple chunks" do
      DocoptUtil::ArrayUtil.take_chunks_starting_with_selected(
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
      DocoptUtil::ArrayUtil.take_chunks_starting_with_selected(
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
      DocoptUtil::ArrayUtil.indices_where([] of String) { |x| true }
        .should eq([] of Int32)
    end

    it "returns all indices if the condition is always true" do
      DocoptUtil::ArrayUtil.indices_where([1, 2, "foo"]) { |x| true }.should eq([0, 1, 2])
    end

    it "returns indices where the condition is true" do
      DocoptUtil::ArrayUtil.indices_where([1, 2, 3, 4, 5]) { |x| x % 2 == 0 }
        .should eq([1, 3])
    end
  end
end

describe DocoptUtil::ParseUtil do
  describe ".parse_option_line" do
    it "returns nil on an empty string" do
      DocoptUtil::ParseUtil.parse_option_line("").should eq(nil)
    end

    it "returns the flag specified on the line" do
      DocoptUtil::ParseUtil.parse_option_line("-a").should eq("-a")
      DocoptUtil::ParseUtil.parse_option_line("-v").should eq("-v")
    end

    it "treats text after 2 spaces as a comment" do
      DocoptUtil::ParseUtil.parse_option_line("--verbose  This is a comment").should eq("--verbose")
    end

    it "ignores leading space" do
      DocoptUtil::ParseUtil.parse_option_line("         --verbose  This is a comment").should eq("--verbose")
    end
  end

  describe ".get_options_from_option_lines" do
    it "returns an empty hash on an empty array" do
      DocoptUtil::ParseUtil.get_options_from_option_lines([] of String).should eq([] of String)
    end

    it "gets rid of leading 'options:' strings" do
      DocoptUtil::ParseUtil.get_options_from_option_lines(["options:  --foo"]).should eq(["--foo"])
    end

    it "works when comments include ':'" do
      DocoptUtil::ParseUtil.get_options_from_option_lines(
        ["options:  --foo  Wizard: needs foo badly."]).should eq(["--foo"])
    end
  end
end
