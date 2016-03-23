class PPtxt::Error::FileNotFound < PPtxt::Error
    def initialize(file)
        super("File not found: #{file}")
    end
end
