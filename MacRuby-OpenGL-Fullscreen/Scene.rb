class Scene

	attr_accessor :roll_angle, :sun_angle



	def initialize

		# Create the texture :
		#texture_image		= NSImage.imageNamed("Earth.jpg")

		#if texture_image then

		#	texture_image_rep	= texture_image.bestRepresentationForDevice(nil)

			# Soon

		#end


		# Initializing other data :
		###

		# Animation
		@animation_phase		= 0.0

		@roll_angle				= 0.0
		@sun_angle				= 135.0

		@radius					= 0.25


		# Texture :
		@texture_name			= Pointer.new_with_type('I')
		@texture_name[0]		= 0


		# Rendering parameters :
		@light_direction		= Pointer.new_with_type('f', 4)
		@light_direction[0]		= -0.7071
		@light_direction[1]		= 0.0
		@light_direction[2]		= 0.7071
		@light_direction[3]		= 0.0

		@material_ambient		= Pointer.new_with_type('f', 4)
		@material_ambient[0]	= 0.0
		@material_ambient[1]	= 0.0
		@material_ambient[2]	= 0.0
		@material_ambient[3]	= 0.0

		@material_diffuse		= Pointer.new_with_type('f', 4)
		@material_diffuse[0]	= 1.0
		@material_diffuse[1]	= 1.0
		@material_diffuse[2]	= 1.0
		@material_diffuse[3]	= 1.0

		@wireframe			= true #false

	end





	def set_viewport_rectangle(bounds)

		

	end





	def render

		# Set up rendering state.
		glEnable(GL_DEPTH_TEST)
		glEnable(GL_CULL_FACE)
		glEnable(GL_LIGHTING)
		glEnable(GL_LIGHT0)

		# Upload the texture.  Since we are sharing OpenGL object between our FullScreen and non-FullScreen contexts, we only need to do this once.
		#if texture_name[0] == 0 then
		#	glGenTextures(1, texture_name)
		#	texture_bitmap_image_rep.upload_as_opengl_texture(texture_name[0])
		#end


		# Set up texturing parameters :
		#glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
		#glEnable(GL_TEXTURE_2D)
		#glBindTexture(GL_TEXTURE_2D, texture_name[0])


		# Clear the framebuffer :
		glClearColor(0, 0, 0, 0)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)


		glPushMatrix


		# Set up our single directional light (the Sun!) :
		
		@light_direction[0] = Math::cos(degree_to_radiant(@sun_angle))
		@light_direction[2] = Math::sin(degree_to_radiant(@sun_angle))
		glLightfv(GL_LIGHT0, GL_POSITION, @light_direction)
	

		# Back the camera off a bit :
		glTranslatef(0.0, 0.0, -1.5)
	

		# Draw the Earth !
		#quadric	= Pointer.new_with_type('^GLUquadric')
		quadric = gluNewQuadric


		gluQuadricDrawStyle(quadric, GLU_LINE) #if @wireframe
glColor3f(1.0, 0.85, 0.35)
		#gluQuadricTexture(quadric, GL_TRUE)
		#glMaterialfv(GL_FRONT, GL_AMBIENT, @material_ambient)
		#glMaterialfv(GL_FRONT, GL_DIFFUSE, @material_diffuse)

		glRotatef(@roll_angle, 1.0, 0.0, 0.0)
		glRotatef(-23.45, 0.0, 0.0, 1.0)		# Earth's axial tilt is 23.45 degrees from the plane of the ecliptic.
		glRotatef(@animation_phase * 360.0, 0.0, 1.0, 0.0)
		glRotatef(90.0, 1.0, 0.0, 0.0)

		gluSphere(quadric, 0.25, 48, 24)
		gluDeleteQuadric(quadric)
		quadric = nil
	
		glPopMatrix
    
		# Flush out any unfinished rendering before swapping.
		glFinish

	end





	def advance_time_by(seconds)

		phase_delta			= seconds - seconds.floor

		new_animation_phase	= @animation_phase + 0.015625 * phase_delta
		new_animation_phase	= new_animation_phase - new_animation_phase.floor

		animation_phase		= new_animation_phase

	end





	def toggleWireframe

		@wireframe = !@wireframe

	end





	def degree_to_radiant(angle)

		return angle * Math::PI / 180.0

	end

end