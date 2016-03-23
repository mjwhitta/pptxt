class PPtxt::Error::MissingDependency < PPtxt::Error
    def initialize(tool)
        super("Missing dependency: #{tool}")
    end
end
