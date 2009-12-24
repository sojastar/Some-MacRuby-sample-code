#
#  MyOpenGLView.rb
#  MacRuby Cocoa OpenGL
#
###

class MyOpenGLView < NSOpenGLView

	attr_reader	:scene

	attr_writer :controller



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

		puts "NSOpenGLView pixelFormat RendererID = %016x" % renderer_id[0]


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

end