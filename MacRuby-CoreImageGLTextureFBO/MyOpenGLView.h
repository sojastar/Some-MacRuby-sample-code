//
//  MyOpenGLView.h
//  MacRuby-CoreImageGLTextureFBO
//
//  Created by Julien Jassaud on 19/01/10.
//  Copyright 2010 IAMAS. All rights reserved.
//

#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <CIContext.h>


@interface MyOpenGLView : NSOpenGLView {

}

- (BOOL)createCIContext;

@end
