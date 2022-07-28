require "./spec_helper"

include StumpyCore

describe StumpyCore do

  describe "Canvas(RGBA)" do
    describe ".new" do
      it "throws an error if the size is to big" do
        size = 2**30
        expect_raises(Exception) do
          canvas = Canvas(RGBA).new(size, size)
        end
      end

      it "uses default initial value for color if none provided" do
        size = 3
        canvas = Canvas(RGBA).new(size, size)
        (0...size).each do |x|
          (0...size).each do |y|
            canvas.get(x, y).should eq RGBA.new(0_u16, 0_u16, 0_u16, 0_u16)
          end
        end
      end
    end

    describe "#get" do
      it "gets the color value of a particular pixel location" do
        size = 3
        canvas1 = Canvas(RGBA).new(size, size)
        canvas2 = Canvas(RGBA).new(size, size) {RGBA.new(0_u16, 0_u16, 0_u16, 0_u16)}

        (0...size).each do |x|
          (0...size).each do |y|
            canvas1.get(x, y).should eq canvas2.get(x, y)
          end
        end
      end
    end

    describe "#set" do
      it "sets a pixel to specified color" do
        size = 3
        canvas1 = Canvas(RGBA).new(size, size)

        (0...size).each do |x|
          (0...size).each do |y|
            canvas1.set(x, y, RGBA::ORANGE)
          end
        end

        canvas2 = Canvas(RGBA).new(size, size) {RGBA::ORANGE}

        (0...size).each do |x|
          (0...size).each do |y|
            canvas1.get(x, y).should eq canvas2.get(x, y)
          end
        end
      end
    end

    describe "#each_row" do
      it "iterates over each row of the canvas" do
        size = 3
        canvas = Canvas(RGBA).new(size, size)
        canvas.each_row {|row| row[1] = RGBA::GREEN; row[2] = RGBA::BLUE }
        canvas[0, 0].should eq(RGBA.new)
        canvas[1, 1].should eq(RGBA::GREEN)
        canvas[2, 2].should eq(RGBA::BLUE)
      end
    end

    describe "#includes_pixel?" do
      it "checks if a pixel is out of bounds" do
        size = 3
        canvas = Canvas(RGBA).new(size, size)

        canvas.includes_pixel?(2, 2).should be_true
        canvas.includes_pixel?(3, 3).should be_false
      end
    end

    describe "#map" do
      it "maps each pixel color to a diff color" do
        size = 3
        canvas = Canvas(RGBA).new(size, size)
        res = canvas.map_with_index {|p, x, y| (x+y).even? ? RGBA::BLACK : RGBA::WHITE }
        canvas[0, 0].should eq(RGBA.new)
        canvas[1, 0].should eq(RGBA.new)
        canvas[0, 1].should eq(RGBA.new)
        canvas[2, 2].should eq(RGBA.new)
        res[0, 0].should eq(RGBA::BLACK)
        res[1, 0].should eq(RGBA::WHITE)
        res[0, 1].should eq(RGBA::WHITE)
        res[2, 2].should eq(RGBA::BLACK)
      end
    end

    describe "#map!" do
      it "changes each pixel color to a diff color" do
        size = 3
        canvas = Canvas(RGBA).new(size, size)
        canvas.map! {|p, x, y| (x+y).even? ? RGBA::BLACK : RGBA::WHITE }
        canvas[0, 0].should eq(RGBA::BLACK)
        canvas[1, 0].should eq(RGBA::WHITE)
        canvas[0, 1].should eq(RGBA::WHITE)
        canvas[2, 2].should eq(RGBA::BLACK)
      end
    end

    describe "#map_with_index" do
      it "maps each pixel color and index to a diff color" do
        size = 3
        canvas = Canvas(RGBA).new(size, size, RGBA::RED)
        res = canvas.map_with_index {|p, x, y, i| i.even? ? RGBA::BLACK : RGBA::WHITE }
        canvas[0, 0].should eq(RGBA::RED)
        canvas[1, 0].should eq(RGBA::RED)
        canvas[0, 1].should eq(RGBA::RED)
        res[0, 0].should eq(RGBA::BLACK)
        res[1, 0].should eq(RGBA::WHITE)
        res[0, 1].should eq(RGBA::WHITE)
      end
    end

    describe "#map_with_index!" do
      it "changes each pixel color and index to a diff color" do
        size = 3
        canvas = Canvas(RGBA).new(size, size, RGBA::RED)
        canvas.map_with_index! {|p, x, y, i| i.even? ? RGBA::BLACK : RGBA::WHITE }
        canvas[0, 0].should eq(RGBA::BLACK)
        canvas[1, 0].should eq(RGBA::WHITE)
        canvas[0, 1].should eq(RGBA::WHITE)
      end
    end

    describe "#==" do
      it "checks if 2 canvases are equal" do
        side = 3
        other_side = 4
        canvas1 = Canvas(RGBA).new(side, side)
        canvas2 = Canvas(RGBA).new(side, side, RGBA.new(0_u16, 0_u16, 0_u16, 0_u16))
        canvas3 = Canvas(RGBA).new(side, side, RGBA::WHITE)
        canvas4 = Canvas(RGBA).new(side, other_side, RGBA.new(0_u16, 0_u16, 0_u16, 0_u16))
        canvas5 = Canvas(RGBA).new(other_side, side, RGBA.new(0_u16, 0_u16, 0_u16, 0_u16))

        (canvas1 == canvas3).should be_false
        (canvas1 == canvas4).should be_false
        (canvas1 == canvas5).should be_false
        (canvas1 == canvas2).should be_true
      end
    end

    describe "#paste" do
      it "pastes the contents of another canvas into this canvas starting at x, y" do
        size1 = 7
        size2 = 3
        canvas1 = Canvas(RGBA).new(size1, size1)
        canvas2 = Canvas(RGBA).new(size2, size2, RGBA::WHITE)

        canvas1.paste(canvas2, 2, 2)

        canvas1[0, 0].should eq(RGBA.new)
        canvas1[1, 0].should eq(RGBA.new)
        canvas1[0, 1].should eq(RGBA.new)
        canvas1[2, 2].should eq(RGBA::WHITE)
        canvas1[3, 4].should eq(RGBA::WHITE)
        canvas1[3, 2].should eq(RGBA::WHITE)
        canvas1[6, 6].should eq(RGBA.new)
        canvas1[6, 5].should eq(RGBA.new)
        canvas1[5, 1].should eq(RGBA.new)

        (0...size2).each do |x|
          (0...size2).each do |y|
            canvas2.get(x, y).should eq RGBA::WHITE
          end
        end
      end
    end
  end

  describe "Canvas(G)" do
    describe ".new" do
      it "throws an error if the size is to big" do
        size = 2**30
        expect_raises(Exception) do
          canvas = Canvas(G).new(size, size)
        end
      end

      it "uses default initial value for gray if none provided" do
        size = 3
        canvas = Canvas(G).new(size, size)
        (0...size).each do |x|
          (0...size).each do |y|
            canvas.get(x, y).should eq G.new(0_u16)
          end
        end
      end
    end

    describe "#get" do
      it "gets the color value of a particular pixel location" do
        size = 3
        canvas1 = Canvas(G).new(size, size)
        canvas2 = Canvas(G).new(size, size) {G.new(0_u16)}

        (0...size).each do |x|
          (0...size).each do |y|
            canvas1.get(x, y).should eq canvas2.get(x, y)
          end
        end
      end
    end

    describe "#set" do
      it "sets a pixel to specified color" do
        size = 3
        canvas1 = Canvas(G).new(size, size)

        (0...size).each do |x|
          (0...size).each do |y|
            canvas1.set(x, y, G::SILVER)
          end
        end

        canvas2 = Canvas(G).new(size, size) {G::SILVER}

        (0...size).each do |x|
          (0...size).each do |y|
            canvas1.get(x, y).should eq canvas2.get(x, y)
          end
        end
      end
    end

    describe "#each_row" do
      it "iterates over each row of the canvas" do
        size = 3
        canvas = Canvas(G).new(size, size)
        canvas.each_row {|row| row[1] = G::WHITE; row[2] = G::BLACK }
        canvas[0, 0].should eq(G.new)
        canvas[1, 1].should eq(G::WHITE)
        canvas[2, 2].should eq(G::BLACK)
      end
    end

    describe "#includes_pixel?" do
      it "checks if a pixel is out of bounds" do
        size = 3
        canvas = Canvas(G).new(size, size)

        canvas.includes_pixel?(2, 2).should be_true
        canvas.includes_pixel?(3, 3).should be_false
      end
    end

    describe "#map" do
      it "maps each pixel color to a diff color" do
        size = 3
        canvas = Canvas(G).new(size, size)
        res = canvas.map_with_index {|p, x, y| (x+y).even? ? G::BLACK : G::WHITE }
        canvas[0, 0].should eq(G.new)
        canvas[1, 0].should eq(G.new)
        canvas[0, 1].should eq(G.new)
        canvas[2, 2].should eq(G.new)
        res[0, 0].should eq(G::BLACK)
        res[1, 0].should eq(G::WHITE)
        res[0, 1].should eq(G::WHITE)
        res[2, 2].should eq(G::BLACK)
      end
    end

    describe "#map!" do
      it "changes each pixel color to a diff color" do
        size = 3
        canvas = Canvas(G).new(size, size)
        canvas.map! {|p, x, y| (x+y).even? ? G::BLACK : G::WHITE }
        canvas[0, 0].should eq(G::BLACK)
        canvas[1, 0].should eq(G::WHITE)
        canvas[0, 1].should eq(G::WHITE)
        canvas[2, 2].should eq(G::BLACK)
      end
    end

    describe "#map_with_index" do
      it "maps each pixel color and index to a diff color" do
        size = 3
        canvas = Canvas(G).new(size, size, G::GRAY)
        res = canvas.map_with_index {|p, x, y, i| i.even? ? G::BLACK : G::WHITE }
        canvas[0, 0].should eq(G::GRAY)
        canvas[1, 0].should eq(G::GRAY)
        canvas[0, 1].should eq(G::GRAY)
        res[0, 0].should eq(G::BLACK)
        res[1, 0].should eq(G::WHITE)
        res[0, 1].should eq(G::WHITE)
      end
    end

    describe "#map_with_index!" do
      it "changes each pixel color and index to a diff color" do
        size = 3
        canvas = Canvas(G).new(size, size)
        canvas.map_with_index! {|p, x, y, i| i.even? ? G::BLACK : G::WHITE }
        canvas[0, 0].should eq(G::BLACK)
        canvas[1, 0].should eq(G::WHITE)
        canvas[0, 1].should eq(G::WHITE)
      end
    end

    describe "#==" do
      it "checks if 2 canvases are equal" do
        side = 3
        other_side = 4
        canvas1 = Canvas(G).new(side, side)
        canvas2 = Canvas(G).new(side, side, G.new(0_u16))
        canvas3 = Canvas(G).new(side, side, G::WHITE)
        canvas4 = Canvas(G).new(side, other_side, G.new(0_u16))
        canvas5 = Canvas(G).new(other_side, side, G.new(0_u16))
        canvas6 = Canvas(RGBA).new(side, side)

        (canvas1 == canvas3).should be_false
        (canvas1 == canvas4).should be_false
        (canvas1 == canvas5).should be_false
        (canvas1 == canvas6).should be_false
        (canvas1 == canvas2).should be_true
      end
    end

    describe "#paste" do
      it "pastes the contents of another canvas into this canvas starting at x, y" do
        size1 = 7
        size2 = 3
        canvas1 = Canvas(G).new(size1, size1)
        canvas2 = Canvas(G).new(size2, size2, G::WHITE)

        canvas1.paste(canvas2, 2, 2)

        canvas1[0, 0].should eq(G.new)
        canvas1[1, 0].should eq(G.new)
        canvas1[0, 1].should eq(G.new)
        canvas1[2, 2].should eq(G::WHITE)
        canvas1[3, 4].should eq(G::WHITE)
        canvas1[3, 2].should eq(G::WHITE)
        canvas1[6, 6].should eq(G.new)
        canvas1[6, 5].should eq(G.new)
        canvas1[5, 1].should eq(G.new)

        (0...size2).each do |x|
          (0...size2).each do |y|
            canvas2.get(x, y).should eq G::WHITE
          end
        end
      end
    end
  end

  describe RGBA do
    describe ".new" do
      it "creates a RGBA value from 16bit values for red, green, blue" do
        rgba = RGBA.new(32_u16, 156_u16, 221_u16)
        rgba.red.should eq 32_u16
        rgba.green.should eq 156_u16
        rgba.blue.should eq 221_u16
        rgba.alpha.should eq UInt16::MAX
      end

      it "creates a RGBA value from 16bit values for grayscale" do
        rgba = RGBA.new(156_u16, 156_u16)
        rgba.red.should eq 156_u16
        rgba.green.should eq 156_u16
        rgba.blue.should eq 156_u16
        rgba.alpha.should eq 156_u16
      end

      it "creates a placeholder RGBA value from nothing" do
        rgba = RGBA.new
        rgba.red.should eq 0_u16
        rgba.green.should eq 0_u16
        rgba.blue.should eq 0_u16
        rgba.alpha.should eq 0_u16
      end

    end

    describe ".from_relative" do
      it "is reversible" do
        tuple = {0.2, 0.4, 0.6, 0.8}
        color = RGBA.from_relative(tuple)
        color.to_relative.should eq(tuple)
      end
    end

    describe ".from_hex" do
      it "handles shorthands" do
        a = RGBA.from_hex("#123")
        b = RGBA.from_hex("#112233")

        a.should eq(b)
      end

      it "handles colors w/ alpha" do
        a = RGBA.from_hex("#F123")
        b = RGBA.from_hex("#FF112233")

        a.should eq(b)
        b.should eq(RGBA.from_hex("#112233"))
      end
    end

    describe ".from_gray_n" do
      it "handles 1-bit values" do
        RGBA.from_gray_n(0, 1).should eq(RGBA::BLACK)
        RGBA.from_gray_n(1, 1).should eq(RGBA::WHITE)
      end

      it "handles 8-bit values" do
        RGBA.from_gray_n(0, 8).should eq(RGBA::BLACK)
        RGBA.from_gray_n(255, 8).should eq(RGBA::WHITE)

        v = 180
        color = RGBA.from_gray_n(v, 8)
        color.r.should eq(UInt16::MAX / 255 * v)
      end
    end

    describe ".from_rgb_n" do
      it "handles 1-bit values" do
        RGBA.from_rgb_n({0, 0, 0}, 1).should eq(RGBA::BLACK)
        RGBA.from_rgb_n({1, 0, 0}, 1).should eq(RGBA::RED)
        RGBA.from_rgb_n({1, 1, 1}, 1).should eq(RGBA::WHITE)
      end

      it "handles 8-bit values" do
        c = RGBA.from_hex("#abcdef")
        vs = c.to_rgb8
        RGBA.from_rgb_n(vs, 8).should eq(c)
      end
    end
  end
end
