module PPtxt
    class Error < RuntimeError
    end

    class MissingDependency < Error
        def initialize(tool)
            super("Missing dependency: #{tool}")
        end
    end

    class UnknownXML < Error
        def initialize(line)
            super("Unknown line in xml: #{line}")
        end
    end
end
