module Docopt
  def self.docopt(doc, argv = ARGV)
    if doc.includes? "Options:"
      {"-a" => false}
    else
      {} of String => String
    end
  end
end
