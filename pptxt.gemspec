Gem::Specification.new do |s|
    s.add_development_dependency("minitest", "~> 5.12", ">= 5.12.2")
    s.add_development_dependency("rake", "~> 13.0", ">= 13.0.0")
    s.add_runtime_dependency("hilighter", "~> 1.5", ">= 1.5.1")
    s.add_runtime_dependency("scoobydoo", "~> 1.0", ">= 1.0.1")
    s.authors = ["Miles Whittaker"]
    s.date = Time.new.strftime("%Y-%m-%d")
    s.description = [
        "This gem can extract the xml info from a pptx file and",
        "convert it to human-readable text. It was intended to be",
        "used with git for seeing changes between revisions."
    ].join(" ")
    s.email = "mj@whitta.dev"
    s.executables = Dir.chdir("bin") do
        Dir["*"]
    end
    s.files = Dir["lib/**/*.rb"]
    s.homepage = "https://github.com/mjwhitta/pptxt"
    s.license = "GPL-3.0"
    s.metadata = {"source_code_uri" => s.homepage}
    s.name = "pptxt"
    s.summary = "Converts pptx files to human-readable text"
    s.version = "0.3.15"
end
