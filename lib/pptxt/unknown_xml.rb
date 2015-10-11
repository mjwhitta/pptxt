require "pptxt/error"

class PPtxt::UnknownXML < PPtxt::Error
    def initialize(line)
        super("Unknown line in xml: #{line}")
    end
end
