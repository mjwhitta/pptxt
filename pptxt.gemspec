Gem::Specification.new do |s|
    s.name = "pptxt"
    s.version = "0.3.9"
    s.date = Time.new.strftime("%Y-%m-%d")
    s.summary = "Converts pptx files to human-readable text"
    s.description =
        "This gem can extract the xml info from a pptx file and " \
        "convert it to human-readable text. It was intended to be " \
        "used with git for seeing changes between revisions."
    s.authors = [ "Miles Whittaker" ]
    s.email = "mjwhitta@gmail.com"
    s.executables = Dir.chdir("bin") do
        Dir["*"]
    end
    s.files = Dir["lib/**/*.rb"]
    s.homepage = "https://mjwhitta.github.io/pptxt"
    s.license = "GPL-3.0"
    s.add_development_dependency("minitest", "~> 5.8", ">= 5.8.4")
    s.add_development_dependency("rake", "~> 10.5", ">= 10.5.0")
    s.add_runtime_dependency("hilighter", "~> 1.0", ">= 1.0.0")
    s.add_runtime_dependency("scoobydoo", "~> 0.1", ">= 0.1.4")
end
