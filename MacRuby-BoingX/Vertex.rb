#
#  Vertex.rb
#  MacRuby BoingX
#
###

class Vertex

	attr_accessor	:x, :y, :z,
					:nx, :ny, :nz,
					:r, :g, :b, :a

	def to_s
		"coordinates : (#{@x}, #{@y}, #{@z}) | normal (#{@nx}, #{@ny}, #{@nz}) | color (#{@r}, #{@g}, #{@b}, #{@a})"
	end

end