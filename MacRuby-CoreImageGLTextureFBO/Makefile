bundle_file := ObjectiveCMyOpenGLView.bundle
class_name := MyOpenGLView
class_file := $(class_name).m
header_file := $(class_name).h
project_build_directory := ./build/Debug
 
$(bundle_file) : $(class_file) $(header_file)
	# will need a -arch ppc -arch ppc64 for power pc boxes
	gcc -dynamiclib -framework Cocoa -framework OpenGL -fobjc-gc -arch i386 -arch x86_64 -o $(bundle_file) $(class_file)
	mkdir -p $(project_build_directory)
	cp $(bundle_file) $(project_build_directory)
 
clean: 
	rm -f $(bundle_file)