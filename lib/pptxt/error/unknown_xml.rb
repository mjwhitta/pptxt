class PPtxt::Error::UnknownXML < PPtxt::Error
    def initialize(line)
        super("Unknown line in xml: #{line}")
    end
end
