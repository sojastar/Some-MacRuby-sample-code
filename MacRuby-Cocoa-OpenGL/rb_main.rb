#
# rb_main.rb
# MacRuby Cocoa OpenGL
#
###

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'
framework 'OpenGL'


# Finding the path to the application bundle resource directory :
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation

# Loading the ObjC bundle :
require "#{dir_path}/ObjectiveCGLString"

# Loading all the Ruby project files :
Dir.entries(dir_path).each do |path|
  if path != File.basename(__FILE__) and path[-3..-1] == '.rb'
    require(path)
  end
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
