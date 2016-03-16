require "./spec_helper"
require "../src/docopt.cr"

describe Docopt do
  describe "#docopt" do
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

    pending "parses arbitrary option names" do
      docstring = "Usage: prog [options]\n"\
                  "\n"\
                  "Options: -b  All.\n"\
                  "\n"
      Docopt.docopt(docstring, argv: [] of String).should eq({"-b" => false})
    end
  end
end

describe DocoptUtil::StringUtil do
  describe "#get_option_lines" do
    pending "returns the empty string if there is no 'options:' section" do
      DocoptUtil::StringUtil.get_option_lines("Usage: prog\n\n").should eq([] of String)
    end

    pending "finds the 'options:' section on simple 2-part docstring" do
      docstring = "Usage: prog [options]\n"\
                  "\n"\
                  "Options: -b  All.\n"\
                  "\n"
    end
  end
end

describe DocoptUtil::ArrayUtil do
  describe "#take_chunks_starting_with_selected" do
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

  end

  describe "#indices_where" do
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
