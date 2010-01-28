//
//  MyOpenGLView.m
//  MacRuby-CoreImageGLTextureFBO
//
//  Created by Julien Jassaud on 19/01/10.
//  Copyright 2010 IAMAS. All rights reserved.
//

#import "MyOpenGLView.h"





// Added for MacRuby
void Init_Texturing(void) { }





@implementation MyOpenGLView

// Create CIContext based on OpenGL context and pixel format
- (BOOL)createCIContext
{

	CIContext	*myCIcontext;


	// Create CIContext from the OpenGL context.
	//myCIcontext = [CIContext contextWithCGLContext:[[self openGLContext] CGLContextObj] 
	//								   pixelFormat:[[self pixelFormat] CGLPixelFormatObj]
	//									   options: nil];
	myCIcontext = [CIContext contextWithCGContext:[[self openGLContext] CGLContextObj] options: nil];

	if (!myCIcontext)
	{ 
		NSLog(@"CIContext creation failed");
		return NO;
	}
	
	
	// Created succesfully
	return YES;

}

@end
