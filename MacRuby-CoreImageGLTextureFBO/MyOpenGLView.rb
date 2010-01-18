#require 'MyOpenGLView.bundle'


class MyOpenGLVIew < NSOpenGLView

	attr_accessor	:hue_angle_slider, :gamma_power_slider, :gloom_radius_slider, :gloom_intensity_slider, :image_view





	def initWithFrame(frame)

		# Nice antialised, hardware accelerated with no recovery by the software renderer :
		antialiased_attributes		= Pointer.new_with_type('I', 16)
		antialiased_attributes[0]	= NSOpenGLPFAAccelerated
		antialiased_attributes[2]	= NSOpenGLPFANoRecovery
		antialiased_attributes[3]	= NSOpenGLPFADoubleBuffer
		antialiased_attributes[4]	= NSOpenGLPFAColorSize
		antialiased_attributes[5]	= 24
		antialiased_attributes[6]	= NSOpenGLPFAAlphaSize
		antialiased_attributes[7]	= 8
		antialiased_attributes[8]	= NSOpenGLPFADepthSize
		antialiased_attributes[9]	= 16
		antialiased_attributes[10]	= NSOpenGLPFAMultisample
		antialiased_attributes[11]	= NSOpenGLPFASampleBuffers
		antialiased_attributes[12]	= 1
		antialiased_attributes[13]	= NSOpenGLPFASamples
		antialiased_attributes[14]	= 4
		antialiased_attributes[15]	= 0

		# A little less requirements if the above fails :
		basic_attributes			= Pointer.new_with_type('I', )
		basic_attributes[0]			= NSOpenGLPFAAccelerated
		basic_attributes[1]			= NSOpenGLPFADoubleBuffer
		basic_attributes[2]			= NSOpenGLPFAColorSize
		basic_attributes[3]			= 24
		basic_attributes[4]			= NSOpenGLPFAAlphaSize
		basic_attributes[5]			= 8
		basic_attributes[6]			= NSOpenGLPFADepthSize
		basic_attributes[7]			= 16
		basic_attributes[8]			= 0


		# Creating the appropriate pixel format :
		@pixel_format	= NSOpenGLPixelFormat.alloc.initWithAttributes(antialiased_attributes)

		if @pixel_format == nil then

			puts "Couldn't find an FSAA pixel format, trying something more basic"
			@pixel_format	= NSOpenGLPixelFormat.alloc.initWithAttributes(basic_attributes)

		end


		# Initializing properly this NSOpenGLView instance :
		initWithFrame(frame, pixelFormat:@pixel_format)


		# Turning on VBL syncing for swaps :
		#swap_interval		= Pointer.new_with_type('i')
		#swap_interval[0]	= 1								# set to 1, so vbl sync is active
		#openGLContext.setValues(swap_interval, forParameter:NSOpenGLCPSwapInterval)


		# Initializing some variables :
		@fbo_id				= Pointer.new_with_type('I', 0)
		@fbo_id[0]			= -1

		@fbo_texture_id		= Pointer.new_with_type('I', 0)

		return self

	end





	# Load the Image and setup the CI filter :
	def setup_image_with_CI_filter

		# Load the image :
		image_path			= NSBundle.mainBundle.pathForResource("Flowers", ofType:"jpg")
		image_url			= NSURL.fileURLWithPath(image_path)
		ciimage				= CIImage.imageWithContentsOfURL(image_url)

	
		# Get the size of the image we are going to need throughout :
		@image_rectangle	= ciimage.extent


		# Get the aspect ratio for possible scaling (e.g. texture coordinates) :
		@image_aspect_ratio	= @image_rectangle.size.width / @image_rectangle.size.height
	

		# Create the CIFilters :
		@hue_filter			= CIFilter.filterWithName("CIHueAdjust")
		@hue_filter.setDefaults
		@hue_filter.setValue(ciimage, forKey:"inputImage")

		@gamma_filter		= CIFilter.filterWithName("CIGammaAdjust")
		@gamma_filter.setDefaults
		@gamma_filter.setValue(@hue_filter.valueForKey("outputImage"), forKey:"inputImage")

		@gloom_filter		= CIFilter.filterWithName("CIGloom")
		@gloom_filter.setDefaults
		@gloom_filter.setValue(@gamma_filter.valueForKey("outputImage"), forKey:"inputImage")

	end





	# Create CIContext based on OpenGL context and pixel format :
	def create_cicontext

		# Create CIContext from the OpenGL context :
		#@cicontext = CIContext.contextWithCGLContext(openGLContext.CGLContextObj,
		#											 pixelFormat:@pixel_format.CGLPixelFormatObj,
		#											 options:nil)
		cgcontext	= NSGraphicsContext.currentContext.graphicsPort
		@cicontext	= CIContext.contextWithCGContext(cgcontext, options:nil)

		unless @cicontext then

			puts "CIContext creation failed"

			return false

		end

	
		# Created succesfully, then :
		return true

	end





	def set_fbo
	
		# If not previously setup generate IDs for FBO and its associated texture :
		if @fbo_id[0] == -1 then

			# Make sure the framebuffer extenstion is supported :

			# Get the extenstion name string.
			# It is a space-delimited list of the OpenGL extenstions ..
			# ...that are supported by the current renderer.

			extension_string	= glGetString(GL_EXTENSIONS)
			
			puts "Your system does not support framebuffer extension" unless extension_string =~ /GL_EXT_framebuffer_object/


			# Create FBO object :
			glGenFramebuffersEXT(1, @fbo_id)

			# The texture :
			glGenTextures(1, @fbo_texture_id)

		end


		# Bind to FBO :
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, @fbo_id[0])

	
		# Sanity check against maximum OpenGL texture size.
		# If bigger adjust to maximum possible size ...
		# ... while maintain the aspect ratio

		max_texture_size	= Pointer.new_with_type('i', 0)

		glGetIntegerv(GL_MAX_TEXTURE_SIZE, max_texture_size)

		if (@image_rectangle.size.width > max_texture_size[0] || @image_rectangle.size.height > max_texture_size[0]) then

			if @image_aspect_ratio > 1 then
				@image_rectangle.size.width		= max_texture_size[0]
				@image_rectangle.size.height	= max_texture_size[0] / @image_aspect_ratio

			else
				@image_rectangle.size.width		= max_texture_size[0] * @image_aspect_ratio
				@image_rectangle.size.height	= max_texture_size[0]

			end

		end


		# Initialize FBO Texture :

		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, @fbo_texture_id[0])

		# Using GL_LINEAR because we want a linear sampling for this particular case.
		# If your intention is to simply get the bitmap data out of Core Image ...
		# ... you might want to use a 1:1 rendering and GL_NEAREST.
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
		glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
	
		# The GPUs like the GL_BGRA / GL_UNSIGNED_INT_8_8_8_8_REV combination.
		# Others are also valid, but might incur a costly software translation.
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, @image_rectangle.size.width, @image_rectangle.size.height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, nil)

		# And attach texture to the FBO as its color destination :
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_RECTANGLE_ARB, @fbo_texture_id[0], 0)


		# NOTE: for this particular case we don't need a depth buffer when drawing to the FBO.
		# If you do need it, make sure you add the depth size in the pixel format, and ...
		# ... you might want to do something along the lines of :

		# Initialize Depth Render Buffer :
		#depth_rb	= Pointer.new_with_type('i')
		#glGenRenderbuffersEXT(1, depth_rb)
		#glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, depth_rb[0])
		#glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT, @image_rectangle.size.width, @image_rectangle.size.height)

		# And attach it to the FBO :
		#glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, depth_rb[0])

	
		# Make sure the FBO was created succesfully :
		if GL_FRAMEBUFFER_COMPLETE_EXT != glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) then

			puts "Framebuffer Object creation or update failed!"

		end
		
		# Unbind FBO :
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0)

	end





	def prepareOpenGL

		# Turning on VBL syncing for swaps :
		swap_interval		= Pointer.new_with_type('i')
		swap_interval[0]	= 1								# set to 1, so vbl sync is active
		openGLContext.setValues(swap_interval, forParameter:NSOpenGLCPSwapInterval)


		# Clear to black :
		glClearColor(0.0, 0.0, 0.0, 0.0)

		# Setup blending function :
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	
		# Enable texturing :
		glEnable(GL_TEXTURE_RECTANGLE_ARB)


		# Load the image and setup the Core Image filters :
		setup_image_with_CI_filter


		# Create an OpenGL backed CIContext :
		create_cicontext
		#createCIContext()


		# Create FBO and attached texture.
		# FBO size depends on CI image extent initialized ...
		# ... in the methods called above.
		set_fbo


		# Update values and trigger initial rendering of CI to FBO :
		slider_changed(self)

	end





	# This method actually renders with Core Image to the ...
	# ... OpenGL managed, hardware accelerated offscreen area.
	def render_core_image_to_fbo

		# Update values for filters :
		@hue_filter.setValue(NSNumber.numberWithFloat(@hue_angle), forKey: "inputAngle")
		@gamma_filter.setValue(NSNumber.numberWithFloat(@gamma_power), forKey: "inputPower")
		@gloom_filter.setValue(NSNumber.numberWithFloat(@gloom_intensity), forKey: "inputIntensity")
		@gloom_filter.setValue(NSNumber.numberWithFloat(@gloom_radius), forKey: "inputRadius")


		# Update images :
		@hue_filter.setValue(@ciimage, forKey:"inputImage")
		@gamma_filter.setValue(@hue_filter.valueForKey("outputImage"), forKey:"inputImage")
		@gloom_filter.setValue(@gamma_filter.valueForKey("outputImage"), forKey:"inputImage")
	

		# Bind FBO  :
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo_id[0])


		# Set GL state  :
		width	= @image_rectangle.size.width.ceil
		height	= @image_rectangle.size.height.ceil


		# The next few calls simply map an orthographic projection ...
		# ... or screen aligned 2D area for Core Image to draw into.

		glViewport(0, 0, width, height)
		
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		glOrtho(0, width, 0, height, -1, 1)
		
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()
		
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

	
		# Render CI :
		@cicontext.drawImage(@gloom_filter.valueForKey("outputImage"), atPoint:CGPointZero,  fromRect:@image_rectangle)


		# Bind to default framebuffer (unbind FBO)
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0)
	

		setNeedsDisplay(true)

	end





	def render_scene

		# Setup OpenGL with a perspective projection  ...
		# ... and back to 3D stuff with the depth buffer.
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
		
		glViewport(0, 0, bounds.size.width, bounds.size.height)
		
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluPerspective(60.0, bounds.size.width / bounds.size.height, 0.1, 100.0)
		
		glMatrixMode(GL_TEXTURE)
		glLoadIdentity()
		# The GL_TEXTURE_RECTANGLE_ARB doesn't use normalized coordinates.
		# Scale the texture matrix to "increase" the texture coordinates ...
		# ... back to the image size :
		glScalef(@image_rectangle.size.width, @image_rectangle.size.height, 1.0)
		
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()
		
		glTranslatef(0.0, 0.0, -2.0)


		# Fake reflection below floor.
		# Draw the image faintly upside down using the results ...
		# ... from Core Image stored in the texture from the FBO.

		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, fbo_exture_id[0])
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)

		# Using GL_MODULATE to have the quad modulate the color/intensity ...
		# ... to achieve a going darker effect at the bottom.

		# Enable blending :
		glEnable(GL_BLEND)

		# Draw a quad with the correct aspect ratio of the image :
		glPushMatrix()

			glScalef(@image_aspect_ratio, 1.0, 1.0)
			glBegin(GL_QUADS)
		
				glColor4f(0.8, 0.8,  0.8, 0.8)
				glTexCoord2f( 1.0, 0.0 ); glVertex2f(  0.5, 0.0 )
				glTexCoord2f( 0.0, 0.0 ); glVertex2f( -0.5, 0.0 )
				glColor4f(0.0, 0.0,  0.0, 0.0)
				glTexCoord2f( 0.0, 1.0 ); glVertex2f( -0.5, -1.0 )
				glTexCoord2f( 1.0, 1.0 ); glVertex2f(  0.5, -1.0 )
		
			glEnd

		glPopMatrix()

	end





	def drawRect(rectangle)

		openGLContect.makeCurrentContext

		# Render using the resulting texture :
		render_scene
	
		# Make sure OpenGL does it thing !
		openGLContext.flushBuffer

	end





	def slider_changed(sender)

		@hue_angle			= @hue_angle_slider.floatValue * (Math::PI / 180.0) + 0.001
		@gamma_power		= @gamma_power_slider.floatValue
		@gloom_radius		= @gloom_radius_slider.floatValue
		@gloom_intensity	= @gloom_intensity_slider.floatValue


		# Render core image to FBO :
		render_core_image_to_fbo

	end





	def update_ciimage(sender)

		if @image_view != nil then
			# Load new image :
			@ciimage	= CIImage.imageWithData(@image_view.image.TIFFRepresentation)

		else
			# Reload default image :
			image_path	= NSBundle.mainBundle.pathForResource("Flowers", ofType:"jpg")
			image_url	= NSURL.fileURLWithPath(image_path)
			ciimage		= CIImage.alloc.imageWithContentsOfURL(image_url)

		end


		# Update geometry :
		@image_rectangle	= @ciimage.extent
		@image_aspect_ratio	= @image_rectangle.size.width / @image_rectangle.size.height


		# Update FBO for new size and check for correctness :
		set_fbo


		# Render Core Image to the FBO :
		render_core_image_to_FBO

	end

end