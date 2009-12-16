#
#  DrawInfo.rb
#  MacRuby Cocoa OpenGL
#
###

#class CapacitiesTextures
class BasicOpenGLView

	def update_capacities_string

		

	end


	#def initialize(display_capacities, display_count)
	def make_textures

		# The textures array :
		@capacities_textures								= []


		# Draw attributes :
		bold12_attributes									= {}
		bold12_attributes[NSFontAttributeName]				= NSFont.fontWithName ("Helvetica-Bold", size:12.0)
		bold12_attributes[NSForegroundColorAttributeName]	= NSColor.whiteColor

		bold9_attributes									= {}
		bold9_attributes[NSFontAttributeName]				= NSFont.fontWithName ("Helvetica-Bold", size:9.0)
		bold9_attributes[NSForegroundColorAttributeName]	= NSColor.whiteColor

		normal9_attributes									= {}
		normal9_attributes[NSFontAttributeName]				= NSFont.fontWithName ("Helvetica", size:9.0)
		normal9_attributes[NSForegroundColorAttributeName]	= NSColor.whiteColor


		# For each display, draws the capacities string :
		display_count.times do |i|

			out_string		= NSMutableAttributedString.alloc.initWithString("GL Capabilities:", attributes:bold12_attributes)


			string			= NSString.stringWithFormat("\n  Max VRAM- %ld MB (%ld MB free)",
														display_capacities[i][:device_vram] / 1024 / 1024,
														display_capacities[i][:device_texture_ram] / 1024 / 1024)
			append_string	= NSMutableAttributedString.alloc.initWithString(string, attributes:normal9_attributes)
			out_string.appendAttributedString(append_string)


			string			= NSString.stringWithFormat("\n  Max Texture Size- 1D/2D: %ld, 3D: %ld, Cube: %ld, Rect: %ld (%ld texture units)",
														display_capacities[i][:max_texture_size],
														display_capacities[i][:max_3D_texture_size],
														display_capacities[i][:max_cube_map_texture_size],
														display_capacities[i][:max_rectangle_texture_size],
														display_capacities[i][:texture_units])
			append_string	= NSMutableAttributedString.alloc.initWithString(string, attributes:normal9_attributes)
			out_string.appendAttributedString(append_string)


			append_string	= NSMutableAttributedString.alloc.initWithString("\n Features:", attributes:bold9_attributes)
			out_string.appendAttributedString(append_string)
			

			if display_capacities[i][:aux_dept_stencil] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Aux depth and stencil (GL_APPLE_aux_depth_stencil)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:client_storage] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Client Storage (GL_APPLE_client_storage)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:element_array] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Element Array (GL_APPLE_element_array)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:fence] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Fence (GL_APPLE_fence)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:float_pixels] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Floating Point Pixels (GL_APPLE_float_pixels)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:flush_buffer_range] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Selective VBO flushing (GL_APPLE_flush_buffer_range)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:flush_renderer] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Flush Renderer (GL_APPLE_flush_render)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:object_purgeable] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Object Purgeability (GL_APPLE_object_purgeable)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:packed_pixels] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Packed Pixels (GL_APPLE_packed_pixels or OpenGL 1.2+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:pixel_buffer] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Pixel Buffers (GL_APPLE_pixel_buffer)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:specular_vector] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Specular Vector (GL_APPLE_specular_vector)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_range] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Range (AGP Texturing) (GL_APPLE_texture_range)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:transform_hint] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Transform Hint (GL_APPLE_transform_hint)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:VAO] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Vertex Array Object (GL_APPLE_vertex_array_object)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:VAR] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Vertex Array Range (GL_APPLE_vertex_array_range)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:VP_evals] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Vertex Program Evaluators (GL_APPLE_vertex_program_evaluators)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:YCbCr] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  YCbCr Textures (GL_APPLE_ycbcr_422)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:depth_tex] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Depth Texture (GL_ARB_depth_texture or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:draw_buffers] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Multiple Render Targets (GL_ARB_draw_buffers or OpenGL 2.0+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:fragment_prog] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Fragment Program (GL_ARB_fragment_program)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:fragment_prog_shadow] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Fragment Program Shadows (GL_ARB_fragment_program_shadow)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:fragment_shader] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Fragment Shaders (GL_ARB_fragment_shader or OpenGL 2.0+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:half_float_pixel] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Half Float Pixels (GL_ARB_half_float_pixel)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:imaging] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Imaging Subset (GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:multisample] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Multisample (Anti-aliasing) (GL_ARB_multisample or OpenGL 1.3+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:multitexture] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Multitexture (GL_ARB_multitexture or OpenGL 1.3+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:occlusion_query] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Occlusion Queries (GL_ARB_occlusion_query or OpenGL 1.5+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:PBO] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Pixel Buffer Objects (GL_ARB_pixel_buffer_object or OpenGL 2.1+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:point_param] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Point Parameters (GL_ARB_point_parameters or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:point_sprite] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Point Sprites (GL_ARB_point_sprite or OpenGL 2.0+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:shader_objects] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Shader Objects (GL_ARB_shader_objects or OpenGL 2.0+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:shader_texture_LOD] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Shader Texture LODs (GL_ARB_shader_texture_lod)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:shading_language_100] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Shading Language 1.0 (GL_ARB_shading_language_100 or OpenGL 2.0+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:shadow] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Shadow Support (GL_ARB_shadow or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:shadow_ambient] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Shadow Ambient (GL_ARB_shadow_ambient)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_border_clamp] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Border Clamp (GL_ARB_texture_border_clamp or OpenGL 1.3+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_compress] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Compression (GL_ARB_texture_compression or OpenGL 1.3+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_cube_map] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Env Cube Map (GL_ARB_texture_cube_map or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_env_add] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Env Add (GL_ARB_texture_env_add, GL_EXT_texture_env_add or OpenGL 1.3+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_env_combine] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Env Combine (GL_ARB_texture_env_combine or OpenGL 1.3+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_env_crossbar] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Env Crossbar (GL_ARB_texture_env_crossbar or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_env_dot3] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Env Dot3 (GL_ARB_texture_env_dot3 or OpenGL 1.3+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_float] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Floating Point Textures (GL_ARB_texture_float)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_mirror_repeat] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Mirrored Repeat (GL_ARB_texture_mirrored_repeat or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_NPOT] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Non Power of Two Textures (GL_ARB_texture_non_power_of_two or OpenGL 2.0+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_rectangle_ARB] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Rectangle (GL_ARB_texture_rectangle)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:transpose_matrix] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Transpose Matrix (GL_ARB_transpose_matrix or OpenGL 1.3+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:vertex_blend] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Vertex Blend (GL_ARB_vertex_blend)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:VBO] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Vertex Buffer Objects (GL_ARB_vertex_buffer_object or OpenGL 1.5+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:vertex_program] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Vertex Program (GL_ARB_vertex_program)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:vertex_shader] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Vertex Shaders (GL_ARB_vertex_shader or OpenGL 2.0+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:window_pos] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Window Position (GL_ARB_window_pos or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:array_rev_comps_4Byte] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Reverse 4 Byte Array Components (GL_ATI_array_rev_comps_in_4_bytes)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:ATI_blend_equation_separate] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Separate Blend Equations (GL_ATI_blend_equation_separate)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:blend_weight_min_max] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Blend Weighted Min/Max (GL_ATI_blend_weighted_minmax)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:pn_triangles] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  PN Triangles (GL_ATI_pn_triangles or GL_ATIX_pn_triangles)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:point_cull] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Point Culling (GL_ATI_point_cull_mode)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:separate_stencil] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Separate Stencil (GL_ATI_separate_stencil)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_fragment_shader] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Text Fragment Shader (GL_ATI_text_fragment_shader)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_compression_3dc] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  ATI 3dc Compressed Textures (GL_ATI_texture_compression_3dc)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:combine3] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Env Combine 3 (GL_ATI_texture_env_combine3)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_ATI_float] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  ATI Floating Point Textures (GL_ATI_texture_float)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_mirror_once] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Mirror Once (GL_ATI_texture_mirror_once)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:ABGR] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  ABGR Texture Support (GL_EXT_abgr)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:BGRA] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  BGRA Texture Support (GL_EXT_bgra or OpenGL 1.2+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:blend_color] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Blend Color (GL_EXT_blend_color or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:blend_equation_separate] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Separate Blending Equations for RGB and Alpha (GL_EXT_blend_equation_separate or OpenGL 2.0+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:blend_function_separate] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Separate Blend Function (GL_EXT_blend_func_separate or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:blend_min_max] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Blend Min/Max (GL_EXT_blend_minmax or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:blend_subtract] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Blend Subtract (GL_EXT_blend_subtract or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:clip_volume_hint] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Clip Volume Hint (GL_EXT_clip_volume_hint)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:color_subtable] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Color Subtable ( GL_EXT_color_subtable or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:CVA] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Compiled Vertex Array (GL_EXT_compiled_vertex_array)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:depth_bounds] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Depth Boundary Test (GL_EXT_depth_bounds_test)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:convolution] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Convolution ( GL_EXT_convolution or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:draw_range_elements] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Draw Range Elements (GL_EXT_draw_range_elements)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:fog_coordinates] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Fog Coordinate (GL_EXT_fog_coord)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:FBO_blit] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  FBO Blit (GL_EXT_framebuffer_blit)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:FBO] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Framebuffer Objects or FBOs (GL_EXT_framebuffer_object)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:geometry_shader4] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  4th Gen Geometry Shader (GL_EXT_geometry_shader4)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:GPU_program_parameters] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  GPU Program Parameters (GL_EXT_gpu_program_parameters)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:GPU_shader4] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  4th Gen GPU Shaders (GL_EXT_gpu_shader4)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:histogram] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Histogram ( GL_EXT_histogram or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:depth_stencil] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Packed Depth and Stencil (GL_EXT_packed_depth_stencil)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:multi_draw_arrays] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Multi-Draw Arrays (GL_EXT_multi_draw_arrays or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:paletted_texture] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Paletted Textures (GL_EXT_paletted_texture)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:rescale_normal] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Rescale Normal (GL_EXT_rescale_normal or OpenGL 1.2+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:secondary_color] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Secondary Color (GL_EXT_secondary_color or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:separate_specular_color] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Separate Specular Color (GL_EXT_separate_specular_color or OpenGL 1.2+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:shadow_functions] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Shadow Function (GL_EXT_shadow_funcs)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:shared_texture_palette] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Shared Texture Palette (GL_EXT_shared_texture_palette)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:stencil_two_side] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  2-Sided Stencil (GL_EXT_stencil_two_side)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:stencil_wrap] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Stencil Wrap (GL_EXT_stencil_wrap or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_compression_DXT1] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  DXT Compressed Textures (GL_EXT_texture_compression_dxt1)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture3D] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  3D Texturing (GL_EXT_texture3D or OpenGL 1.2+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_compression_S3TC] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Compression S3TC (GL_EXT_texture_compression_s3tc)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_filter_anisotropic] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Anisotropic Texture Filtering (GL_EXT_texture_filter_anisotropic)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_LOD_bias] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Level Of Detail Bias (GL_EXT_texture_lod_bias or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_mirror_clamp] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture mirror clamping (GL_EXT_texture_mirror_clamp)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_rectangle] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Rectangle (GL_EXT_texture_rectangle)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_sRGB] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  sRGB Textures (GL_EXT_texture_sRGB or OpenGL 2.1+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:transform_feedback] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Transform Feedback (GL_EXT_transform_feedback)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:convolution_border_modes] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Convolution Border Modes (GL_HP_convolution_border_modes or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:rasterpos_clip] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Raster Position Clipping (GL_IBM_rasterpos_clip)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:blend_square] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Blend Square (GL_NV_blend_square or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:depth_clamp] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Depth Clamp (GL_NV_depth_clamp)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:fog_distance] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Eye Radial Fog Distance (GL_NV_fog_distance)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:light_max_exponent] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Light Max Exponent (GL_NV_light_max_exponent)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:multisample_filter_hint] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Multi-Sample Filter Hint (GL_NV_multisample_filter_hint)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:NV_point_sprite] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  NV Point Sprites (GL_NV_point_sprite)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:register_combiners] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Register Combiners (GL_NV_register_combiners)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:register_combiners2] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Register Combiners 2 (GL_NV_register_combiners2)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texgen_reflection] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  TexGen Reflection (GL_NV_texgen_reflection)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_en_combine4] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Env Combine 4 (GL_NV_texture_env_combine4)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_shader] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Shader (GL_NV_texture_shader)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_shader2] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Shader 2 (GL_NV_texture_shader2)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_shader3] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Shader 3 (GL_NV_texture_shader3)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:generate_mipmap] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  MipMap Generation (GL_SGIS_generate_mipmap or OpenGL 1.4+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_edge_clamp] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Edge Clamp (GL_SGIS_texture_edge_clamp or OpenGL 1.2+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:texture_LOD] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Texture Level Of Detail (GL_SGIS_texture_lod or OpenGL 1.2+)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:color_matrix] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Color Matrix ( GL_SGI_color_matrix or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end
			if display_capacities[i][:color_table] == 1 then
				append_string	= NSMutableAttributedString.alloc.initWithString("\n  Color Table ( GL_SGI_color_table or GL_ARB_imaging)", attributes:normal9_attributes)
				out_string.appendAttributedString(append_string)
			end


			text_color			= NSColor.colorWithDeviceRed(1.0, green:1.0, blue:1.0, alpha:1.0)
			box_color			= NSColor.colorWithDeviceRed(0.4, green:0.4, blue:0.0, alpha:0.4)
			border_color		= NSColor.colorWithDeviceRed(0.8, green:0.8, blue:0.0, alpha:0.8)

			capacities_texture	= GLString.new(	attributedString:out_string,
												withTextColor:text_color,
												withBoxColor:box_color,
												withBorderColor:border_color )


			@capacities_textures << capacities_texture

		end

	end





	# Draw the NSString capacities for this renderer :
	def draw_capacities_string_for_renderer(display_capacities, display_count, renderer, width)

		display_count.times do |i|

			# Match display in caps list :
			if renderer == display_capacities[i][:renderer_id] then
				@capacities_textures[i].drawAtPoint(NSMakePoint(width - 10.0 - @capacities_textures[i].frame.width, 10.0))
				break
			end

		end
	
	end

end
