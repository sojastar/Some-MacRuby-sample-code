#
#  Camera.rb
#  MacRuby Cocoa OpenGL
#
#  Created by Julien Jassaud on 28/02/09.
#  Copyright (c) 2009 IAMAS. All rights reserved.
#
###

class Camera

	attr_accessor	:view_position, :view_direction, :view_up,
					:rotation_point,
					:aperture,
					:view_width, :view_height

	def initialize
		reset
	end
	
	def reset
		
		@aperture = 40;
		@rotation_point = Vector.new(0.0, 0.0, 0.0)
		@view_position = Vector.new(0.0, 0.0, -10.0)
		@view_direction = @view_position.reverse
		@view_up = Vector.new(0, 1, 0)

	end

	def to_s
		"Camera at #{@view_position} looking at #{@view_direction} with #{@aperture.round(1)} aperture"
		
		
		
		#"aperture       : #{@aperture}\n" +
		#"rotation point : #{@rotation_point}\n" +
		#"view position  : #{@view_position}\n" +
		#"view direction : #{@view_direction}\n" +
		#"view up        : #{@view_up}\n"
	end

end
