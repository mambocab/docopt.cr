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
end

