#
#  GLString.rb
#  MacRuby Cocoa OpenGL
#
###





require 'ObjectiveCGLString'

class GLString



	def initialize(arguments)

		if arguments.class != Hash then		# Where the arguments passed as a hash ?
			return
		end


		# Calling the complete initializer with the right arguments :
		if	arguments.has_key?(:attributedString)	and
			arguments.has_key?(:withTextColor)		and
			arguments.has_key?(:withBoxColor)		and
			arguments.has_key?(:withBorderColor)	then

			# Call the complete initializing function :
			initWithAttributedString(	arguments[:attributedString],
										withTextColor:arguments[:withTextColor],
										withBoxColor:arguments[:withBoxColor],
										withBorderColor:arguments[:withBorderColor])

		elsif	arguments.has_key?(:string)				and
				arguments.has_key?(:withAttributes)		and
				arguments.has_key?(:withTextColor)		and
				arguments.has_key?(:withBoxColor)		and
				arguments.has_key?(:withBorderColor)	then

			# Create the NSAttributedString from the arguments :
			attributed_string	= NSAttributedString.alloc.initWithString(arguments[:string], attributes:arguments[:withAttributes])

			# Call the complete initializing function :
			initWithAttributedString(	attributed_string,
										withTextColor:arguments[:withTextColor],
										withBoxColor:arguments[:withBoxColor],
										withBorderColor:arguments[:withBorderColor])

		elsif arguments.has_key?(:attributedString) and arguments.length == 1 then

			# Default colors :
			text_color			= NSColor.colorWithDeviceRed 1.0, green:1.0, blue:1.0, alpha:1.0
			box_color			= NSColor.colorWithDeviceRed 1.0, green:1.0, blue:1.0, alpha:0.0
			border_color		= NSColor.colorWithDeviceRed 1.0, green:1.0, blue:1.0, alpha:0.0

			# Call the complete initializing function :
			initWithAttributedString(	arguments[:attributedString],
										withTextColor:text_color,
										withBoxColor:box_color,
										withBorderColor:border_color)

		elsif arguments.has_key?(:string) and arguments.has_key?(:withAttributes) then

			# Default colors :
			text_color			= NSColor.colorWithDeviceRed 1.0, green:1.0, blue:1.0, alpha:1.0
			box_color			= NSColor.colorWithDeviceRed 1.0, green:1.0, blue:1.0, alpha:0.0
			border_color		= NSColor.colorWithDeviceRed 1.0, green:1.0, blue:1.0, alpha:0.0

			# Create the NSAttributedString from the arguments :
			attributed_string	= NSAttributedString.alloc.initWithString(arguments[:string], attributes:arguments[:withAttributes])

			# Call the complete initializing function :
			initWithAttributedString(	attributed_string,
										withTextColor:text_color,
										withBoxColor:box_color,
										withBorderColor:border_color)
		end

	end





	def drawAtPoint(point)

		if requiresUpdate == 1 then
			generateTexture			# ensure size is calculated for bounds
		end

		if textureName != 0 then	# if successful
			drawWithBounds(NSMakeRect(point.x, point.y, textureSize.width, textureSize.height))
		end

	end
			

end