class PPtxt::Error < RuntimeError
end

require "pptxt/error/file_not_found"
require "pptxt/error/missing_dependency"
require "pptxt/error/unknown_xml"
