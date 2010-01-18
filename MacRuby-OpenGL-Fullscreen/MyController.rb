#
#  MyController.rb
#  MacRuby Cocoa OpenGL
#
###

class MyController

	attr_accessor	:opengl_view,
					:fullscreen,
					:scene, :animating



	def awakeFromNib

		# Setting the scene :
		@scene				= Scene.new


		# Setting and starting the animation : 
		@animating			= false
		start_animation

	end





	def keyDown(the_event)

		characters = the_event.characters

		if characters.length > 0 then

			first_character = characters[0]

			case
			when first_character.bytes.to_a[0] == 27
				@fullscreen.stay_in_fullscreen_mode	= false

			when first_character.bytes.to_a[0] == 32
				toggle_animation

			when first_character == 'w' || first_character == 'W'
				@scene.wireframe	= !@scene.wireframe

			end

		end


	end





	def go_fullscreen(sender)

		@fullscreen.go_fullscreen

	end





	def mouseDown(the_event)

		# No animation while dragging :
		was_animating	= @animating
		stop_animation if was_animating


		# Dragging :
		dragging			= true
		last_window_point	= the_event.locationInWindow

		while dragging do
        
			the_event = opengl_view.window.nextEventMatchingMask(NSLeftMouseUpMask | NSLeftMouseDraggedMask)
			window_point = the_event.locationInWindow

			case the_event.type
			when NSLeftMouseUp
				dragging	= false
				
            when NSLeftMouseDragged
                dx = window_point.x - last_window_point.x
                dy = window_point.y - last_window_point.y
                @scene.sun_angle	+= -1.0 * dx
                @scene.roll_angle	+= -0.5 * dy
                last_window_point	 = window_point
				
                # Render a frame :
				if @fullscreen.stay_in_fullscreen_mode then
                    @scene.render
                    @fullscreen.fullscreen_context.flushBuffer

				else
                    @opengl_view.display
					

                end

			end

		end


		# Resume animating if was animating beofre dragging :
		if was_animating then
			start_animation
			@fullscreen.before	= CFAbsoluteTimeGetCurrent()
		end

	end





	def start_animation_timer

		if @animation_timer == nil then
			@animation_timer	= NSTimer.scheduledTimerWithTimeInterval(	1.0/60.0,
																			target:self,
																			selector:"animation_timer_fired:",
																			userInfo:nil,
																			repeats:true)
		end

	end





	def stop_animation_timer

		if @animation_timer != nil then

			@animation_timer.invalidate
			@animation_timer = nil

		end

	end





	def animation_timer_fired(timer)

		@scene.advance_time_by(1.0/60.0)

		@opengl_view.setNeedsDisplay true

	end





	def start_animation

		unless @animating then

			@animating	= true

			unless @fullscreen.stay_in_fullscreen_mode then
				start_animation_timer
			end

		end

	end





	def stop_animation

		if @animating then

			@animating	= false

			stop_animation_timer if @animation_timer != nil

		end

	end





	def toggle_animation

		if @animating == true then
			stop_animation

		else
			start_animation

		end

	end

end