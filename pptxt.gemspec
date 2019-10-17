Gem::Specification.new do |s|
    s.name = "pptxt"
    s.version = "0.3.14"
    s.date = Time.new.strftime("%Y-%m-%d")
    s.summary = "Converts pptx files to human-readable text"
    s.description = [
        "This gem can extract the xml info from a pptx file and",
        "convert it to human-readable text. It was intended to be",
        "used with git for seeing changes between revisions."
    ].join(" ")
    s.authors = ["Miles Whittaker"]
    s.email = "mj@whitta.dev"
    s.executables = Dir.chdir("bin") do
        Dir["*"]
    end
    s.files = Dir["lib/**/*.rb"]
    s.homepage = "https://gitlab.com/mjwhitta/pptxt"
    s.license = "GPL-3.0"
    s.add_development_dependency("minitest", "~> 5.12", ">= 5.12.2")
    s.add_development_dependency("rake", "~> 13.0", ">= 13.0.0")
    s.add_runtime_dependency("hilighter", "~> 1.3", ">= 1.3.0")
    s.add_runtime_dependency("scoobydoo", "~> 1.0", ">= 1.0.1")
end
