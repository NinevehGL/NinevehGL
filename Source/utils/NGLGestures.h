/*
 *	NGLGestures.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 4/15/12.
 *	Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLArray.h"

@protocol NGLGestureRecognizer <NSObject>

@property(nonatomic, readonly) NGLArray *gestureRecognizers;

- (void) addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void) removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void) removeAllGestureRecognizers;

@end

NGL_API void nglGestureAdd(id <NGLGestureRecognizer> target, UIGestureRecognizer *gesture);
NGL_API void nglGestureRemove(id <NGLGestureRecognizer> target, UIGestureRecognizer *gesture);
NGL_API void nglGestureRemoveAll(id <NGLGestureRecognizer> target);