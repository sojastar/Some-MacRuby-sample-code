#
#  MyController.rb
#  MacRuby Cocoa OpenGL
#
###

class MyController

	attr_accessor	:opengl_view,
					:fullscreen,
					:scene



	def awakeFromNib

		# Setting the scene :
		@scene				= Scene.new


		# Starting the animation :
		start_animation_timer

	end





	def keyDown(the_event)

		characters = the_event.characters

		if characters.length > 0 then

			first_character = characters[0]

			case
			# Pressing space enters fullscreen mode :
			when first_character.bytes.to_a[0] == 32
				@fullscreen.go_fullscreen

			# Pressing escape exits fullscreen mode :
			when first_character.bytes.to_a[0] == 27
				@fullscreen.stay_in_fullscreen_mode	= false

			end

		end


	end





	def mouseDown(the_event)

		# No animation while dragging :
		stop_animation_timer


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

                @scene.drag_x_angle	+= -0.5 * dx
                @scene.drag_y_angle	+= -0.5 * dy

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


		# Resume animating :
		if @fullscreen.stay_in_fullscreen_mode then
			@fullscreen.before	= CFAbsoluteTimeGetCurrent()
		else
			start_animation_timer
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

end