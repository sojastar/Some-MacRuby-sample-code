#
#  GLCheck.rb
#  MacRuby Cocoa OpenGL
#
###

module GLCheck

	# This checks to if things have changed without being too heavy weight :
	# returns 1 if changed 0 if not.
	# Checks num displays, displayID, displayMask, each display geometry and 
	# renderer VRAM and ID
	#
	###
	def GLCheck.have_opengl_capacities_changed(display_capacities, display_count)

		max_displays		= 32
		active_displays		= Pointer.new_with_type('^L')
		new_display_count	= Pointer.new_with_type('I')


		# If the display capacities list is empty then capacities list has changed.
		if display_capacities == nil then return true end


		display_error = CGGetActiveDisplayList(max_displays, active_displays, new_display_count)
		# If the call resulted in an error then the capacities list has changed.
		if display_error != 0 then return true end
		# If the number of displays has changed then the list has changed too.
		if display_count[0] != new_display_count[0] then return true end


		# Checking all displays :
		display_count[0].times do |i|

			# Testing display's id and mask :
			if display_capacities[i][:cg_display_id]	then return true end
			if display_capacities[i][:cgl_display_mask] then return true end


			# Get the display's geometry and mode :
			display_rectangle	= CGDisplayBounds(active_displays[0][i])
			display_mode		= CGDisplayCurrentMode(display_ids[0][i])

			# Do they match ?
			if display_capacities[i][:display_width]	!= display_rectangle.size.width		then return 1 end
			if display_capacities[i][:display_height]	!= display_rectangle.size.height	then return 1 end
			if display_capacities[i][:display_origin_x] != display_rectangle.origin.x		then return 1 end
			if display_capacities[i][:display_origin_y] != display_rectangle.origin.y		then return 1 end
			if display_capacities[i][:display_depth]	!= display_mode["BitsPerPixel"]		then return 1 end
			if display_capacities[i][:display_refresh]	!= display_mode["RefreshRate"]		then return 1 end


			# Get the renderer's info :
			renderer_info	= Pointer.new_with_type("^{_CGLRendererInfoObject=}")
			renderer_count	= Pointer.new_with_type("l")
			renderer_value	= Pointer.new_with_type("l")

			renderer_error	= CGLQueryRendererInfo(	display_capacities[i][:cgl_display_mask],
													renderer_info,
													renderer_count )

			if renderer_error == 0 then

				CGLDescribeRenderer(renderer_info, 0, kCGLRPRendererCount, renderer_count)

				renderer_count[0].times do |j|

					# Find accelerated renderer (assume only one) :
					CGLDescribeRenderer(renderer_info, j, kCGLRPAccelerated, renderer_value)

					if renderer_value[0] == 1 then	# If it is accelerated :
						# What is the renderer's id :
						CGLDescribeRenderer(renderer_info, j, kCGLRPRendererID, renderer_value)
						if renderer_value[0] != display_capacities[i][:renderer_id] then return false end
						# What is the VRAM :
						CGLDescribeRenderer(renderer_info, j, kCGLRPVideoMemory, renderer_value)
						if renderer_value[0] != display_capacities[i][:device_vram] then return false end
						break
					end

				end

			end

			CGLDestroyRendererInfo(renderer_info)

		end

		return false

	end





	# This will walk all active displays and gather information about their
	# hardware renderer 
	#
	# An array length (max_displays) and array of GLCaps are passed in. Up to
	# maxDisplays of the array are filled in with the displays meeting the
	# specified criteria.  The actual number of displays filled in is returned
	# in dspyCnt.  Calling this function with max_displays of 0 will just
	# return the number of displays in dspyCnt.
	#
	# Developers should note this is NOT an exhaustive list of all the
	# capabilities one could query, nor a required set of capabilities,
	# feel free to add or subtract queries as you find helpful for your 
	# application/use.
	#
	# one note on mirrored displays... if the display configuration is 
	# changed it is possible (and likely) that the current active display
	# in a mirrored configuration (as identified by the OpenGL Display Mask)
	# will change if the mirrored display is removed.  
	# This is due to the preference of selection the external display as 
	# the active display.  This may affect full screen apps which should 
	# always detect display configuration changes and respond accordingly.
	#
	###
	def GLCheck.check_opengl_capacities(max_displays)

		display_ids			= Pointer.new_with_type('^I')

		display_capacities	= []	#nil
		
		display_count		= Pointer.new_with_type('I')
		display_count[0]	= 0								# no display yet


		# Find the number of displays :
		###
		if max_displays == 0 then

			# This call to CGGetActiveDisplayList will return the number of displays in display_count.
			display_ids.assign(Array.new(32,0))
			display_error = CGGetActiveDisplayList(32, display_ids[0], display_count)

			if display_error != 0 then	# If the call resulted in an error ...
				display_count.assign(0)	# ... then no display is available.
			end

			#display_ids.assign([0])	# Zero list to ensure the routines are used correctly

			return nil,display_count[0]

		end


		# If no display capacities storage was passed, abort :
		###
		#if display_capacities == nil then return end
		#display_capacities = [] if display_capacities == nil


		# Find the capacities for each of the found displays :
		###

		display_ids.assign(Array.new(max_displays, 0))

		display_error = CGGetActiveDisplayList(max_displays, display_ids[0], display_count)

		if display_error != 0		then return end
		if display_count[0] == 0	then return end

		display_count[0].times do |i|

			caps = {}			# create a new hash to store the capacities

			# Get display ids :
			caps[:cg_display_id]	= display_ids[0][i]
			caps[:cgl_display_mask]	= CGDisplayIDToOpenGLDisplayMask(display_ids[0][i])


			# Get display geometry and mode :
			display_rectangle	= CGDisplayBounds(display_ids[0][i])
			display_mode		= CGDisplayCurrentMode(display_ids[0][i])

			caps[:display_width]	= display_rectangle.size.width#.to_i
			caps[:display_height]	= display_rectangle.size.height
			caps[:display_origin_x]	= display_rectangle.origin.x
			caps[:display_origin_y]	= display_rectangle.origin.y
			caps[:display_depth]	= display_mode["BitsPerPixel"]
			caps[:display_refresh]	= display_mode["RefreshRate"]

			# Get renderer info :
			#renderer_info	= Pointer.new_with_type("^{_CGLRendererInfoObject=}")
			renderer_info	= Pointer.new_with_type("^{_CGLRendererInfoObj}")
			renderer_count	= Pointer.new_with_type("i")
			renderer_value	= Pointer.new_with_type("i")
			puts "there"
			renderer_error	= CGLQueryRendererInfo(	caps[:cgl_display_mask],
													renderer_info,
													renderer_count )

			if renderer_error == 0 then		# If the info is successfully retrieved :

				# Get the renderers count :

				CGLDescribeRenderer(renderer_info[0],
									0,
									KCGLRPRendererCount,
									renderer_count)

				# Get the info for each renderer and store it :
				renderer_count[0].times do |j|

					# Accelerated renderer ?
					CGLDescribeRenderer (renderer_info[0], j, KCGLRPAccelerated, renderer_value)

					if renderer_value == 1 then		# If the renderer is accelerated :

						# What is the renderer ID ?
						CGLDescribeRenderer (renderer_info[0], j, KCGLRPRendererID, renderer_value)
						caps[:renderer_id] = renderer_value

						# Can we do full screen ?
						CGLDescribeRenderer (renderer_info[0], j, KCGLRPFullScreen, renderer_value)
						case renderer_value[0]
						when 1 then
							caps[:full_screen_capable] = true
						when 2 then
							caps[:full_screen_capable] = false
						else
							caps[:full_screen_capable] = false
						end

						# How much VRAM ?
						CGLDescribeRenderer (renderer_info[0], j, KCGLRPVideoMemory, renderer_value)
						caps[:device_vram] = renderer_value[0]

						# How much texture memory ?
						CGLDescribeRenderer (renderer_info[0], j, KCGLRPTextureMemory, renderer_value)
						caps[:device_texture_ram] = renderer_value[0]

						break

					end

				end

			end

			# Disposing of the CGLRendererInfoObject object :
			CGLDestroyRendererInfo(renderer_info[0])


			# Context info :
			pixel_format		= Pointer.new_with_type("^{_CGLPixelFormatObject=}")
			pixel_format_count	= Pointer.new_with_type("l")
			current_context		= Pointer.new_with_type("^{_CGLContextObject=}")
			cgl_context			= Pointer.new_with_type("^{_CGLContextObject=}")


			# Get the current CGL context
			current_context.assign(CGLGetCurrentContext())


			# Choose a pixel format
			CGLChoosePixelFormat(	[KCGLPFADisplayMask, caps[:cgl_display_mask], 0],
									pixel_format,
									pixel_format_count)

			if pixel_format != nil then

				CGLCreateContext(pixel_format[0], nil, cgl_context)
				CGLDestroyPixelFormat(pixel_format[0])
				CGLSetCurrentContext(cgl_context[0])

				if cgl_context != nil then

					# Some more renderer info :
					caps[:renderer_name]	= glGetString(GL_RENDERER)
					caps[:renderer_vendor]	= glGetString(GL_VENDOR)
					caps[:renderer_version]	= glGetString(GL_VERSION)

					version = caps[:renderer_version].slice(/\d+\.\d+/)		# Extract the OpenGL version from the renderer version
					shift	= 8
					v		= 0
					version.length.times do |j|								# Compute the OpenGL version
						c = version.slice(j,1)
						if c != '.' then
							v += c.to_i << shift
							shift-=4
						end
					end
					caps[:opengl_version]	= v


					# Get the texture capacities :
					cap_value	= Pointer.new_with_type('l')
					glGetIntegerv(GL_MAX_TEXTURE_UNITS, cap_value)
					caps[:texture_units]				= cap_value[0]
					glGetIntegerv(GL_MAX_TEXTURE_SIZE, cap_value)
					caps[:max_texture_size]				= cap_value[0]
					glGetIntegerv(GL_MAX_3D_TEXTURE_SIZE, cap_value)
					caps[:max_3D_texture_size]			= cap_value[0]
					glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, cap_value)
					caps[:max_cube_map_texture_size]	= cap_value[0]


					# Get functionality info :
					extensions = glGetString (GL_EXTENSIONS)

					caps[:aux_dept_stencil]				= gluCheckExtension("GL_APPLE_aux_depth_stencil", extensions)
					caps[:client_storage]				= gluCheckExtension("GL_APPLE_client_storage", extensions)
					caps[:element_array]				= gluCheckExtension("GL_APPLE_element_array", extensions)
					caps[:fence]						= gluCheckExtension("GL_APPLE_fence", extensions)
					caps[:float_pixels]					= gluCheckExtension("GL_APPLE_float_pixels", extensions)
					caps[:flush_buffer_range]			= gluCheckExtension("GL_APPLE_flush_buffer_range", extensions)
					caps[:flush_renderer]				= gluCheckExtension("GL_APPLE_flush_render", extensions)
					caps[:object_purgeable]				= gluCheckExtension("GL_APPLE_object_purgeable", extensions)
				
					if caps[:opengl_version] >= 288 then
						flag = 1
					else
						flag = 0
					end
					caps[:packed_pixels]				= gluCheckExtension("GL_APPLE_packed_pixels", extensions) ||
														  gluCheckExtension("GL_APPLE_packed_pixel", extensions) ||
														  flag
					
					caps[:pixel_buffer]					= gluCheckExtension("GL_APPLE_pixel_buffer", extensions)
					caps[:specular_vector]				= gluCheckExtension("GL_APPLE_specular_vector", extensions)
					caps[:texture_range]				= gluCheckExtension("GL_APPLE_texture_range", extensions)
					caps[:transform_hint]				= gluCheckExtension("GL_APPLE_transform_hint", extensions)
					caps[:VAO]							= gluCheckExtension("GL_APPLE_vertex_array_object", extensions)
					caps[:VAR]							= gluCheckExtension("GL_APPLE_vertex_array_range", extensions)
					caps[:VP_evals]						= gluCheckExtension("GL_APPLE_vertex_program_evaluators", extensions)
					caps[:YCbCr]						= gluCheckExtension("GL_APPLE_ycbcr_422", extensions)
					caps[:depth_tex]					= gluCheckExtension("GL_ARB_depth_texture", extensions)
					caps[:draw_buffers]					= gluCheckExtension("GL_ARB_draw_buffers", extensions)
					caps[:fragment_prog]				= gluCheckExtension("GL_ARB_fragment_program", extensions)
					caps[:fragment_prog_shadow]			= gluCheckExtension("GL_ARB_fragment_program_shadow", extensions)
					caps[:fragment_shader]				= gluCheckExtension("GL_ARB_fragment_shader", extensions)
					caps[:half_float_pixel]				= gluCheckExtension("GL_ARB_half_float_pixel", extensions)
					caps[:imaging]						= gluCheckExtension("GL_ARB_imaging", extensions)
					caps[:multisample]					= gluCheckExtension("GL_ARB_multisample", extensions)
					caps[:multitexture]					= gluCheckExtension("GL_ARB_multitexture", extensions)
					caps[:occlusion_query]				= gluCheckExtension("GL_ARB_occlusion_query", extensions)
					caps[:PBO]							= gluCheckExtension("GL_ARB_pixel_buffer_object", extensions)
					caps[:point_param]					= gluCheckExtension("GL_ARB_point_parameters", extensions)
					caps[:point_sprite]					= gluCheckExtension("GL_ARB_point_sprite", extensions)
					caps[:shader_objects]				= gluCheckExtension("GL_ARB_shader_objects", extensions)
					caps[:shader_texture_LOD]			= gluCheckExtension("GL_ARB_shader_texture_lod", extensions)
					caps[:shading_language_100]			= gluCheckExtension("GL_ARB_shading_language_100", extensions)
					caps[:shadow]						= gluCheckExtension("GL_ARB_shadow", extensions)
					caps[:shadow_ambient]				= gluCheckExtension("GL_ARB_shadow_ambient", extensions)
					caps[:texture_border_clamp]			= gluCheckExtension("GL_ARB_texture_border_clamp", extensions)
					caps[:texture_compress]				= gluCheckExtension("GL_ARB_texture_compression", extensions)
					caps[:texture_cube_map]				= gluCheckExtension("GL_ARB_texture_cube_map", extensions)
					caps[:texture_env_add]				= gluCheckExtension("GL_ARB_texture_env_add", extensions) ||
														  gluCheckExtension("GL_EXT_texture_env_add", extensions)
					caps[:texture_env_combine]			= gluCheckExtension("GL_ARB_texture_env_combine", extensions)
					caps[:texture_env_crossbar]			= gluCheckExtension("GL_ARB_texture_env_crossbar", extensions)
					caps[:texture_env_dot3]				= gluCheckExtension("GL_ARB_texture_env_dot3", extensions)
					caps[:texture_float]				= gluCheckExtension("GL_ARB_texture_float", extensions)
					caps[:texture_mirror_repeat]		= gluCheckExtension("GL_ARB_texture_mirrored_repeat", extensions)
					caps[:texture_NPOT]					= gluCheckExtension("GL_ARB_texture_non_power_of_two", extensions)
					caps[:texture_rectangle_ARB]		= gluCheckExtension("GL_ARB_texture_rectangle", extensions)
					caps[:transpose_matrix]				= gluCheckExtension("GL_ARB_transpose_matrix", extensions)
					caps[:vertex_blend]					= gluCheckExtension("GL_ARB_vertex_blend", extensions)
					caps[:VBO]							= gluCheckExtension("GL_ARB_vertex_buffer_object", extensions)
					caps[:vertex_program]				= gluCheckExtension("GL_ARB_vertex_program", extensions)
					caps[:vertex_shader]				= gluCheckExtension("GL_ARB_vertex_shader", extensions)
					caps[:window_pos]					= gluCheckExtension("GL_ARB_window_pos", extensions)
					caps[:array_rev_comps_4Byte]		= gluCheckExtension("GL_ATI_array_rev_comps_in_4_bytes", extensions)
					caps[:ATI_blend_equation_separate]	= gluCheckExtension("GL_ATI_blend_equation_separate", extensions)
					caps[:blend_weight_min_max]			= gluCheckExtension("GL_ATI_blend_weighted_minmax", extensions)
					caps[:pn_triangles]					= gluCheckExtension("GL_ATI_pn_triangles", extensions) |
														  gluCheckExtension("GL_ATIX_pn_triangles", extensions)
					caps[:point_cull]					= gluCheckExtension("GL_ATI_point_cull_mode", extensions)
					caps[:separate_stencil]				= gluCheckExtension("GL_ATI_separate_stencil", extensions)
					caps[:texture_fragment_shader]		= gluCheckExtension("GL_ATI_text_fragment_shader", extensions)
					caps[:texture_compression_3dc]		= gluCheckExtension("GL_ATI_texture_compression_3dc", extensions)
					caps[:combine3]						= gluCheckExtension("GL_ATI_texture_env_combine3", extensions)
					caps[:texture_ATI_float]			= gluCheckExtension("GL_ATI_texture_float", extensions)
					caps[:texture_mirror_once]			= gluCheckExtension("GL_ATI_texture_mirror_once", extensions)
					caps[:ABGR]							= gluCheckExtension("GL_EXT_abgr", extensions)
					caps[:BGRA]							= gluCheckExtension("GL_EXT_bgra", extensions)
					caps[:blend_color]					= gluCheckExtension("GL_EXT_blend_color", extensions) ||
														  gluCheckExtension("GL_ARB_imaging", extensions)
					caps[:blend_equation_separate]		= gluCheckExtension("GL_EXT_blend_equation_separate", extensions)
					caps[:blend_function_separate]		= gluCheckExtension("GL_EXT_blend_func_separate", extensions)
					caps[:blend_min_max]				= gluCheckExtension("GL_EXT_blend_minmax", extensions) ||
														  gluCheckExtension("GL_ARB_imaging", extensions)
					caps[:blend_subtract]				= gluCheckExtension("GL_EXT_blend_subtract", extensions) ||
														  gluCheckExtension("GL_ARB_imaging", extensions)
					caps[:clip_volume_hint]				= gluCheckExtension("GL_EXT_clip_volume_hint", extensions)
					caps[:color_subtable]				= gluCheckExtension("GL_EXT_color_subtable", extensions) ||
														  gluCheckExtension("GL_ARB_imaging", extensions)
					caps[:CVA]							= gluCheckExtension("GL_EXT_compiled_vertex_array", extensions)
					caps[:depth_bounds]					= gluCheckExtension("GL_EXT_depth_bounds_test", extensions)
					caps[:convolution]					= gluCheckExtension("GL_EXT_convolution", extensions) ||
														  gluCheckExtension("GL_ARB_imaging", extensions)
					caps[:draw_range_elements]			= gluCheckExtension("GL_EXT_draw_range_elements", extensions)
					caps[:fog_coordinates]				= gluCheckExtension("GL_EXT_fog_coord", extensions)
					caps[:FBO_blit]						= gluCheckExtension("GL_EXT_framebuffer_blit", extensions)
					caps[:FBO]							= gluCheckExtension("GL_EXT_framebuffer_object", extensions)
					caps[:geometry_shader4]				= gluCheckExtension("GL_EXT_geometry_shader4", extensions)
					caps[:GPU_program_parameters]		= gluCheckExtension("GL_EXT_gpu_program_parameters", extensions)
					caps[:GPU_shader4]					= gluCheckExtension("GL_EXT_gpu_shader4", extensions)
					caps[:histogram]					= gluCheckExtension("GL_EXT_histogram", extensions) ||
														  gluCheckExtension("GL_ARB_imaging", extensions)
					caps[:depth_stencil]				= gluCheckExtension("GL_EXT_packed_depth_stencil", extensions)
					caps[:multi_draw_arrays]			= gluCheckExtension("GL_EXT_multi_draw_arrays", extensions)
					caps[:paletted_texture]				= gluCheckExtension("GL_EXT_paletted_texture", extensions)
					caps[:rescale_normal]				= gluCheckExtension("GL_EXT_rescale_normal", extensions)
					caps[:secondary_color]				= gluCheckExtension("GL_EXT_secondary_color", extensions)
					caps[:separate_specular_color]		= gluCheckExtension("GL_EXT_separate_specular_color", extensions)
					caps[:shadow_functions]				= gluCheckExtension("GL_EXT_shadow_funcs", extensions)
					caps[:shared_texture_palette]		= gluCheckExtension("GL_EXT_shared_texture_palette", extensions)
					caps[:stencil_two_side]				= gluCheckExtension("GL_EXT_stencil_two_side", extensions)
					caps[:stencil_wrap]					= gluCheckExtension("GL_EXT_stencil_wrap", extensions)
					caps[:texture_compression_DXT1]		= gluCheckExtension("GL_EXT_texture_compression_dxt1", extensions)
					caps[:texture3D]					= gluCheckExtension("GL_EXT_texture3D", extensions)
					caps[:texture_compression_S3TC]		= gluCheckExtension("GL_EXT_texture_compression_s3tc", extensions)
					caps[:texture_filter_anisotropic]	= gluCheckExtension("GL_EXT_texture_filter_anisotropic", extensions)
					caps[:texture_LOD_bias]				= gluCheckExtension("GL_EXT_texture_lod_bias", extensions)
					caps[:texture_mirror_clamp]			= gluCheckExtension("GL_EXT_texture_mirror_clamp", extensions)
					caps[:texture_rectangle]			= gluCheckExtension("GL_EXT_texture_rectangle", extensions)
					caps[:texture_sRGB]					= gluCheckExtension("GL_EXT_texture_sRGB", extensions)
					caps[:transform_feedback]			= gluCheckExtension("GL_EXT_transform_feedback", extensions)
					caps[:convolution_border_modes]		= gluCheckExtension("GL_HP_convolution_border_modes", extensions) ||
														  gluCheckExtension("GL_ARB_imaging", extensions)
					caps[:rasterpos_clip]				= gluCheckExtension("GL_IBM_rasterpos_clip", extensions)
					caps[:blend_square]					= gluCheckExtension("GL_NV_blend_square", extensions)
					caps[:depth_clamp]					= gluCheckExtension("GL_NV_depth_clamp", extensions)
					caps[:fog_distance]					= gluCheckExtension("GL_NV_fog_distance", extensions)
					caps[:light_max_exponent]			= gluCheckExtension("GL_NV_light_max_exponent", extensions)
					caps[:multisample_filter_hint]		= gluCheckExtension("GL_NV_multisample_filter_hint", extensions)
					caps[:NV_point_sprite]				= gluCheckExtension("GL_NV_point_sprite", extensions)
					caps[:register_combiners]			= gluCheckExtension("GL_NV_register_combiners", extensions)
					caps[:register_combiners2]			= gluCheckExtension("GL_NV_register_combiners2", extensions)
					caps[:texgen_reflection]			= gluCheckExtension("GL_NV_texgen_reflection", extensions)
					caps[:texture_en_combine4]			= gluCheckExtension("GL_NV_texture_env_combine4", extensions)
					caps[:texture_shader]				= gluCheckExtension("GL_NV_texture_shader", extensions)
					caps[:texture_shader2]				= gluCheckExtension("GL_NV_texture_shader2", extensions)
					caps[:texture_shader3]				= gluCheckExtension("GL_NV_texture_shader3", extensions)
					caps[:generate_mipmap]				= gluCheckExtension("GL_SGIS_generate_mipmap", extensions)
					caps[:texture_edge_clamp]			= gluCheckExtension("GL_SGIS_texture_edge_clamp", extensions)
					caps[:texture_LOD]					= gluCheckExtension("GL_SGIS_texture_lod", extensions)
					caps[:color_matrix]					= gluCheckExtension("GL_SGI_color_matrix", extensions)
					caps[:color_table]					= gluCheckExtension("GL_SGI_color_table", extensions) ||
														  gluCheckExtension("GL_ARB_imaging", extensions)

					if caps[:texture_rectangle] != 0 then
						glGetIntegerv(GL_MAX_RECTANGLE_TEXTURE_SIZE_EXT, cap_value)
						caps[:max_texture_size]				= cap_value[0]
					else
						caps[:max_rectangle_texture_size]	= 0
					end

					#CGLDestroyContext(cgl_context)
					CGLDestroyContext(cgl_context[0])

				end

			end

			# Store the capacities hash in an array :
			display_capacities << caps 

			# Reset current CGL context :
			CGLSetCurrentContext(current_context)

		end

		return display_capacities, display_count[0]

	end

end
