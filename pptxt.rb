#!/usr/bin/env ruby

require "optparse"
require "pathname"

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

def output(lines)
    can_be_newline = false
    first_time = false
    ignore = false
    in_subtitle = false
    in_title = false
    was_newline = false

    lines.each do |line|
        case line
        when %r{<p:cNvPr .*Title}
            # Handle titles
            in_title = true
            first_time = true
            print "# "
        when %r{<p:cNvPr .*Subtitle}
            # Handle subtitles
            in_subtitle = true
            first_time = true
            print "## "
        when %r{<a:t>.*}
            break if (ignore)

            # Handle text
            print "  " if (in_title && !first_time && was_newline)
            print "   " if (in_subtitle && !first_time && was_newline)
            print line[5..-1]

            first_time = false
            was_newline = false
        when "</a:t>"
            # Handle newlines
            can_be_newline = true
        when "</p:txBody>"
            # Handle newlines
            puts

            can_be_newline = false
            was_newline = true
            in_title = false
            in_subtitle = false
        when "<a:br>", "</a:p>"
            # Handle newlines
            puts if (can_be_newline)

            can_be_newline = false
            was_newline = true
        when "<p:graphicFrame>"
            ignore = true
        when "</p:graphicFrame>"
            ignore = false
        else
            # Ignore
        end
    end
    puts
end

def parse(args)
    options = Hash.new
    options["detailed"] = false
    options["global"] = false
    options["init"] = false
    parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [OPTIONS] [pptx]"

        opts.on("-d", "--detailed", "Display full xml") do
            options["detailed"] = true
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
    system("git config #{global} diff.pptxt.textconv pptxt")

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
slides.each do |slide|
    # Extract xml data
    xml_data = %x(unzip -qc "#{pptx}" #{slide})

    lines = xml_data.gsub("<", "\n<").split("\n")
    if (options["detailed"])
        # Display full xml
        detailed_output(lines)
    else
        # Make it human readable and parse
        output(lines)
    end
end
