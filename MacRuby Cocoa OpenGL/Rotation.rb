#
#  Rotation.rb
#  MacRuby Cocoa OpenGL
#
###

module Rotation

	#
	# Constants :
	#
	###
	TOL					= 0.001
	RADIANS_TO_DEGREES	= 180.0 / 3.1415927
	DEGREES_TO_RADIANS	= 3.1415927 / 180.0



	def Rotation.rotation_to_quaternion(a, q)

		# Convert a GL-style rotation to a quaternion. The GL rotation looks like this:
		# {angle, x, y, z}, the corresponding quaternion looks like this:
		# {{v}, cos(angle/2)}, where {v} is {x, y, z} / sin(angle/2).

		# Convert from degrees ot radians, get the half-angle :
		half_angle		= a[0] * DEGREES_TO_RADIANS * 0.5
		sin_half_angle	= Math.sin(half_angle)

		q[0]			= a[1] * sin_half_angle
		q[1]			= a[2] * sin_half_angle
		q[2]			= a[3] * sin_half_angle
		q[3]			= Math.cos(half_angle);

	end



	def Rotation.add_to_rotation (da, a)

		q0		= Array.new(4,0)
		q1		= Array.new(4,0)
		q2		= Array.new(4,0)


		# Figure out a' = a . da
		# In quaternions: let q0 <- a, and q1 <- da.
		# Figure out q2 = q1 + q0 (note the order reversal!).
		# a' <- q3.

		rotation_to_quaternion(a, q0)
		rotation_to_quaternion(da, q1)


		# q2 = q1 + q0 :
		q2[0]	= q1[1]*q0[2] - q1[2]*q0[1] + q1[3]*q0[0] + q1[0]*q0[3]
		q2[1]	= q1[2]*q0[0] - q1[0]*q0[2] + q1[3]*q0[1] + q1[1]*q0[3]
		q2[2]	= q1[0]*q0[1] - q1[1]*q0[0] + q1[3]*q0[2] + q1[2]*q0[3]
		q2[3]	= q1[3]*q0[3] - q1[0]*q0[0] - q1[1]*q0[1] - q1[2]*q0[2]
		# Here's an excersize for the reader: it's a good idea to re-normalize your quaternions
		# every so often.  Experiment with different frequencies.


		# An identity rotation is expressed as rotation by 0 about any axis.
		# The "angle" term in a quaternion is really the cosine of the half-angle.
		# So, if the cosine of the half-angle is one (or, 1.0 within our tolerance),
		# then you have an identity rotation.
		if (q2[3] - 1).abs < 1.0e-7 then

			# Identity rotation :
			a[0] = 0.0
			a[1] = 1.0
			a[2] = 0.0
			a[3] = 0.0

			return

		end


		# If you get here, then you have a non-identity rotation.  In non-identity rotations,
		# the cosine of the half-angle is non-0, which means the sine of the angle is also
		# non-0.  So we can safely divide by sin(theta2).
    
		# Turn the quaternion back into an {angle, {axis}} rotation.
		half_theta		= Math.acos(q2[3])
		sin_half_theta	= 1.quo(Math.sin(half_theta))

		a[0]			= 2 * half_theta * RADIANS_TO_DEGREES
		a[1]			= q2[0] * sin_half_theta
		a[2]			= q2[1] * sin_half_theta
		a[3]			= q2[2] * sin_half_theta

	end



end