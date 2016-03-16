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
  end
end
