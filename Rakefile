require "rake/testtask"

task :default => :gem

desc "Clean up"
task :clean do
    system("rm -f *.gem Gemfile.lock")
    system("chmod -R go-rwx bin lib")
end

desc "Test example project"
task :ex => :install do
    system("pptxt -s test/test.pptx")
end

desc "Build gem"
task :gem do
    system("chmod -R u=rwX,go=rX bin lib")
    system("gem build pptxt.gemspec")
end

desc "Build and install gem"
task :install => :gem do
    system("gem install pptxt*.gem")
end

desc "Push gem to rubygems.org"
task :push => [:clean, :gem] do
    system("gem push pptxt*.gem")
end

desc "Run tests"
Rake::TestTask.new do |t|
    t.libs << "test"
end
