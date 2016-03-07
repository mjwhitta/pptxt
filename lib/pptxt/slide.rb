class PPtxt::PPtxtSlide
    def detailed
        ret = Array.new
        num_indents = 0

        @xml.each_line do |line|
            line.strip!
            indents = Array.new(num_indents, "  ").join

            case line
            when %r{^<\?.+$}, ""
                # Ignore xml version and blank lines
            when %r{^<.+/> *$}, %r{^<[^/].+>.*</.+> *$}
                # Don't indent if one-liner
                ret.push("#{indents}#{line}")
            when %r{^<[^/].+$}
                # Indent after opening tag
                ret.push("#{indents}#{line}")
                num_indents += 1
            when %r{^</.+> *$}
                # Remove indent after closing tag
                num_indents -= 1
                indents = Array.new(num_indents, "  ").join
                ret.push("#{indents}#{line}")
            else
                raise PPtxt::Error::UnknownXML.new(line)
            end
        end

        return ret.join("\n")
    end

    def diffable
        out = Array.new
        out.push(@title) if (!@title.empty?)
        out.push(@subtitle) if (!@subtitle.empty?)
        out.push("\n") if (!@title.empty? || !@subtitle.empty?)
        out.push(@content) if (!@content.empty?)
        return out.join.strip
    end

    def handle_format(str, format, lvl, list_index)
        filler = Array.new(lvl, "  ").join
        case format
        when "bullet"
            return "#{filler}- #{str}"
        when "number"
            return "#{filler}#{list_index}. #{str}"
        else
            return str
        end
    end
    private :handle_format

    def initialize(xml, count)
        @content = ""
        @count = count
        @subtitle = ""
        @title = ""
        @xml = xml
        parse_xml
    end

    def parse_xml
        can_be_newline = false
        first_time = false
        ignore = false
        in_subtitle = false
        in_title = false
        was_newline = true

        format = "bullet"
        lvl = 0
        numlist_count = Array.new

        @xml.each_line do |raw_line|
            line = raw_line.strip
            raw_line.gsub!(/^ *<a:t>/, "")
            raw_line.gsub!(/[\n\r]$/, "")

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
                @title += "# "
            when %r{<p:cNvPr .*Subtitle}
                # Setup subtitles
                in_subtitle = true
                first_time = true
                @subtitle += "## "
            when %r{<a:t>.*}
                # Handle text
                if (in_title)
                    @title += "  " if (!first_time && was_newline)
                    @title += raw_line
                elsif (in_subtitle)
                    if (!first_time && was_newline)
                        @subtitle += "   "
                    end
                    @subtitle += raw_line
                elsif(ignore)
                    break
                else
                    if (was_newline)
                        list_index = numlist_count[lvl] || 1
                        @content += handle_format(
                            raw_line,
                            format,
                            lvl,
                            list_index
                        )
                        if (format == "number")
                            numlist_count[lvl] = list_index + 1
                        end
                    else
                        @content += raw_line
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
                    @title += "\n" if (can_be_newline)
                elsif (in_subtitle)
                    @subtitle += "\n" if (can_be_newline)
                elsif(ignore)
                    break
                else
                    @content += "\n" if (can_be_newline)
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
    end
    private :parse_xml

    def to_s()
        div = Array.new(70, "-").join
        out = Array.new
        out.push("#{div}\n")
        out.push(@title) if (!@title.empty?)
        out.push(@subtitle) if (!@subtitle.empty?)
        out.push("\n") if (!@title.empty? || !@subtitle.empty?)
        out.push(@content) if (!@content.empty?)
        out.push("#{div} #{@count}\n")
        return out.join.strip
    end
end
