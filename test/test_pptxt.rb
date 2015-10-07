require "minitest/autorun"
require "pathname"
require "pptxt"

class PPtxtTest < Minitest::Test
    def setup
        @pptx = Pathname.new("test/test.pptx").expand_path
        @slides = PPtxt.new(@pptx).slides
    end

    def test_pptxt
        assert_equal(4, @slides.length)
    end
end
