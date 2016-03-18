require "./spec_helper"
require "../src/docopt/parser.cr"

describe Parser do
  describe ".parse" do
    it "raises an error on an empty docstring" do
      expect_raises(Parser::Errors::InvalidDocstringException, "empty") do
        Parser.parse ""
      end
    end
  end

  describe Parser::Util do
    describe ".tokenize_option_line" do
      it "returns empty string on an empty string" do
        Parser::Util.tokenize_option_line("").should eq("")
      end

      it "returns the flag specified on the line" do
        Parser::Util.tokenize_option_line("-a").should eq("-a")
        Parser::Util.tokenize_option_line("-v").should eq("-v")
      end

      it "treats text after 2 spaces as a comment" do
        Parser::Util.tokenize_option_line("--verbose  This is a comment").should eq("--verbose")
      end

      it "ignores leading space" do
        Parser::Util.tokenize_option_line("         --verbose  This is a comment").should eq("--verbose")
      end
    end

    describe ".parse_option_lines" do
      it "returns an empty hash on an empty array" do
        Parser::Util.parse_option_lines([] of String).should eq([] of String)
      end

      it "gets rid of leading 'options:' strings" do
        Parser::Util.parse_option_lines(["options:  --foo"]).should eq(["--foo"])
      end

      it "works when comments include ':'" do
        Parser::Util.parse_option_lines(
          ["options:  --foo  Wizard: needs foo badly."]).should eq(["--foo"])
      end
    end

    describe ".get_args_from_usage_lines" do
      it "gets a single argument" do
        Parser::Util.parse_usage_lines(["usage: prog <args>"]).should eq(["<args>"])
      end
    end
  end
end

