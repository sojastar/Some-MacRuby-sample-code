//
//  GLString.m
//  MacRuby Cocoa OpenGL
//

#import "GLString.h"



// Added for MacRuby
void Init_ObjectiveCGLString(void) { }





@implementation NSBezierPath (RoundRect)



+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius {

    NSBezierPath *result = [NSBezierPath bezierPath];

    [result appendBezierPathWithRoundedRect:rect cornerRadius:radius];

    return result;

}






- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius {
 
	if (!NSIsEmptyRect(rect)) {

		if (radius > 0.0) {

			// Clamp radius to be no larger than half the rect's width or height.
			float clampedRadius	= MIN(radius, 0.5 * MIN(rect.size.width, rect.size.height));
			
			NSPoint topLeft		= NSMakePoint(NSMinX(rect), NSMaxY(rect));
			NSPoint topRight	= NSMakePoint(NSMaxX(rect), NSMaxY(rect));
			NSPoint bottomRight	= NSMakePoint(NSMaxX(rect), NSMinY(rect));
			
			[self moveToPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect))];
			[self appendBezierPathWithArcFromPoint:topLeft     toPoint:rect.origin radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:rect.origin toPoint:bottomRight radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:bottomRight toPoint:topRight    radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:topRight    toPoint:topLeft     radius:clampedRadius];
			[self closePath];

		} else {
			
			// When radius == 0.0, this degenerates to the simple case of a plain rectangle.
			[self appendBezierPathWithRect:rect];

		}

    }

}

@end





@implementation GLString

+ (void) caca
{
	printf("caca");
}

// The complete initializer :
- (id) initWithAttributedString:(NSAttributedString *)attributedString withTextColor:(NSColor *)text withBoxColor:(NSColor *)box withBorderColor:(NSColor *)border
{

	cgl_context		= NULL;

	textureName		= 0;
	textureSize		= NSMakeSize(0.0f, 0.0f);

	string			= attributedString;

	textColor		= text;
	boxColor		= box;
	borderColor		= border;

	staticFrame		= NO;
	antialias		= YES;

	marginSize		= NSMakeSize(4.0f, 2.0f);
	cornerRadius	= 4.0f;

	requiresUpdate = YES;

	return self;

}





// Generate the texture without drawing texture to current context :
- (void) generateTexture
{

	NSImage * image;
	NSBitmapImageRep * bitmap;


	NSSize previousSize = textureSize;


	// Find the frame size if we have not already found it :
	if ((staticFrame == NO) && (frameSize.width == 0.0f) && (frameSize.height == 0.0f)) {
		frameSize = [string size];							// current string size
		frameSize.width		+= marginSize.width  * 2.0f;	// add padding
		frameSize.height	+= marginSize.height * 2.0f;
	}


	// Creating the NSImage that will be used to make the texture :
	image = [[NSImage alloc] initWithSize:frameSize];	
	[image lockFocus];


	// Getting the current graphic context :
	[[NSGraphicsContext currentContext] setShouldAntialias:antialias];
	

	// Actually drawing in the NSImage :
	NSRect frameRectangle	= NSMakeRect (0.0f, 0.0f, frameSize.width, frameSize.height);
	if ([boxColor alphaComponent]) {		// this should be == 0.0f but need to make sure
		[boxColor set];
		NSRect boxRectangle		= NSInsetRect(frameRectangle, 0.5, 0.5);
		NSBezierPath *path		= [NSBezierPath bezierPathWithRoundedRect:boxRectangle cornerRadius:cornerRadius];
		[path fill];
	}

	if ([borderColor alphaComponent]) {
		[borderColor set];
		NSRect borderRectangle	= NSInsetRect(frameRectangle, 0.5, 0.5);
		NSBezierPath *path		= [NSBezierPath bezierPathWithRoundedRect:borderRectangle cornerRadius:cornerRadius];
		[path setLineWidth:1.0f];
		[path stroke];
	}
//NSLog(@"%f, %f, %f, %f\n", [textColor redComponent], [textColor greenComponent], [textColor blueComponent], [textColor alphaComponent]);
	textColor	= [NSColor whiteColor];
	[textColor set];
	[string drawAtPoint:NSMakePoint(marginSize.width, marginSize.height)]; // draw at offset position

	
	// Transorming the NSImage in a NSBitmapImageRep that can feed our OpenGL texture with its raw data :
	bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:frameRectangle];
	textureSize.width		= [bitmap pixelsWide];
	textureSize.height		= [bitmap pixelsHigh];

	
	[image unlockFocus];


	// Finaly, generating the texture from the NSBitmapImageRep.
	// This is the part I couldn't translate to Ruby, because :
	//	- [bitmap bitmapData] returns an (unsigned char *)
	//	- bitmap.bitmapData returns "" (empty string)
	if ( cgl_context = CGLGetCurrentContext() ) { // if we successfully retrieve a current context (required)

		glPushAttrib(GL_TEXTURE_BIT);

		if (textureName == 0)
			glGenTextures(1, &textureName);

		glBindTexture (GL_TEXTURE_RECTANGLE_EXT, textureName);

		if (NSEqualSizes(previousSize, textureSize)) {
			glTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT,
							0,0,0,textureSize.width,
							textureSize.height,
							[bitmap hasAlpha] ? GL_RGBA : GL_RGB,
							GL_UNSIGNED_BYTE,
							[bitmap bitmapData]);
		} else {
			glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexImage2D(GL_TEXTURE_RECTANGLE_EXT,
						 0,
						 GL_RGBA,
						 textureSize.width, textureSize.height,
						 0,
						 [bitmap hasAlpha] ? GL_RGBA : GL_RGB,
						 GL_UNSIGNED_BYTE,
						 [bitmap bitmapData]);
		}

		glPopAttrib();

	} else
		NSLog (@"StringTexture -genTexture: Failure to get current OpenGL context\n");

	requiresUpdate = NO;

}





