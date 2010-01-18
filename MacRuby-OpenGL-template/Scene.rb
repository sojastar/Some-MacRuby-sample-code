class Scene

	attr_accessor	:roll_angle, :sun_angle,
					:wireframe



	def initialize

		# Initializing the cube geometry :
		###

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


		# Initializing animation data :
		###

		@animation_phase		= 0.0

		@roll_angle				= 0.0

	end





	def set_viewport_rectangle(bounds)

		glViewport(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height)

		glMatrixMode(GL_PROJECTION)
		glLoadIdentity
		gluPerspective(30, bounds.size.width / bounds.size.height, 1.0, 1000.0)

		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity

	end





	def render

		# Clear the framebuffer :
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)


		# Reset all previous transformations ( reset the ModelView matrix ) :
		glLoadIdentity()


		# Back the camera off a bit :
		glTranslatef(0.0, 0.0, -10.5)
	

		# Draw the cube :
		###

		# Rotate the cube :
		glRotatef(@animation_phase * 360.0, 0.0, 1.0, 0.0)
		glRotatef(@animation_phase * 360.0, 1.0, 0.0, 0.0)


		# Drawing the faces :
		glBegin(GL_QUADS)


		@faces_number.times do |f|

			4.times do |i|

				glColor3f(	@vertex_colors[@faces[f][i]][0],
							@vertex_colors[@faces[f][i]][1],
							@vertex_colors[@faces[f][i]][2] )
				glVertex3f(	@vertices[@faces[f][i]][0],
							@vertices[@faces[f][i]][1],
							@vertices[@faces[f][i]][2])

			end

		end

		glEnd


		# Drawing the lines :
		glColor3f(0.0, 0.0, 0.0)
		@faces_number.times do |f|

			glBegin(GL_LINE_LOOP)

			4.times do |i|
				glVertex3f(	@vertices[@faces[f][i]][0],
							@vertices[@faces[f][i]][1],
							@vertices[@faces[f][i]][2])
			end

			glEnd

		end


		# Flush out any unfinished rendering before swapping.
		glFinish

	end





	def advance_time_by(seconds)

		phase_delta			= seconds - seconds.floor

		new_animation_phase	= @animation_phase + 0.015625 * phase_delta
		new_animation_phase	= new_animation_phase - new_animation_phase.floor

		@animation_phase		= new_animation_phase

	end





	def toggle_wireframe

		@wireframe = !@wireframe

	end





	def degree_to_radiant(angle)

		return angle * Math::PI / 180.0

	end

end