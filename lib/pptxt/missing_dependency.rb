require "pptxt/error"

class PPtxt::MissingDependency < PPtxt::Error
    def initialize(tool)
        super("Missing dependency: #{tool}")
    end
end
