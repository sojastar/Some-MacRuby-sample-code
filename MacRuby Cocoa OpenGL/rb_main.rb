#
# rb_main.rb
# MacRuby Cocoa OpenGL
#
###

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'
framework 'OpenGL'

# Loading all the Ruby project files.
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
Dir.entries(dir_path).each do |path|
  if path != File.basename(__FILE__) and path[-3..-1] == '.rb'
	#puts "#{path}"
    require(path)
  end
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
