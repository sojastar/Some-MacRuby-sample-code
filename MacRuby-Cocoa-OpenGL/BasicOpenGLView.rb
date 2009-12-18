#
#  BasicOpenGLView.rb
#  MacRuby Cocoa OpenGL
#
###

module Rotation
end

module GLCheck
end

class BasicOpenGLView < NSOpenGLView

	include Rotation
	include GLCheck



	# Constant(s) :
	#
	###
	MESSAGE_PERSISTANCE	= 10.0
	MAX_VELOCITY		= 2.0





	# OpenGL, geometry and animation methods :
	#
	#################################################################################################################################################################

	# Check for existing opengl caps here :
	# This can be called again with same display caps array when display configurations are changed and
	# your info needs to be updated.  Note, if you are doing dynmaic allocation, the number of displays
	# may change and thus you should always reallocate your display caps array.
	#
	###
	def get_current_opengl_capacities

		#if GLCheck.have_opengl_capacities_changed(display_capacities, display_count) 

	end





	# Pixel format definition :
	# Ugly C code in Ruby form.
	#
	###
	def basic_pixel_format

		attributes		= Pointer.new_with_type('I')
		attributes[0]	= NSOpenGLPFAWindow
		attributes[1]	= NSOpenGLPFADoubleBuffer			# double buffered
		attributes[2]	= NSOpenGLPFADepthSize
		attributes[3]	= 16								# 16 bit depth buffer
		attributes[4]	= 0									# 0 terminated list of attributes

		pixel_format	= NSOpenGLPixelFormat.alloc.initWithAttributes(attributes)

		return pixel_format

	end





	# Updates the projection matrix based on camera and view info :
	#
	###
	def update_projection

		@current_context.makeCurrentContext


		# Set projection :
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity

		near = -@camera.view_position.z - @shape_size * 0.5
		if near < 0.00001 then near = 0.00001 end

		far = -@camera.view_position.z + @shape_size * 0.5
		if far < 1.0 then far = 1.0 end

		radians		= 0.0174532925 * @camera.aperture * 0.5
		wd2			= near * Math.tan(radians)

		ratio = @camera.view_width / @camera.view_height.to_f
		if (ratio >= 1.0) then
			left	= -ratio * wd2
			right	= ratio * wd2
			top		= wd2
			bottom	= -wd2
		else
			left	= -wd2
			right	= wd2
			top		= wd2 / ratio
			bottom	= -wd2 / ratio
		end

		glFrustum(left, right, bottom, top, near, far)

		#update_camera_string

	end





	# Updates the contexts model view matrix for object and camera moves :
	#
	###
	def update_model_view

		@current_context.makeCurrentContext


		# Move the view :
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity
		gluLookAt(	@camera.view_position.x, @camera.view_position.y, @camera.view_position.z,
					@camera.view_position.x + @camera.view_direction.x,
					@camera.view_position.y + @camera.view_direction.y,
					@camera.view_position.z + @camera.view_direction.z,
					@camera.view_up.x, @camera.view_up.y ,@camera.view_up.z)


		# If we have trackball rotation to map (this IS the test I want as it can be explicitly 0.0f) :
		if (@tracking_view_info == self) and (@trackball.rotation[0] != 0.0) then
			glRotatef(	@trackball.rotation[0],
						@trackball.rotation[1],
						@trackball.rotation[2],
						@trackball.rotation[3]	)
		end

		# Accumulated world rotation via trackball :
		glRotatef(@world_rotation[0], @world_rotation[1], @world_rotation[2], @world_rotation[3])

		# The object rotates itself after the camera rotation :
		glRotatef(@object_rotation[0], @object_rotation[1], @object_rotation[2], @object_rotation[3])
		@rotation		= [0.0, 0.0, 0.0]

		#update_camera_string

	end





	# Changes the OpenGL parameters in case the window geometry is modified :
	#
	###
	def resize_gl

		view_rectangle = bounds

		# Ensures camera knows size changed :
		if (@camera.view_height != view_rectangle.size.height) or (@camera.view_width != view_rectangle.size.width)	then

			@camera.view_height = view_rectangle.size.height
			@camera.view_width = view_rectangle.size.width

			glViewport(0, 0, @camera.view_width, @camera.view_height)
			update_projection

			update_info_string

		end

	end





	# Moves the camera on the Z axis :
	#
	###
	def mouse_dolly(location)

		dolly = (@dolly_pan_start_point[1] - location.y) * -@camera.view_position.z / 300.0
		@camera.view_position.z += dolly

		if @camera.view_position.z == 0 then @camera.view_position.z = 0.0001 end

		@dolly_pan_start_point	= [location.x, location.y]

		update_camera_string

	end





	# Moves the camera on the X/Y plane :
	#
	###
	def mouse_pan(location)

		pan_x = (@dolly_pan_start_point[0] - location.x) / (900.0 / -@camera.view_position.z)
		pan_y = (@dolly_pan_start_point[1] - location.y) / (900.0 / -@camera.view_position.z)

		@camera.view_position.x -= pan_x
		@camera.view_position.y -= pan_y

		@dolly_pan_start_point	= [location.x, location.y]

		update_camera_string

	end





	# Given a delta time in seconds and current rotation accel, ...
	#... velocity and position, update overall object rotation :
	#
	###
	def update_object_rotation_for_time_data(delta_time)

		3.times do |i|

			@velocity[i] +=@acceleration[i] * delta_time * 30.0

			if		@velocity[i] > MAX_VELOCITY then
				@acceleration[i]	*= -1.0
				@velocity[i]		 = MAX_VELOCITY
			elsif	@velocity[i] < -MAX_VELOCITY then
				@acceleration[i]	*= -1.0
				@velocity[i]		 = -MAX_VELOCITY
			end

			@rotation[i] += @velocity[i] * delta_time * 30.0
			@rotation[i] %= 360

		end


		rot		= [0.0, 0.0, 0.0, 0.0]
		rot[0]	= @rotation[0]
		rot[1]	= 1.0
		Rotation::add_to_rotation(rot, @object_rotation)
		rot[0]	= @rotation[1]
		rot[1]	= 0.0
		rot[2]	= 1.0
		Rotation::add_to_rotation(rot, @object_rotation)
		rot[0]	= @rotation[2]
		rot[2]	= 0.0
		rot[3]	= 1.0
		Rotation::add_to_rotation(rot, @object_rotation)

	end





	# Draw a cube based on current modelview and projection matrices
	#
	###
	def draw_cube(cube, cube_size)

		# Drawing the faces :
		glBegin(GL_QUADS)

		glColor3f(1.0, 0.5, 0.0)
		cube.faces_number.times do |f|
			4.times do |i|
				glColor3f(	cube.vertex_colors[cube.faces[f][i]][0],
							cube.vertex_colors[cube.faces[f][i]][1],
							cube.vertex_colors[cube.faces[f][i]][2] )
				glVertex3f(	cube.vertices[cube.faces[f][i]][0] * cube_size,
							cube.vertices[cube.faces[f][i]][1] * cube_size,
							cube.vertices[cube.faces[f][i]][2] * cube_size )
			end
		end

		glEnd


		# Drawing the lines :
		glColor3f(0.0, 0.0, 0.0)
		cube.faces_number.times do |f|

			glBegin(GL_LINE_LOOP)

			4.times do |i|
				glVertex3f(	cube.vertices[cube.faces[f][i]][0] * cube_size,
							cube.vertices[cube.faces[f][i]][1] * cube_size,
							cube.vertices[cube.faces[f][i]][2] * cube_size )
			end

			glEnd

		end

	end





	# Per-window timer function (basic time based animation preformed here) :
	#
	###
	def animation_timer(timer)

		should_draw = false

		if @animate_flag == true then
			delta_time = Time.now.to_f - @time
			if delta_time > 10.0 then	# Skip pauses
				return
			else
				if !@trackball_flag or (@tracking_view_info != self) then
					update_object_rotation_for_time_data(delta_time)
				end
				should_draw = true
			end
		end

		@time = Time.now.to_f	# Reset the time

		# If we have current messages ...
		#if	((get_elapsed_time - @message_time)	< @message_persistance) or
		#	((get_elapsed_time - @error_time)	< @message_persistance)	then
		#		should_draw = true	# ... force redraw.
		#end

		if should_draw == true then
			# Redraw now instead dirty to enable updates during live resize
			setNeedsDisplay true
		end

	end





	def update_info_string

		width		= bounds.size.width
		height		= bounds.size.height
		renderer	= glGetString(GL_RENDERER)
		version		= glGetString(GL_VERSION)

		info_string = "(#{width} x #{height})\n#{renderer}\n#{version}"

		if (@info_glstring != nil) then
			@info_glstring.setString(info_string, withAttributes:@strings_attributes)

		else
			text_color		= NSColor.colorWithDeviceRed(1.0, green:1.0, blue:1.0, alpha:1.0)
			box_color		= NSColor.colorWithDeviceRed(0.5, green:0.5, blue:0.5, alpha:0.5)
			border_color	= NSColor.colorWithDeviceRed(0.8, green:0.8, blue:0.8, alpha:0.8)

			info_glstring	= GLString.new( string:				info_string,
											withAttributes:		@strings_attributes,
											withTextColor:		text_color,
											withBoxColor:		box_color,
											withBorderColor:	border_color )

		end

	end





	def update_camera_string

		camera_string	= @camera.to_s

		if (@camera_glstring != nil) then
			@camera_glstring.setString(camera_string, withAttributes:@strings_attributes)

		else
			text_color			= NSColor.colorWithDeviceRed(1.0, green:1.0, blue:1.0, alpha:1.0)
			box_color			= NSColor.colorWithDeviceRed(0.5, green:0.5, blue:0.5, alpha:0.5)
			border_color		= NSColor.colorWithDeviceRed(0.8, green:0.8, blue:0.8, alpha:0.8)

			camera_glstring	= GLString.new( string:				camera_string,
												withAttributes:		@strings_attributes,
												withTextColor:		text_color,
												withBoxColor:		box_color,
												withBorderColor:	border_color )

		end

	end





	def create_help_string

		help_string		= "Cmd-A: animate    Cmd-I: show info \n'h': toggle help    'c': toggle OpenGL caps"

		text_color		= NSColor.colorWithDeviceRed(1.0, green:1.0, blue:1.0, alpha:1.0)
		box_color		= NSColor.colorWithDeviceRed(0.0, green:0.5, blue:0.0, alpha:0.5)
		border_color	= NSColor.colorWithDeviceRed(0.3, green:0.8, blue:0.3, alpha:0.8)

		help_glstring	= GLString.new(	string:				help_string,
										withAttributes:		@strings_attributes,
										withTextColor:		text_color,
										withBoxColor:		box_color,
										withBorderColor:	border_color )

	end





	def update_message_string

		if (@message_glstring != nil) then
			@message_glstring.setString("update at #{@message_time.round(1)} secs", withAttributes:@strings_attributes)

		else

			message_string		= "No messages..."

			text_color			= NSColor.colorWithDeviceRed(1.0, green:1.0, blue:1.0, alpha:1.0)
			box_color			= NSColor.colorWithDeviceRed(0.5, green:0.5, blue:0.5, alpha:0.5)
			border_color		= NSColor.colorWithDeviceRed(0.8, green:0.8, blue:0.8, alpha:0.8)

			message_glstring	= GLString.new(	string:				message_string,
												withAttributes:		@strings_attributes,
												withTextColor:		text_color,
												withBoxColor:		box_color,
												withBorderColor:	border_color )

		end

	end





	# Draw text interface using our GLString class for much more optimized text drawing :
	# ( lots of hardcoded values in here )
	#
	###
	def draw_interface

		message_top	= 10.0

		matrix_mode	= Pointer.new_with_type('i')

		width		= @camera.view_width
		height		= @camera.view_height
		
		# Set orthograhic 1:1  pixel transform in local view coords :
		glGetIntegerv(GL_MATRIX_MODE, matrix_mode)
		glMatrixMode(GL_PROJECTION)
		glPushMatrix
		glLoadIdentity
		glMatrixMode(GL_MODELVIEW)
		glPushMatrix
		glLoadIdentity
		glScalef(2.0 / width, -2.0 /  height, 1.0);
		glTranslatef(-width / 2.0, -height / 2.0, 0.0)
			
		glColor4f(1.0, 1.0, 1.0, 1.0)


		# Drawing the info string :
		@info_glstring.drawAtPoint(NSMakePoint(10.0, height - @info_glstring.frameSize.height - 10.0))


		# Drawing the camera string :
		@camera_glstring.drawAtPoint(NSMakePoint(10.0, message_top))
		message_top += @camera_glstring.frameSize.height + 3.0


		# Drawing the help string :
		if @draw_help_flag then
			drawing_x		= ((width - @help_glstring.textureSize.width) / 2.0).floor
			drawing_y		= ((height - @help_glstring.textureSize.height) / 3.0).floor
			drawing_point	= NSMakePoint(drawing_x, drawing_y)
			@help_glstring.drawAtPoint(drawing_point)
		end


		# Drawing the OpenGL capacities string :
		if @draw_capacities_flag then
			renderer	= Pointer.new_with_type('i')
			pixelFormat.getValues(	renderer,
									forAttribute:NSOpenGLPFARendererID,
									forVirtualScreen:openGLContext.currentVirtualScreen)
			puts "renderer for screen #{openGLContext.currentVirtualScreen} : #{renderer[0]}"
			#draw_capacities(@display_capacities, @display_numbers, renderer[0], width);
		end


		# Drawing the message string :
		current_time	= get_elapsed_time
		if current_time - @message_time < MESSAGE_PERSISTANCE then
			fade		= (MESSAGE_PERSISTANCE - get_elapsed_time + @message_time) * 0.1	# premultiplied fade
			glColor4f(fade, fade, fade, fade)
			@message_glstring.drawAtPoint(NSMakePoint(10.0, message_top))
			message_top += @message_glstring.textureSize.height + 3.0
		end


		# Drawing the error message if needed :
		#if ((current_time - @error_time) < MESSAGE_PERSISTANCE) then
		#	fade		= (MESSAGE_PERSISTANCE - get_elapsed_time + @error_time) * 0.1	# premultiplied fade
		#	glColor4f(fade, fade, fade, fade)
		#	@error_glstring.drawAtPoint(NSMakePoint(10.0, message_top))
		#end


		# Reset orginal martices :
		glPopMatrix		# GL_MODELVIEW
		glMatrixMode(GL_PROJECTION)
		glPopMatrix
		glMatrixMode(matrix_mode[0])

		glDisable(GL_TEXTURE_RECTANGLE_EXT)
		glDisable(GL_BLEND)

		if glIsEnabled(GL_DEPTH_TEST) then	# ????
			glEnable(GL_DEPTH_TEST)			# ????
		end									# ????

		report_error

	end





	# IB Actions :
	#
	#################################################################################################################################################################

	def animate(sender)
		@animate_flag	= !@animate_flag
	end





	def info(sender)
		@draw_interface_flag		= !@draw_interface_flag
	end





	# User input methods (overriden methods) :
	#
	#################################################################################################################################################################

	def keyDown(the_event)

		characters = the_event.characters

		if characters.length > 0 then
			first_character = characters[0]
			case first_character
			when 'h'		# toggle help
				@draw_help_flag	= !@draw_help_flag
				setNeedsDisplay true

			when 'c'		# toggle caps
				@draw_capacities_flag	= !@draw_capacities_flag
				setNeedsDisplay true

			end
		end

	end





	def mouseDown(the_event)

		if the_event.modifierFlags & NSControlKeyMask != 0 then			# send to pan
			rightMouseDown(the_event)
		elsif the_event.modifierFlags & NSAlternateKeyMask	!= 0 then	# send to dolly
			otherMouseDown(the_event)
		else
			location			= convertPoint(the_event.locationInWindow, fromView:nil)
			location.y			= @camera.view_height - location.y
			@dolly_flag			= false			# no dolly
			@pan_flag			= false			# no pan
			@trackball_flag		= true
			@trackball.set(location.x, location.y, 0, 0, @camera.view_width, @camera.view_height)
			@tracking_view_info	= self
		end

	end





	def rightMouseDown(the_event)

		location			= convertPoint(the_event.locationInWindow, fromView:nil)
		location.y			= @camera.view_height - location.y

		if @trackball_flag then				# if we are currently tracking, end trackball

			if @trackball.rotation[0] != 0.0 then
				Rotation::add_to_rotation(@trackball.rotation, @world_rotation)
			end

			@trackball.rotation	= [0.0, 0.0, 0.0, 0.0]

		end

		@dolly_flag			= false		# no dolly
		@pan_flag			= true
		@trackball_flag		= false		# no trackball
		@dolly_pan_start_point	= [location.x, location.y]
		@tracking_view_info	= self

	end





	def otherMouseDown(the_event)

		location			= convertPoint(the_event.locationInWindow, fromView:nil)
		location.y			= @camera.view_height - location.y

		if @trackball_flag then				# if we are currently tracking, end trackball

			if @trackball.rotation[0] != 0.0 then
				Rotation::add_to_rotation(@trackball.rotation, @world_rotation)
			end

			@trackball.rotation	= [0.0, 0.0, 0.0, 0.0]

		end

		@dolly_flag			= true
		@pan_flag			= false		# no pan
		@trackball_flag		= false		# no trackball
		@dolly_pan_start_point	= [location.x, location.y]
		@tracking_view_info	= self

	end





	def mouseUp(the_event)

		if @dolly_flag then				# end dolly
			@dolly_flag		= false

		elsif @pan_flag then			# end pan
			@pan_flag		= false

		elsif @trackball_flag then		# end trackball
			@trackball_flag = false

			if (@trackball.rotation[0] != 0.0)
				Rotation::add_to_rotation(@trackball.rotation, @world_rotation);
				@trackball.rotation	= [0.0, 0.0, 0.0, 0.0]
			end

		end 

		@tracking_view_info	= nil;

	end





	def rightMouseUp(the_event)
		mouseUp(the_event)
	end





	def otherMouseUp(the_event)
		mouseUp(the_event)
	end





	def mouseDragged(the_event)

		location = convertPoint(the_event.locationInWindow, fromView:nil)
		location.y = @camera.view_height - location.y

		if @trackball_flag then
			@trackball.roll_to(location.x, location.y)
			setNeedsDisplay true

		elsif @dolly_flag then
			mouse_dolly(location)
			update_projection		# update projection matrix (not normally done on draw)
			setNeedsDisplay true

		elsif @pan_flag then
			mouse_pan(location)
			setNeedsDisplay true

		end

	end





	def rightMouseDragged(the_event)
		mouseDragged(the_event)
	end





	def otherMouseDragged(the_event)
		mouseDragged(the_event)
	end





	def scrollWheel(the_event)

		wheel_delta	= the_event.deltaX + the_event.deltaY + the_event.deltaZ

		if wheel_delta != 0 then

			delta_aperture = wheel_delta * -@camera.aperture / 200.0

			@camera.aperture += delta_aperture;

			if @camera.aperture < 0.1 then		# do not let aperture <= 0.1
				@camera.aperture	= 0.1
			end

			if @camera.aperture > 179.9 then	# do not let aperture >= 180
				@camera.aperture	= 179.9
			end


			update_camera_string
			update_projection		# update projection matrix
			setNeedsDisplay true

		end

	end





	# View methods (overriden methods) :
	#
	#################################################################################################################################################################

	def drawRect(rect)

		# Setup viewport and prespective :
		resize_gl			# force projection matrix update (does test for size changes)
		update_model_view	# update model view matrix for object

		# clear our drawable
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
		# model view and projection matricies already set

		draw_cube(@cube, 1.5)	# draw scene

		if @draw_interface_flag then
			draw_interface
		end

		if inLiveResize and not @animate_flag then
			glFlush
		else
			@current_context.flushBuffer
		end

		#report_error

	end





	# Set initial OpenGL state (current context is set) called after context is created :
	def prepareOpenGL

		glEnable(GL_DEPTH_TEST)

		glShadeModel(GL_SMOOTH)
		glEnable(GL_CULL_FACE)
		glFrontFace(GL_CCW)
		glPolygonOffset (1.0, 1.0)
	
		glClearColor(0.0, 0.0, 0.0, 0.0)

	end





	# Window resizes, moves and display changes (resize, depth and display config change) :
	def update

		# This can be a troublesome call to do anything heavyweight, as it is called on window moves, resizes, and display config changes.
		# So be careful of doing too much here.

		@message_time	= get_elapsed_time

		update_message_string

		@current_context.update

		unless inLiveResize				# if not doing live resize
			update_info_string					# to get change in renderers will rebuild string every time (could test for early out)
			#get_current_opengl_capacities		# this call checks to see if the current config changed in a reasonably lightweight way ...
												# ... to prevent expensive re-allocations
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





	def awakeFromNib

		# Pixel format ... :
		@pixel_format	= basic_pixel_format
		setPixelFormat(@pixel_format)


		# ... and only then OpenGL context : 
		swap_int			= Pointer.new_with_type('i')
		swap_int[0]			= 1
		@current_context	= openGLContext
		@current_context.setValues(swap_int, forParameter:NSOpenGLCPSwapInterval)	# set to vbl sync

		
		# Retrieving the OpenGL capacities :
		# THE BROKEN PART
		#c,d	= GLCheck::check_opengl_capacities(0)
		#c,d	= GLCheck::check_opengl_capacities(d)


		# Get the application start time :
		@start_time	= Time.now.to_f
		@time		= @start_time


		# Content setup :
		setup_scene
		setup_interface


		# Get current GL capabilities for all displays :
		#get_current_caps


		# Starting the timer :
		@timer			= NSTimer.timerWithTimeInterval(1.0/60.0, target:self, selector:"animation_timer:", userInfo:nil, repeats:true)
		NSRunLoop.currentRunLoop.addTimer(@timer, forMode:NSDefaultRunLoopMode)
		NSRunLoop.currentRunLoop.addTimer(@timer, forMode:NSEventTrackingRunLoopMode)

	end





	def setup_scene

		# Initializing world and camera geometry :
		@camera					= Camera.new				# creating a camera object
		@dolly_pan_start_point	= [0, 0]
		@dolly_flag				= false
		@pan_flag				= false
		@world_rotation			= [0.0, 0.0, 0.0, 0.0]
		@object_rotation		= [0.0, 0.0, 0.0, 0.0]

		@trackball				= Trackball.new
		@trackball_flag			= false
		@tracking_view_info		= nil		

		@cube					= Cube.new					# create a cube object
		@rotation				= [0.0, 0.0, 0.0]
		@velocity				= [0.3, 0.1, 0.2]
		@acceleration			= [0.003, -0.005, 0.004]

		@shape_size				= 7.0						# maximum radius of objects

	end





	def setup_interface

		# Initializing the interface flags :
		@draw_interface_flag	= true
		@draw_help_flag			= true
		@draw_capacities_flag	= false
		@animate_flag			= true


		# Init font and attributes for use with all strings :
		font				= NSFont.fontWithName("Helvetica", size:12.0)
		@strings_attributes	= {	'NSFontAttributeName'				=> font,
								'NSForegroundColorAttributeName'	=> NSColor.whiteColor }

		@message_time		= 0
		@error_time			= 0


		# Ensure strings are created :
		@info_glstring		= update_info_string
		@camera_glstring	= update_camera_string
		@help_glstring		= create_help_string
		@message_glstring	= update_message_string

	end





	# Utilities :
	#
	#################################################################################################################################################################

	def get_elapsed_time
		return Time.now.to_f - @start_time
	end





	def report_error

		error = glGetError
		if error == GL_NO_ERROR then
			return
		else
			error	= NSSTring.alloc.initWithCString(gluErrorString (err), kNSASCIIStringEncoding);
		end


		@error_time		= get_elapsed_time


		error_string	= "Error: #{error} (at time: #{@error_time} secs)."
		puts error_string


		# Creating the error string texture :
		font			= NSFont.fontWithName("Monaco", size:9.0)
		attributes		= {'NSFontAttributeName' => font, 'NSForegroundColorAttributeName' => NSColor.whiteColor}

		if @error_glstring == nil then

			@error_glstring.set_string_with_attributes(error_string, attributes)

		else

			text_color				= NSColor.colorWithDeviceRed(1.0, green:1.0, blue:1.0, alpha:1.0)
			box_color				= NSColor.colorWithDeviceRed(1.0, green:0.0, blue:0.0, alpha:0.3)
			border_color			= NSColor.colorWithDeviceRed(1.0, green:0.0, blue:0.0, alpha:0.8)

			@error_glstring = GLString.new(	error_string,
											withAttributes:		attribs,
											withTextColor:		text_color,
											withBoxColor:		box_color,
											withBorderColor:	border_color )

		end

	end

end
