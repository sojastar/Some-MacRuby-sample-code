#
#  BoingWindow.rb
#  MacRuby BoingX
#
###

class BoingWindow < NSWindow

	# This is here just so that keyboards events work even though we're a borderless window
	# (normally they would not).
	def canBecomeKeyWindow
		return true
	end

end