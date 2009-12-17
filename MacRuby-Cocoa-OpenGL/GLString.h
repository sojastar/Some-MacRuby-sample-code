//
//  GLString.h
//  MacRuby Cocoa OpenGL
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLContext.h>





@interface NSBezierPath (RoundRect)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius;

- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius;

@end





@interface GLString : NSObject {

	CGLContextObj		cgl_context;	// current context at time of texture creation
	GLuint				textureName;
	NSSize				textureSize;
	
	NSAttributedString	* string;
	NSColor				* textColor;	// default is opaque white
	NSColor				* boxColor;		// default transparent or none
	NSColor				* borderColor;	// default transparent or none
	BOOL				staticFrame;	// default in NO
	BOOL				antialias;		// default to YES
	NSSize				marginSize;		// offset or frame size, default is 4 width 2 height
	NSSize				frameSize;		// offset or frame size, default is 4 width 2 height
	float				cornerRadius;	// corner radius, if 0 just a rectangle. Defaults to 4.0f
	
	BOOL				requiresUpdate;

}

+ (void)caca;
// Initializer :
- (id) initWithAttributedString:(NSAttributedString *)attributedString withTextColor:(NSColor *)text withBoxColor:(NSColor *)box withBorderColor:(NSColor *)border;



// This API requires a current rendering context and all operations will be performed in regards to thar context.
// The same context should be current for all method calls for a particular object instance.

- (void) generateTexture;				// generates the texture without drawing texture to current context
- (void) drawWithBounds:(NSRect)bounds;	// will update the texture if required due to change in settings
										// (note : context should be setup to be orthographic scaled to per pixel scale)


// Accessors :
- (GLuint)		textureName;

- (void)		setTextureSize:(NSSize)size;
- (NSSize)		textureSize;

- (void)		setTextColor:(NSColor *)color;		// set default text color
- (NSColor *)	textColor;
- (void)		setBoxColor:(NSColor *)color;		// set default text color
- (NSColor *)	boxColor;
- (void)		setBorderColor:(NSColor *)color;	// set default text color
- (NSColor *)	borderColor;

- (void)		setMarginSize:(NSSize)size;		// set offset size and size to fit with offset
- (NSSize)		marginSize;

- (void)		setAntialias:(bool)request;
- (BOOL)		antialias;

- (NSSize)		frameSize;

- (void)		useStaticFrame:(NSSize)size;	// set static frame size and size to frame
- (void)		useDynamicFrame;
- (BOOL)		staticFrame;

- (void)		setString:(NSAttributedString *)attributedString;
- (void)		setString:(NSString *)aString withAttributes:(NSDictionary *)attribs;
- (NSString *)	string;

- (BOOL)		requiresUpdate;

@end
