class MyOpenGLView < NSOpenGLView


	def drawRect(rect)

		glClearColor(0, 0, 0, 0)
		glClear(GL_COLOR_BUFFER_BIT)

		glColor3f(1.0, 0.85, 0.35)

		glBegin(GL_TRIANGLES)

		glVertex3f( 0.0,  0.6, 0.0)
		glVertex3f(-0.2, -0.3, 0.0)
		glVertex3f( 0.2, -0.3 ,0.0)

		glEnd

		glFlush

	end





	def awakeFromNib

		# Retrieving the OpenGL capabilities for each display's renderer :
		check_opengl_capabilities

	end





	def check_opengl_capabilities

		display_ids			= Pointer.new_with_type('^I')		# an array holding all the found displays' ids

		display_capabilities	= []								# an array holding all the found displays' renderers' capabilities ...
																# ... saved as hashes.
		
		display_count		= Pointer.new_with_type('I')		# how many displays do we have ?
		display_count[0]	= 0									# no display yet


		# Find the number of displays :
		###

		# This call to CGGetActiveDisplayList will return the number of displays in display_count.
		display_ids.assign(Array.new(32,0))
		display_error = CGGetActiveDisplayList(32, display_ids[0], display_count)

		if display_error != 0 then	# If the call resulted in an error ...
			puts "No display found\n"
			return	nil, 0

		else
			max_displays	= display_count[0]
			puts "Found #{display_count[0]} displays\n"

		end


		# Find the capabilities for each of the found displays :
		###

		display_ids.assign(Array.new(max_displays, 0))

		display_error = CGGetActiveDisplayList(max_displays, display_ids[0], display_count)

		return if ( display_error != 0 ) && ( display_count[0] == 0	)


		display_count[0].times do |i|

			caps					= {}

			caps[:cg_display_id]	= display_ids[0][i]
			caps[:cgl_display_mask]	= CGDisplayIDToOpenGLDisplayMask(display_ids[0][i])

			# Get renderer info :
			renderer_info	= Pointer.new_with_type("^{_CGLRendererInfoObject}")
			#renderer_info	= Pointer.new_with_type("^{_CGLRendererInfoObj}")
			renderer_count	= Pointer.new_with_type("i")
			renderer_value	= Pointer.new_with_type("i")

			renderer_error	= CGLQueryRendererInfo(	caps[:cgl_display_mask],
													renderer_info,
													renderer_count )

			if renderer_error == 0 then		# If the info is successfully retrieved :

				# How many renderers available for display number #{display_ids[0][i]} ?

				CGLDescribeRenderer(renderer_info[0],
									0,
									KCGLRPRendererCount,
									renderer_count)


			end

			CGLDestroyRendererInfo(renderer_info)

		end

	end

end