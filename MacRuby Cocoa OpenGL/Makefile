bundle_file := ObjectiveCGLString.bundle
class_name := GLString
class_file := $(class_name).m
header_file := $(class_name).h
 
$(bundle_file) : $(class_file) $(header_file)
	# will need a -arch ppc -arch ppc64 for power pc boxes
	gcc -dynamiclib -framework Cocoa -framework OpenGL -fobjc-gc -arch i386 -arch x86_64 -o $(bundle_file) $(class_file)
 
clean: 
	rm -f $(bundle_file)