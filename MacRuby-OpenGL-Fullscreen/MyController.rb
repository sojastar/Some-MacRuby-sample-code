#
#  MyController.rb
#  MacRuby Cocoa OpenGL
#
###

class MyController

	#attr_reader	:full_screen_flag,
	#			:animation_flag

	attr_accessor :opengl_view, :full_screen_flag, :animation_flag



	def awakeFromNib

		@animation_flag	= false

		start_animation

	end





	def keyDown(the_event)

		characters = the_event.characters


		if characters.length > 0 then

			first_character = characters[0]

			case
			when first_character.bytes.to_a[0] == 27
				@stay_in_fullscreen_mode	= false
				puts "escape"

			when first_character.bytes.to_a[0] == 32
				puts "rotation"
				toggle_animation

			when first_character == 'w' || first_character == 'W'
				puts "wireframe"
				#toggle_wireframe

			end

		end


	end





	def mouseDown(the_event)

		

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

		@opengl_view.scene.advance_time_by(1.0/60.0)

		@opengl_view.setNeedsDisplay true

	end





	def start_animation

		unless @animation_flag then

			@animation_flag	= true

			start_animation_timer unless @full_screen_flag

		end

	end





	def stop_animation

		if @animation_flag then

			@animation_flag	= false

			stop_animation_timer if @animation_timer != nil

		end

	end





	def toggle_animation

		if @animation_flag then
			stop_animation

		else
			start_animation

		end

	end

end