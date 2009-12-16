#
#  cube.rb
#  MacRuby Cocoa OpenGL
#
###

class Cube

	attr_accessor	:vertice_number,
					:vertices,
					:vertex_colors,
					:faces_number,
					:faces

					

	def initialize

		# Initializing the cube geometry :

		@vertice_number	= 8

		@vertices		= [	[ 1.0,  1.0,  1.0],
							[ 1.0, -1.0,  1.0],
							[-1.0, -1.0,  1.0],
							[-1.0,  1.0,  1.0],
							[ 1.0,  1.0, -1.0],
							[ 1.0, -1.0, -1.0],
							[-1.0, -1.0, -1.0],
							[-1.0,  1.0, -1.0] ]

		@vertex_colors	= [	[1.0, 1.0, 1.0],
							[1.0, 1.0, 0.0],
							[0.0, 1.0, 0.0],
							[0.0, 1.0, 1.0],
							[1.0, 0.0, 1.0],
							[1.0, 0.0, 0.0],
							[0.0, 0.0, 0.0],
							[0.0, 0.0, 1.0] ]

		@faces_number	= 6

		@faces			= [	[3, 2, 1, 0],
							[2, 3, 7, 6],
							[0, 1, 5, 4],
							[3, 0, 4, 7],
							[1, 2, 6, 5],
							[4, 5, 6, 7] ]

	end

end
