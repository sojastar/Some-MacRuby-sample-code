#
#  Vector.rb
#  MacRuby Cocoa OpenGL
#
###

class Vector

	attr_accessor :x, :y, :z

	def initialize(x, y, z)
		@x = x
		@y = y
		@z = z
	end

	def reverse
		return Vector.new(-@x, -@y, -@z)
	end

	def to_s
		"(#{@x.round(1)}, #{@y.round(1)}, #{@z.round(1)})"
	end

end
