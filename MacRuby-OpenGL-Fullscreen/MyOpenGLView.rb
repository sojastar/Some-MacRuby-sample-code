#
#  MyOpenGLView.rb
#  MacRuby Cocoa OpenGL
#
###

class MyOpenGLView < NSOpenGLView

	#attr_reader	:scene

	attr_accessor :controller, :scene



	def initWithFrame(frame)

		# Setting the pixel format attributes :
		attributes		= Pointer.new_with_type('I', 8)
		attributes[0]	= NSOpenGLPFANoRecovery		# Specifying "NoRecovery" gives us a context that cannot fall back to the software renderer. 
													# This makes the View-based context a compatible with the fullscreen context, enabling us  ...
													# ... to use the "shareContext" feature to share textures, display lists, and other OpenGL ...
													# ... objects between the two.
		attributes[1]	= NSOpenGLPFAColorSize		# From now on, attributes common to FullScreen and non-FullScreen
		attributes[2]	= 24
		attributes[3]	= NSOpenGLPFADepthSize
		attributes[4]	= 16
		attributes[5]	= NSOpenGLPFADoubleBuffer
		attributes[6]	= NSOpenGLPFAAccelerated
		attributes[7]	= 0

		# Create our non-Fullscreen pixel format :
		pixel_format	= NSOpenGLPixelFormat.alloc.initWithAttributes(attributes)


		# Just as a diagnostic, report the renderer ID that this pixel format binds to.
		# CGLRenderers.h contains a list of known renderers and their corresponding RendererID codes.
		renderer_id		= Pointer.new_with_type('i')
		pixel_format.getValues(renderer_id, forAttribute:NSOpenGLPFARendererID, forVirtualScreen:0)
		puts "NSOpenGLView pixelFormat RendererID = %08x" % renderer_id[0]


		# Initializing the properly this NSOpenGLView instance :
		initWithFrame(frame, pixelFormat:pixel_format)


		# Setting the scene :
		@scene	= Scene.new

		return self

	end





	def drawRect(rect)

		@scene.render
		openGLContext.flushBuffer

	end





	def reshape

		@scene.set_viewport_rectangle(bounds)

	end





	def acceptsFirstResponder

		return true

	end





	def keyDown(the_event)

		@controller.keyDown(the_event)

	end





	def mouseDown(the_event)

		@controller.mouseDown(the_event)

	end



	def go_fullscreen

		main_display_id		= CGMainDisplayID()


		# Pixel Format Attributes for the FullScreen NSOpenGLContext :
		attributes			= Pointer.new_with_type('I', 8)
		attributes[0]		= NSOpenGLPFAFullScreen			# Specify that we want a full-screen OpenGL context	
		attributes[1]		= NSOpenGLPFAScreenMask			# We may be on a multi-display system (and each screen may be driven by a different renderer) ...
															# ... so we need to specify which screen we want to take over.  For this demo, we'll specify  ...
															# ... the main screen.
		#attributes[2]		= CGDisplayIDToOpenGLDisplayMask(KCGDirectMainDisplay)
		attributes[2]		= CGDisplayIDToOpenGLDisplayMask(main_display_id)
		attributes[3]		= NSOpenGLPFAColorSize
		attributes[4]		= 24
		attributes[5]		= NSOpenGLPFADepthSize
		attributes[6]		= 16
		attributes[7]		= NSOpenGLPFADoubleBuffer
		attributes[8]		= NSOpenGLPFAAccelerated
		attributes[9]		= 0

	
		# Create the FullScreen NSOpenGLContext with the attributes listed above :
		pixel_format		= NSOpenGLPixelFormat.alloc.initWithAttributes(attributes)


		# Just as a diagnostic, report the renderer ID that this pixel format binds to.
		# CGLRenderers.h contains a list of known renderers and their corresponding RendererID codes.
		renderer_id			= Pointer.new_with_type('i')
		pixel_format.getValues(renderer_id, forAttribute:NSOpenGLPFARendererID, forVirtualScreen:0)
		puts "NSOpenGLView pixelFormat RendererID = %08x" % renderer_id[0]

	
		# Create an NSOpenGLContext with the FullScreen pixel format.
		# By specifying the non-FullScreen context as our "shareContext", we automatically inherit ...
		# ... all of the textures, display lists, and other OpenGL objects it has defined.
		fullscreen_context	= NSOpenGLContext.alloc.initWithFormat(pixel_format, shareContext:@opengl_view.openGLContext)


		if fullscreen_context == nil then
			puts "Failed to create fullScreenContext"
        end

	
		# Pause animation in the OpenGL view.  While we're in full-screen mode, we'll drive the animation actively instead of using a timer callback.
		#stop_animation_timer if @animation_flag
    
		# From here, we have to be carefull not to lock ourselves in fullscreen mode :
		begin

			# Take control of the display where we're about to go FullScreen.
			error				= CGCaptureAllDisplays()
			
			return if error != CGDisplayNoErr
			
			
			# Enter FullScreen mode and make our FullScreen context the active context for OpenGL commands.
			fullscreen_context.setFullScreen
			fullscreen_context.makeCurrentContext
			
			
			# Save the current swap interval so we can restore it later, and then set the new swap interval to lock us to the display's refresh rate.
			old_swap_interval	= Pointer.new_with_type('i')
			new_swap_interval	= Pointer.new_with_type('i')
			new_swap_interval[0]= 1
			
			cgl_context			= CGLGetCurrentContext()
			
			CGLGetParameter(cgl_context, KCGLCPSwapInterval, old_swap_interval)
			CGLSetParameter(cgl_context, KCGLCPSwapInterval, new_swap_interval)
			
			
			# Tell the scene the dimensions of the area it's going to render to, ...
			# ... so it can set up an appropriate viewport and viewing transformation :
			w					= CGDisplayPixelsWide(main_display_id)
			h					= CGDisplayPixelsHigh(main_display_id)

			@scene.set_viewport_rectangle([0, 0, w, h])


			# Now that we've got the screen, we enter a loop in which we alternately process input events and computer and render the next frame of our animation.
			# The shift here is from a model in which we passively receive events handed to us by the AppKit to one in which we are actively driving event processing.
			time_before			= CFAbsoluteTimeGetCurrent()
			@stay_in_fullscreen_mode	= true

			while @stay_in_fullscreen_mode do
				
				# Check for and process input events =
				event	= NSApp.nextEventMatchingMask(NSAnyEventMask, untilDate:NSDate.distantPast, inMode:NSDefaultRunLoopMode, dequeue:true)
				while (event != nil) do
					
					case event.type
						when NSLeftMouseDown
						mouseDown(event)
						
						when NSLeftMouseUp
						mouseUp(event)
						
						when NSLeftMouseDragged
						mouseDragged(event)
						
						when NSKeyDown
						#keyDown(event)
						@stay_in_fullscreen_mode	= false
						
					end
					
				end
					
					# Update our animation :
					time_now	= CFAbsoluteTimeGetCurrent
					@scene.advance_time_by(time_now - time_before) if @animation_flag
					time_before = time_now
					
					# Render a frame, and swap the front and back buffers :
					@scene.render
					fullscreen_context.flushBuffer
					
				end
				
				
				# Clear the front and back framebuffers before switching out of FullScreen mode.  (This is not strictly necessary, but avoids an untidy flash of garbage.)
				glClearColor(0.0, 0.0, 0.0, 0.0)
				glClear(GL_COLOR_BUFFER_BIT)
				fullscreen_context.flushBuffer
				glClear(GL_COLOR_BUFFER_BIT)
				fullscreen_context.flushBuffer
				
				
				# Restore the previously set swap interval :
				CGLSetParameter(cgl_context, KCGLCPSwapInterval, old_swap_interval)
				
				
				# Exit fullscreen mode and release our FullScreen NSOpenGLContext :
				NSOpenGLContext.clearCurrentContext
				fullscreen_context.clearDrawable

		rescue Exception
			puts "There was a problem while in fullscreen mode !"
			CGReleaseAllDisplays()

		end

		# Release control of the display :
		CGReleaseAllDisplays()


		# Mark our view as needing drawing.  (The animation has advanced while we were in FullScreen mode, so its current contents are stale.)
		setNeedsDisplay(true)


		# Resume animation timer firings :
		start_animation_timer if @animation_flag

	end

end