- (void) drawWithBounds:(NSRect)bounds
{

	if (requiresUpdate)
		[self generateTexture];

	if (textureName) {

		glPushAttrib(GL_ENABLE_BIT | GL_TEXTURE_BIT | GL_COLOR_BUFFER_BIT); // GL_COLOR_BUFFER_BIT for glBlendFunc, GL_ENABLE_BIT for glEnable / glDisable

		glDisable(GL_DEPTH_TEST);						// ensure text is not remove by depth buffer test.
		glEnable(GL_BLEND);								// for text fading
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);	// ditto
		glEnable(GL_TEXTURE_RECTANGLE_EXT);
		
		glBindTexture(GL_TEXTURE_RECTANGLE_EXT, textureName);
		glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);								// draw upper left in world coordinates
		glVertex2f(bounds.origin.x, bounds.origin.y);
		
		glTexCoord2f(0.0f, textureSize.height);					// draw lower left in world coordinates
		glVertex2f(bounds.origin.x, bounds.origin.y + bounds.size.height);

		glTexCoord2f(textureSize.width, textureSize.height);	// draw upper right in world coordinates
		glVertex2f(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);

		glTexCoord2f(textureSize.width, 0.0f);					// draw lower right in world coordinates
		glVertex2f(bounds.origin.x + bounds.size.width, bounds.origin.y);
		glEnd();

		glPopAttrib();

	}

}





// Accessors :

- (GLuint) textureName
{
	return textureName;
}





- (void) setTextureSize:(NSSize)size {
	textureSize	= size;
}

- (NSSize) textureSize
{
	return textureSize;
}





- (void) setTextColor:(NSColor *)color // set default text color
{
	textColor		= color;
	requiresUpdate	= YES;
}

- (NSColor *) textColor
{
	return textColor;
}





- (void) setBoxColor:(NSColor *)color // set default text color
{
	boxColor		= color;
	requiresUpdate	= YES;
}

- (NSColor *) boxColor
{
	return boxColor;
}





- (void) setBorderColor:(NSColor *)color // set default text color
{
	borderColor		= color;
	requiresUpdate	= YES;
}

- (NSColor *) borderColor
{
	return borderColor;
}





- (void) setMarginSize:(NSSize)size // set offset size and size to fit with offset
{

	marginSize = size;

	if (staticFrame == NO)		// ensure dynamic frame sizes will be recalculated
		frameSize	= NSMakeSize(0.0f, 0.0f);

	requiresUpdate = YES;

}

- (NSSize) marginSize
{
	return marginSize;
}





- (void) setAntialias:(bool)request
{
	antialias = request;
	requiresUpdate = YES;
}

- (BOOL) antialias
{
	return antialias;
}





- (NSSize) frameSize
{

	if ((staticFrame == NO) && NSEqualSizes(frameSize, NSMakeSize(0.0f, 0.0f))) { // find frame size if we have not already found it
		frameSize = [string size];							// current string size
		frameSize.width		+= marginSize.width * 2.0f;		// add padding
		frameSize.height	+= marginSize.height * 2.0f;
	}

	return frameSize;

}





- (void) useStaticFrame:(NSSize)size	// set static frame size and size to frame
{
	frameSize = size;
	staticFrame = YES;
	requiresUpdate = YES;
}

- (void) useDynamicFrame
{
	if (staticFrame == YES) {			// set to dynamic frame and set to regen texture
		staticFrame		= NO;
		frameSize		= NSMakeSize(0.0f, 0.0f);	// ensure frame sizes will be recalculated
		requiresUpdate	= YES;
	}
}

- (BOOL) staticFrame
{
	return staticFrame;
}





- (void) setString:(NSAttributedString *)attributedString // set string after initial creation
{

	string = attributedString;

	if (staticFrame == NO)		// ensure dynamic frame sizes will be recalculated
		frameSize	= NSMakeSize(0.0f, 0.0f);

	requiresUpdate = YES;

}

- (void) setString:(NSString *)aString withAttributes:(NSDictionary *)attribs // set string after initial creation
{
	[self setString:[[[NSAttributedString alloc] initWithString:aString attributes:attribs] autorelease]];
}

- (NSString *) string
{
	return(string.string);		// uggly !!!
}





- (BOOL) requiresUpdate
{
	return requiresUpdate;
}


@end
