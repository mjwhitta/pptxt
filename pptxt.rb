#!/usr/bin/env ruby

require "optparse"
require "pathname"

class Slide < Hash
    def content(content = nil)
        self["content"] = content if (content)
        self["content"] = nil if (content && content.empty?)
        return self["content"]
    end

    def initialize(title = nil, subtitle = nil, content = nil)
        self.title(title)
        self.subtitle(subtitle)
        self.content(content)
    end

    def subtitle(subtitle = nil)
        self["subtitle"] = subtitle if (subtitle)
        self["subtitle"] = nil if (subtitle && subtitle.empty?)
        return self["subtitle"]
    end

    def title(title = nil)
        self["title"] = title if (title)
        self["title"] = nil if (title && title.empty?)
        return self["title"]
    end

    def to_s()
        out = []
        out.push(title) if (title)
        out.push(subtitle) if (subtitle)
        out.push("\n") if (title || subtitle)
        out.push(content) if (content)
        return out.join.strip
    end
end

def detailed_output(lines)
    num_indents = 0
    lines.each do |line|
        indents = Array.new(num_indents, "  ").join
        case line
        when %r{^<\?.*$}, ""
            # Ignore xml version and blank lines
        when %r{^<.*/>$}
            # Don't indent if one-liner
            puts "#{indents}#{line}"
        when %r{^<[^/].*$}
            # Indent after opening tag
            puts "#{indents}#{line}"
            num_indents += 1
        when %r{^</.*$}
            # Remove indent after closing tag
            num_indents -= 1
            indents = Array.new(num_indents, "  ").join
            puts "#{indents}#{line}"
        else
            # Log unsupported format
            puts "UNSUPPORTED FORMAT: #{line}"
        end
    end
end

def handle_format(str, format, lvl)
    case format
    when "bullet"
        return "#{Array.new(lvl, "  ").join}- #{str}"
    when "number"
        return "#{Array.new(lvl, "  ").join}1. #{str}"
    else
        return str
    end
end

def output(lines, git = false, count = 0)
    can_be_newline = false
    first_time = false
    ignore = false
    in_subtitle = false
    in_title = false
    was_newline = true

    title = ""
    subtitle = ""
    content = ""

    divider = Array.new(70, "_").join

    format = "bullet"
    lvl = 0

    lines.each do |line|
        case line
        when "<a:p>"
            # Assume bullet list
            format = "bullet"
        when %r{<a:pPr.*lvl="[^"]+".*}
            # Sub bullet/item
            lvl = line[%r{<a:pPr.*lvl="([^"]+)".*}, 1].to_i
        when %r{<.?a:buNone}
            # Regular text
            format = "text"
        when %r{<.?a:buAutoNum}
            # Numbered list
            format = "number"
        when %r{<p:cNvPr .*Title}
            # Setup titles
            in_title = true
            first_time = true
            title += "# "
        when %r{<p:cNvPr .*Subtitle}
            # Setup subtitles
            in_subtitle = true
            first_time = true
            subtitle += "## "
        when %r{<a:t>.*}
            # Handle text
            if (in_title)
                title += "  " if (!first_time && was_newline)
                title += line[5..-1]
            elsif (in_subtitle)
                subtitle += "   " if (!first_time && was_newline)
                subtitle += line[5..-1]
            elsif(ignore)
                break
            else
                if (was_newline)
                    content += handle_format(line[5..-1], format, lvl)
                else
                    content += line[5..-1]
                end
            end

            first_time = false
            was_newline = false
            lvl = 0
        when "</a:t>"
            # Setup newlines
            can_be_newline = true
        when "<a:br>", "</a:p>", "</p:txBody>"
            # Handle newlines
            if (in_title)
                title += "\n" if (can_be_newline)
            elsif (in_subtitle)
                subtitle += "\n" if (can_be_newline)
            elsif(ignore)
                break
            else
                content += "\n" if (can_be_newline)
            end

            can_be_newline = false
            was_newline = true

            if (line == "</p:txBody>")
                in_title = false
                in_subtitle = false
            end
        when "<p:graphicFrame>"
            # Ignore graphics for now
            # FIXME
            ignore = true
        when "</p:graphicFrame>"
            ignore = false
        else
            # Ignore
        end
    end
    puts divider if (!git)
    puts Slide.new(title, subtitle, content)
    if (count > 0)
        puts "#{divider}#{count}" if (!git)
    else
        puts divider if (!git)
    end
    puts
    puts
end

def parse(args)
    options = Hash.new
    options["detailed"] = false
    options["git"] = false
    options["global"] = false
    options["init"] = false
    parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [OPTIONS] [pptx]"

        opts.on("-d", "--detailed", "Display full xml") do
            options["detailed"] = true
        end

        opts.on("--git", "Hide the slide dividers for git-diff") do
            options["git"] = true
        end

        opts.on(
            "-g",
            "--global-init",
            "Configure git to use pptxt globally"
        ) do
            options["init"] = true
            options["global"] = true
        end

        opts.on("-h", "--help", "Display this help message") do
            puts opts
            exit
        end

        opts.on("-i", "--init", "Initialize git repo to use pptxt") do
            options["init"] = true
        end
    end
    parser.parse!

    if (args.length > 0)
        if (!Pathname.new(args[0]).expand_path.exist?)
            puts "#{args[0]} does not exist!"
            exit 2
        end

        options["pptx"] = args[0]
    end

    return options
end

# Cross-platform way of finding an executable in the $PATH.
def which(cmd)
    exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
    ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            if (File.executable?(exe) && !File.directory?(exe))
                return true
            end
        end
    end
    return false
end

if (!which("unzip"))
    puts "Please install the unzip utility and try again!"
    exit 3
end

# Parse cli args
options = parse(ARGV)

# Initialize git config if specified
if (options["init"])
    # Configure git
    global = ""
    global = "--global" if (options["global"])
    system("git config #{global} diff.pptxt.textconv \"pptxt --git\"")

    # Setup .gitattributes
    filename = ".gitattributes"
    if (options["global"])
        global_cfg = "git config --global"
        filename = %x(#{global_cfg} core.attributesfile).strip
        if (filename.nil? || filename.empty?)
            filename = Pathname.new("~/.gitattributes").expand_path
            system(
                "#{global_cfg} core.attributesfile \"#{filename}\""
            )
        end
    end
    new_line = "*.pptx diff=pptxt\n"

    if (Pathname.new(filename).expand_path.exist?)
        File.open(filename) do |f|
            f.each_line do |line|
                if (line == new_line)
                    exit
                end
            end
        end
        File.open(filename, "a") do |f|
            f.write(new_line)
        end
    else
        File.open(filename, "w") do |f|
            f.write(new_line)
        end
    end

    exit
end

# Handle empty/null input
if (!options.has_key?("pptx"))
    exit
end
pptx = options["pptx"].strip
if (pptx == "/dev/null")
    exit
end

# Get list of slides
slides = %x(
    unzip -l "#{pptx}" | \grep -E "ppt/slides/[^_]" |
        awk '{print $4}' | sort -k 1.17n
).split("\n")

# Loop through slides
count = 0
slides.each do |slide|
    # Extract xml data
    xml_data = %x(unzip -qc "#{pptx}" #{slide})

    lines = xml_data.gsub("<", "\n<").split("\n")
    if (options["detailed"])
        # Display full xml
        detailed_output(lines)
    else
        # Make it human readable and parse
        count += 1
        output(lines, options["git"], count)
    end
end
