#
#  Trackball.rb
#  MacRuby Cocoa OpenGL
#
###

class Trackball

	include	Rotation



	attr_accessor	:radius,
					:start_point, :end_point,
					:x_center, :y_center,
					:rotation





	# Start up the trackball.  The trackball works by pretending that a ball
    # encloses the 3D view.  You roll this pretend ball with the mouse.  For
    # example, if you click on the center of the ball and move the mouse straight
    # to the right, you roll the ball around its Y-axis.  This produces a Y-axis
    # rotation.  You can click on the "edge" of the ball and roll it around
    # in a circle to get a Z-axis rotation.
    #   
    # The math behind the trackball is simple: start with a vector from the first
    # mouse-click on the ball to the center of the 3D view.  At the same time, set the
	# radius of the ball to be the smaller dimension of the 3D view.  As you drag the
	# mouse around in the 3D view, a second vector is computed from the surface of the
	# ball to the center.  The axis of rotation is the cross product of these two
	# vectors, and the angle of rotation is the angle between the two vectors.
	#
	###
	def initialize
		@rotation	= [0.0, 0.0, 0.0, 0.0]
	end





	# Setting up the trackball
	#
	###
	def set(x, y, x_origin, y_origin, width, height)

		@rotation	= [0.0, 0.0, 0.0, 0.0]

		if width > height then
			@radius = width * 0.5
		else
			@radius = height * 0.5
		end


		# Figure the center of the view :
		@x_center = x_origin + width * 0.5
		@y_center = y_origin + height * 0.5

    
		# Compute the starting vector from the surface of the ball to its center :
		@start_point = []
		@start_point[0] = x - @x_center
		@start_point[1] = y - @y_center

		distance = @start_point[0]*@start_point[0] + @start_point[1]*@start_point[1]

		if distance > @radius*@radius then	# Outside the sphere :
			@start_point[2] = 0
		else
			@start_point[2] = Math.sqrt(@radius*@radius - distance)
		end


		# Initializing the end point array :
		@end_point = []

	end





	# Update to new mouse position, output rotation angle.
	# 'rotation' is the output rotation angle.
	#
	###
	def roll_to(x, y)

		@end_point[0]	= x - @x_center
		@end_point[1]	= y - @y_center


		# Not enough change in the vectors to have an action ?
		if (@end_point[0] - @start_point[0]).abs < TOL and (@end_point[1] - @start_point[1]).abs < TOL then
			return
		end


		# Compute the ending vector from the surface of the ball to its center :
		distance = @end_point[0] * @end_point[0] + @end_point[1] * @end_point[1]

		if distance > @radius * @radius then
			@end_point[2]	= 0
		else
			@end_point[2]	= Math.sqrt(@radius * @radius - distance)
		end


		# Take the cross product of the two vectors. r = s X e :
		@rotation[1]	=  @start_point[1] * @end_point[2] - @start_point[2] * @end_point[1]
		@rotation[2]	= -@start_point[0] * @end_point[2] + @start_point[2] * @end_point[0]
		@rotation[3]	=  @start_point[0] * @end_point[1] - @start_point[1] * @end_point[0]


		# Use atan for a better angle.  If you use only cos or sin, you only get half
		# the possible angles, and you can end up with rotations that flip around near
		# the poles.

		# cos(a) = (s . e) / (||s|| ||e||)
		cos_angle	=	@start_point[0] * @end_point[0] +		# (s . e)
						@start_point[1] * @end_point[1] +
						@start_point[2] * @end_point[2]

		s			= Math.sqrt(@start_point[0] * @start_point[0] +
								@start_point[1] * @start_point[1] +
								@start_point[2] * @start_point[2])

		e			= Math.sqrt(@end_point[0] * @end_point[0] +
								@end_point[1] * @end_point[1] +
								@end_point[2] * @end_point[2])

		cos_angle	= cos_angle.quo(s).quo(e)

		# sin(a) = ||(s X e)|| / (||s|| ||e||)
		sin_angle	= Math.sqrt(@rotation[1] * @rotation[1] +		# ||(s X e)||
								@rotation[2] * @rotation[2] +
								@rotation[3] * @rotation[3])
        r			= sin_angle # keep this length in lr for normalizing the rotation vector later.

		sin_angle	= sin_angle.quo(s).quo(e)

		# GL rotations are in degrees :
		rotation[0] = Math.atan2 (sin_angle, cos_angle) * RADIANS_TO_DEGREES


		# Normalize the rotation axis :
		@rotation[1] = @rotation[1].quo(r);
		@rotation[2] = @rotation[2].quo(r);
		@rotation[3] = @rotation[3].quo(r);

	end

end
