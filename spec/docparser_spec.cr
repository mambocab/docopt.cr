require "./spec_helper"
require "../src/docopt/docparser.cr"

describe DocParser do
  describe ".parse" do
    it "raises an error on an empty docstring" do
      expect_raises(DocParser::Errors::InvalidDocstringException, "empty") do
        DocParser.parse ""
      end
    end
  end

  describe DocParser::Util do
    describe ".tokenize_option_line" do
      it "returns empty string on an empty string" do
        DocParser::Util.tokenize_option_line("").should eq("")
      end

      it "returns the flag specified on the line" do
        DocParser::Util.tokenize_option_line("-a").should eq("-a")
        DocParser::Util.tokenize_option_line("-v").should eq("-v")
      end

      it "treats text after 2 spaces as a comment" do
        DocParser::Util.tokenize_option_line("--verbose  This is a comment").should eq("--verbose")
      end

      it "ignores leading space" do
        DocParser::Util.tokenize_option_line("         --verbose  This is a comment").should eq("--verbose")
      end
    end

    describe ".parse_option_lines" do
      it "returns an empty hash on an empty array" do
        DocParser::Util.parse_option_lines([] of String).should eq([] of String)
      end

      it "gets rid of leading 'options:' strings" do
        DocParser::Util.parse_option_lines(["options:  --foo"]).should eq(["--foo"])
      end

      it "works when comments include ':'" do
        DocParser::Util.parse_option_lines(
          ["options:  --foo  Wizard: needs foo badly."]).should eq(["--foo"])
      end
    end

    describe ".get_args_from_usage_lines" do
      it "gets a single argument" do
        DocParser::Util.parse_usage_lines(["usage: prog <args>"]).should eq(["<args>"])
      end
    end
  end
end

