require "./utils"
require "./g/*"

module StumpyCore
  # A `RGBA` is made up of four components:
  # `red`, `green`, `blue` and `alpha`,
  # each with a resolution of 16 bit.
  #
  # All 148 [Named CSS Colors](https://www.quackit.com/css/css_color_codes.cfm)
  # are available as constants.
  struct G
    getter g : UInt16

    def initialize
      @g = 0_u16
    end

    # Create a RGBA value
    # from 16bit (`UInt16`)
    # values for red, green, blue and
    # optionally alpha.
    # Alpha defaults to 100% opacity.
    def initialize(@g)
    end

    def gray
      @g
    end
  end
end
