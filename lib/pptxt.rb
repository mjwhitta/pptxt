require "scoobydoo"

class PPtxt
    attr_accessor :slides

    def self.configure_git(global = false)
        if (ScoobyDoo.where_are_you("git").nil?)
            raise PPtxt::Error::MissingDependency.new("git")
        end

        # Configure git
        flag = ""
        flag = "--global" if (global)
        system(
            "git config #{flag} diff.pptxt.textconv \"pptxt --git\""
        )

        # Setup .gitattributes
        filename = ".gitattributes"
        if (global)
            cfg = "git config --global core.attributesfile"
            filename = %x(#{cfg}).strip
            if (filename.nil? || filename.empty?)
                filename = "~/.gitattributes"
                system("#{cfg} \"#{filename}\"")
            end
        end
        new_line = "*.pptx diff=pptxt\n"

        file = Pathname.new(filename).expand_path
        if (file.exist?)
            File.open(file) do |f|
                f.each_line do |line|
                    if (line == new_line)
                        return
                    end
                end
            end
            File.open(file, "a") do |f|
                f.write(new_line)
            end
        else
            File.open(file, "w") do |f|
                f.write(new_line)
            end
        end
    end

    def create_slides
        if (ScoobyDoo.where_are_you("unzip").nil?)
            raise PPtxt::Error::MissingDependency.new("unzip")
        end

        count = 0
        %x(
            unzip -l "#{@pptx}" | \grep -E "ppt/slides/[^_]" |
            awk '{print $4}' | sort -k 1.17n
        ).split("\n").each do |slide|
            xml = %x(unzip -qc "#{@pptx}" #{slide}).gsub("<", "\n<")
            count += 1
            @slides.push(PPtxtSlide.new(xml, count))
        end
    end
    private :create_slides

    def initialize(pptx)
        if (!Pathname.new(pptx).expand_path.exist?)
            raise PPtxt::Error::FileNotFound.new(pptx)
        end

        @pptx = pptx
        @slides = Array.new
        create_slides
    end
end

require "pptxt/error"
require "pptxt/slide"
