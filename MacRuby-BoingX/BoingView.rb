#
#  BoingView.rb
#  MacRuby BoingX
#
###

class BoingView < NSOpenGLView



	def get_pixel_format

		# 'Smooth' attributes : attributes that allow for a smoother rendering
		# ( with multiple samples )
		smooth_attributes			= Pointer.new_with_type('I')
		smooth_attributes[0]		= NSOpenGLPFAAccelerated
		smooth_attributes[1]		= NSOpenGLPFADoubleBuffer
		smooth_attributes[2]		= NSOpenGLPFADepthSize
		smooth_attributes[3]		= 24
		smooth_attributes[4]		= NSOpenGLPFAAlphaSize
		smooth_attributes[5]		= 8
		smooth_attributes[6]		= NSOpenGLPFAColorSize
		smooth_attributes[7]		= 32
		smooth_attributes[8]		= KCGLPFASampleBuffers
		smooth_attributes[9]		= 1
		smooth_attributes[10]		= KCGLPFASamples
		smooth_attributes[11]		= 2
		#smooth_attributes[12]		= NSOpenGLPFANoRecovery
		smooth_attributes[12]		= 0

		# 'Jaggy' attributes : attributes that allow for a jaggyer rendering
		# ( without multiple sample )
		jaggy_attributes		= Pointer.new_with_type('I')
		jaggy_attributes[0]		= NSOpenGLPFAAccelerated
		jaggy_attributes[1]		= NSOpenGLPFADoubleBuffer
		jaggy_attributes[2]		= NSOpenGLPFADepthSize
		jaggy_attributes[3]		= 24
		jaggy_attributes[4]		= NSOpenGLPFAAlphaSize
		jaggy_attributes[5]		= 8
		jaggy_attributes[6]		= NSOpenGLPFAColorSize
		jaggy_attributes[7]		= 32
		#jaggy_attributes[8]		= NSOpenGLPFANoRecovery
		jaggy_attributes[8]	= 0


		# Try to create a pixel format from the 'smooth' attributes :
		pixel_format	= NSOpenGLPixelFormat.alloc.initWithAttributes(smooth_attributes)


		if pixel_format != nil then			# if the 'smooth' pixel format was not created ...
			@can_do_multisample	= true

		else								# ... try to make a 'jaggy' one :
			pixel_format			= NSOpenGLPixelFormat.alloc.initWithAttributes(jaggy_attributes)
			@can_do_multisample	= false

		end

		return pixel_format

	end





	def initialize_animation_timer

		@timer	= NSTimer.timerWithTimeInterval(1.0/60.0, target:self, selector:"animate:", userInfo:nil, repeats:true)
		NSRunLoop.currentRunLoop.addTimer(@timer, forMode:NSDefaultRunLoopMode)
		NSRunLoop.currentRunLoop.addTimer(@timer, forMode:NSEventTrackingRunLoopMode)

	end





	def initialize_lighting_parameters

		# Defining the scene's light parameters :
		@light_position		= Pointer.new_with_type('f')
		@light_position[0]	= -2.0
		@light_position[1]	=  2.0
		@light_position[2]	=  1.0
		@light_position[3]	=  0.0

		@light_ambient		= Pointer.new_with_type('f')
		@light_ambient[0]	= 0.2
		@light_ambient[1]	= 0.2
		@light_ambient[2]	= 0.2
		@light_ambient[3]	= 0.2
		@light_diffuse		= Pointer.new_with_type('f')
		@light_diffuse[0]	= 1.0
		@light_diffuse[1]	= 1.0
		@light_diffuse[2]	= 1.0
		@light_diffuse[3]	= 1.0
		@light_specular		= Pointer.new_with_type('f')
		@light_specular[0]	= 1.0
		@light_specular[1]	= 1.0
		@light_specular[2]	= 1.0
		@light_specular[3]	= 1.0

		# Defining the ball's material parameters :
		@material_shininess		= Pointer.new_with_type('f')
		@material_shininess[0]	= 10.0
		@material_shininess[1]	= 0.0
		@material_shininess[2]	= 0.0
		@material_shininess[3]	= 0.0

		@material_ambient		= Pointer.new_with_type('f')
		@material_ambient[0]	= 1.0
		@material_ambient[1]	= 1.0
		@material_ambient[2]	= 1.0
		@material_ambient[3]	= 1.0
		@material_diffuse		= Pointer.new_with_type('f')
		@material_diffuse[0]	= 1.0
		@material_diffuse[1]	= 1.0
		@material_diffuse[2]	= 1.0
		@material_diffuse[3]	= 1.0
		@material_specular		= Pointer.new_with_type('f')
		@material_specular[0]	= 1.0
		@material_specular[1]	= 1.0
		@material_specular[2]	= 1.0
		@material_specular[3]	= 1.0

		@material_emission		= Pointer.new_with_type('f')
		@material_emission[0]	= 0.0
		@material_emission[1]	= 0.0
		@material_emission[2]	= 0.0
		@material_emission[3]	= 0.0

	end





	def generate_boing_parameters

		delta		= Math::PI / 8.0

		@boing_data.clear


		# 8 vertical segments :
		8.times do |theta|

			theta0	= theta		* delta
			theta1	= (theta+1)	* delta


			# 16 horizontal segments :
			16.times do |phi|

				phi0	= phi		* delta
				phi1	= (phi+1)	* delta

				# For now, generate 4 full points :
				vertex1, vertex2, vertex3, vertex4	= Vertex.new, Vertex.new, Vertex.new, Vertex.new

				vertex1.x = @radius * Math::sin(theta0) * Math::cos(phi0)
				vertex1.y = @radius * Math::cos(theta0)
				vertex1.z = @radius * Math::sin(theta0) * Math::sin(phi0)

				vertex2.x = @radius * Math::sin(theta0) * Math::cos(phi1)
				vertex2.y = @radius * Math::cos(theta0)
				vertex2.z = @radius * Math::sin(theta0) * Math::sin(phi1)

				vertex3.x = @radius * Math::sin(theta1) * Math::cos(phi1)
				vertex3.y = @radius * Math::cos(theta1)
				vertex3.z = @radius * Math::sin(theta1) * Math::sin(phi1)

				vertex4.x = @radius * Math::sin(theta1) * Math::cos(phi0)
				vertex4.y = @radius * Math::cos(theta1)
				vertex4.z = @radius * Math::sin(theta1) * Math::sin(phi0)
			
				# Generate normal :
				if theta >= 4 then

					v1x = vertex2.x - vertex1.x
					v1y = vertex2.y - vertex1.y
					v1z = vertex2.z - vertex1.z
	
					v2x = vertex4.x - vertex1.x
					v2y = vertex4.y - vertex1.y
					v2z = vertex4.z - vertex1.z

				else

					v1x = vertex1.x - vertex4.x
					v1y = vertex1.y - vertex4.y
					v1z = vertex1.z - vertex4.z

					v2x = vertex3.x - vertex4.x
					v2y = vertex3.y - vertex4.y
					v2z = vertex3.z - vertex4.z

				end

				vertex1.nx = (v1y * v2z) - (v2y * v1z)
				vertex1.ny = (v1z * v2x) - (v2z * v1x)
				vertex1.nz = (v1x * v2y) - (v2x * v1y)
			
				d = 1.0/Math::sqrt(	vertex1.nx * vertex1.nx + 
									vertex1.ny * vertex1.ny +
									vertex1.nz * vertex1.nz )
			
				vertex1.nx *= d
				vertex1.ny *= d
				vertex1.nz *= d
			
				# Generate color :
				if (theta ^ phi) & 1 == 1 then

					vertex1.r = 1.0
					vertex1.g = 1.0
					vertex1.b = 1.0
					vertex1.a = 1.0			

				else

					vertex1.r = 1.0
					vertex1.g = 0.0
					vertex1.b = 0.0
					vertex1.a = 1.0

				end
			
				# Replicate vertex info :
				vertex2.nx, vertex3.nx, vertex4.nx	= vertex1.nx, vertex1.nx, vertex1.nx
				vertex2.ny, vertex3.ny, vertex4.ny	= vertex1.ny, vertex1.ny, vertex1.ny
				vertex2.nz, vertex3.nz, vertex4.nz	= vertex1.nz, vertex1.nz, vertex1.nz

				vertex2.r, vertex3.r, vertex4.r	= vertex1.r, vertex1.r, vertex1.r
				vertex2.g, vertex3.g, vertex4.g	= vertex1.g, vertex1.g, vertex1.g
				vertex2.b, vertex3.b, vertex4.b	= vertex1.b, vertex1.b, vertex1.b
				vertex2.a, vertex3.a, vertex4.a	= vertex1.a, vertex1.a, vertex1.a
			
				# Store vertices :
				@boing_data << [vertex1, vertex2, vertex3, vertex4]

			end

		end

		@boing_data.flatten!

	end





	def initWithFrame(frame)

		# Get the pixel format :
		pixel_format	= get_pixel_format

		initWithFrame(frame, pixelFormat:pixel_format)


		# User interface flags :
		@scale_flag			= false
		@lighting_flag		= false
		@transparency_flag	= 0
		@multisample_flag	= false


		# Initialize the ball's parameters :
		@radius			= 48.0
		@x_velocity		= 1.5
		@y_velocity		= 0.0
		@x_position		= 2*@radius
		@y_position		= 3*@radius


		initialize_lighting_parameters


		@boing_data		= [] 


		@did_init		= false

		return self

	end





	def drawRect(rect)

		# Initializing then animation :
		#
		###
		if @did_init == false then

			@did_init				= true

			NSColor.clearColor.set
			NSRectFill(bounds)

			opaque = Pointer.new_with_type('i')
			opaque.assign(0)
			openGLContext.setValues(opaque, forParameter:NSOpenGLCPSurfaceOpacity)
			window.setOpaque(false)
			window.setAlphaValue(0.999)
			window.setMovableByWindowBackground(true)
		
			generate_boing_parameters

			@screen_bounds	= NSScreen.mainScreen.frame

			@angle					= 0
			@angle_delta			= -2.5

			glClearColor(0.0, 0.0, 0.0, 0.0)
			glClear(GL_COLOR_BUFFER_BIT  |GL_DEPTH_BUFFER_BIT)
			openGLContext.flushBuffer


			# Animation settings :
			@background_fade		= 1.0
			@light_factor			= 0.0
			@scale_factor			= 1.0
			@bounce_inside_window	= true

			if @can_do_multisample	== true then
				glDisable(GL_MULTISAMPLE_ARB)		
				glHint(GL_MULTISAMPLE_FILTER_HINT_NV, GL_NICEST)
			end


			glEnable(GL_LIGHT0)
			set_scene_light_parameters(@light_factor)

			set_material_parameters

			initialize_animation_timer

		end


		# Updating animation according to flags :
		# (flags can be modified by user input )
		#
		###
		if @multisample_flag	== true then glEnable(GL_MULTISAMPLE_ARB) end

		if @transparency_flag == 2 then

			@background_fade -= 0.05
			@background_fade = 0.0 if @background_fade < 0.0

		end
	
		if @lighting_flag == true then

			@light_factor += 0.005

			if @light_factor > 1.0 then
				@light_factor	= 1.0
				@lighting_flag	= false
			end

			set_scene_light_parameters(@light_factor)

		end

		if @scale_flag == true then

			old_radius		= @radius
			@scale_factor	+= 0.025
			@radius			= @scale_factor * 48.0
			@y_position		+= @radius - old_radius

			if @scale_factor > 2.0 then
		
				@scale_factor	= 2.0
				@scale_flag		= false

			end

			generate_boing_parameters

		end


		# Drawing the background and the ball and its shadow :
		#
		###
		glViewport(0, 0, bounds.size.width, bounds.size.height)

		glScissor(0, 0, 320 * @scale_factor, 200 * @scale_factor)
		glEnable(GL_SCISSOR_TEST)
		glClearColor(	0.675 * @background_fade,
						0.675 * @background_fade,
						0.675 * @background_fade,
						@background_fade)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

		glMatrixMode(GL_PROJECTION)
		glLoadIdentity
		glOrtho(0, bounds.size.width, 0, bounds.size.height, 0.0, 2000.0)

		glDisable(GL_LIGHTING)		# the background is not lit

		# Reset transformation matrix and set light position :
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity
		glLightfv(GL_LIGHT0, GL_POSITION, @light_position)


		# Drawing the background ( scaling and fading ) :
		# I am doing the scaling myself (rather than using OpenGL) just because
		# I want to get exact positioning of the lines.  There is probably a better
		# way to do this if I would try harder with the math.  Hey, it is a demo. ;)

		if @background_fade > 0.0 then

			glDepthMask(GL_FALSE)
			glDisable(GL_DEPTH_TEST)

			glBegin(GL_LINES)
			glColor4f(0.6275 * @background_fade, 0.0, 0.6275 * @background_fade, @background_fade)


			40.step(280, 16) do |i|
				glVertex3f(	(i * @scale_factor).floor + 0.5, (7 * @scale_factor).floor + 0.5, -500.0)
				glVertex3f(	(i * @scale_factor).floor + 0.5, 200 * @scale_factor + 0.5, -500.0)

				# Do stragglers along the bottom. Not exactly the same as
				# the original, but close enough.
				glVertex3f( (i * @scale_factor).floor + 0.5, (7 * @scale_factor).floor + 0.5, -500.0)
				glVertex3f( (i - 160) * @scale_factor * 1.1 + 160.0 * @scale_factor, -0.5, -500.0)

			end

			8.step(200, 16) do |i|
				glVertex3f(40.0 * @scale_factor, (i * @scale_factor).floor - 0.5, -500.0)
				glVertex3f(280.0 * @scale_factor, (i * @scale_factor).floor - 0.5, -500.0)

			end

			# Do final two horizontal lines :
			glVertex3f(	((40.0 - 3.0) * @scale_factor).floor + 0.5,
						((7.0 - 2.0) * @scale_factor).floor + 0.5,
						-500.0)
			glVertex3f(	((280.0 + 3.0) * @scale_factor).floor + 0.5,
						((7.0 - 2.0) * @scale_factor).floor + 0.5,
						-500.0)
			glVertex3f(	((40.0 - 8.0) * @scale_factor).floor + 0.5,
						((7.0 - 5.0) * @scale_factor).floor + 0.5,
						-500.0)
			glVertex3f(	((280.0 + 8.0) * @scale_factor).floor + 0.5,
						((7.0 - 5.0) * @scale_factor).floor + 0.5,
						-500.0)

			glEnd()
			
		end

		glLoadIdentity


		# Draw the shadow :

		glEnable(GL_CULL_FACE)
		if @bounce_inside_window then
			glTranslatef(@x_position + 10, @y_position - 2, -800.0)

		else
			glTranslatef(@radius + 10, @radius - 2, -800.0)

		end
			
		glRotatef(-16.0, 0.0, 0.0, 1.0)
		glRotatef(@angle, 0.0, 1.0, 0.0)
		glScalef(1.05, 1.05, 1.05)
	
		glEnable(GL_BLEND)
		glBlendFunc(GL_SRC_ALPHA_SATURATE, GL_ONE_MINUS_SRC_ALPHA)

		glBegin(GL_QUADS)
		glColor4f(0.0, 0.0, 0.0, 0.4)
		(4*8*16).times do |i|
			glNormal3f(@boing_data[i].nx, @boing_data[i].ny, @boing_data[i].nz)
			glVertex3f(@boing_data[i].x, @boing_data[i].y, @boing_data[i].z)
		end	
		glEnd()


		# Draw the ball :

		glEnable(GL_LIGHTING)
		glEnable(GL_CULL_FACE)
		glEnable(GL_DEPTH_TEST)
		glDepthMask(GL_TRUE)
		glDepthFunc(GL_LESS)
		glDisable(GL_BLEND)

		glLoadIdentity

		if @bounce_inside_window == true then
			glTranslatef(@x_position, @y_position, -100.0)
		
		else
			glTranslatef(@radius, @radius, -100.0)

		end


		glRotatef( -16.0, 0.0, 0.0, 1.0)
		glRotatef(@angle, 0.0, 1.0, 0.0)

		glBegin(GL_QUADS)
		(4*8*16).times do |i|
			glColor4f(@boing_data[i].r, @boing_data[i].g, @boing_data[i].b, @boing_data[i].a)
			glNormal3f(@boing_data[i & ~3].nx, @boing_data[i & ~3].ny, @boing_data[i & ~3].nz)
			glVertex3f(@boing_data[i].x, @boing_data[i].y, @boing_data[i].z)
		end
		glEnd()


		@angle	+= @angle_delta
		@angle	%= 360.0


		openGLContext.flushBuffer

	end





	def set_scene_light_parameters(light_factor)

		# We work with the first default OpenGL lights, named GL_LIGHT0 :
		#glEnable(GL_LIGHT0)

		# Ambient light :
		glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, GL_FALSE)
		glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_FALSE)
		light_model_ambient		= Pointer.new_with_type('f')
		light_model_ambient[0]	= 1.0 - light_factor
		light_model_ambient[1]	= 1.0 - light_factor
		light_model_ambient[2]	= 1.0 - light_factor
		light_model_ambient[3]	= 1.0 - light_factor
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT, light_model_ambient)
	
		# Directional white light :
		glLightfv(GL_LIGHT0, GL_AMBIENT, @light_ambient)
		glLightfv(GL_LIGHT0, GL_DIFFUSE, @light_diffuse)
		light_specular		= Pointer.new_with_type('f')
		light_specular[0]	= light_factor
		light_specular[1]	= light_factor
		light_specular[2]	= light_factor
		light_specular[3]	= light_factor
		glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular)

	end





	def set_material_parameters

		glEnable(GL_COLOR_MATERIAL)
		glEnable(GL_NORMALIZE)
		glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
		glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS,	@material_shininess)
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR,	@material_specular)
		glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION,	@material_emission)

	end





	def mouseDragged(the_event)

		origin	= window.frame.origin

		origin.x	+= the_event.deltaX
		origin.y	-= the_event.deltaY

		window.setFrameOrigin(origin)

	end





	def rightMouseDown(the_event)
		@angle_delta	= 2.0 - @angle_delta
	end





	def transition

		@bounce_inside_window	= false

		# Now we are going to switch to window movement mode for the bounce.
		# Move window origin such that when the ball is locked at r,r the ball doesn't
		# appear to move from it's current location.
		origin	= window.frame.origin
		frame	= NSMakeRect(	origin.x + @x_position - @radius,
								origin.y + @y_position - @radius,
								2*@radius + 20,
								2*@radius + 20	)


		# Convert xPos,yPos to screen coordinates :
		@x_position	= frame.origin.x + @radius
		@y_position	= frame.origin.y + @radius


		# Move window :
		window.setFrame(frame, display:true)


		openGLContext.update
		display
		window.flushWindow

	end




	def animate(timer)

		# Do bouncy stuff
		if @bounce_inside_window then

			@y_velocity	-= 0.05

			@x_position	+= @x_velocity * @scale_factor
			@y_position	+= @y_velocity * @scale_factor


			if @x_position < @radius + 10.0 then

				if @transparency_flag == 2 then
					transition

				else
					@x_position		= @radius + 10.0
					@x_velocity		= -@x_velocity
					@angle_delta	= -@angle_delta

				end

			elsif @x_position > (310 * @scale_factor - @radius)

				if @transparency_flag == 2 then
					transition

				else
					@x_position		= 310 * @scale_factor - @radius
					@x_velocity		= -@x_velocity
					@angle_delta	= -@angle_delta

				end
			end


			if @y_position < @radius

				if @transparency_flag < 2 then
					@y_position	= @radius
					@y_velocity = -@y_velocity
				end

				if @transparency_flag == 1 then
					@transparency_flag	= 2

				elsif @transparency_flag == 2
					transition

				end
			end

			#if @bounce_inside_window then display end
			display

		else

			@y_velocity -= 0.1

			@x_position	+= @x_velocity * @scale_factor
			@y_position += @y_velocity * @scale_factor
		
			frame = window.frame
		
			if @x_position < @radius + 10.0 then
				@x_position		= @radius + 10.0
				@x_velocity		= -@x_velocity
				@angle_delta	= -@angle_delta

			elsif @x_position > ((NSMaxX(@screen_bounds) - 10) - @radius)
				@x_position		= (NSMaxX(@screen_bounds) - 10) - @radius
				@x_velocity		= -@x_velocity
				@angle_delta	= -@angle_delta

			end

			if @y_position < @radius then
				@y_position	= @radius
				@y_velocity = -@y_velocity
			end

			frame.origin.x = @x_position - @radius
			frame.origin.y = @y_position - @radius
		
			setNeedsDisplay true
			window.setFrameOrigin(frame.origin)

		end

	end





	def acceptsFirstResponder
		return true
	end

	def becomeFirstResponder
		return true
	end

	def resignFirstResponder
		return true
	end





	def keyDown(the_event)

		characters = the_event.characters

		if characters.length > 0 then
			first_character = characters[0]
			case first_character
			when 's'
				@scale_flag			= true

			when 'l'
				@lighting_flag		= true

			when 't'
				@transparency_flag	= 1

			when 'm'
				@multisample_flag	= true

			end
		end

	end














end