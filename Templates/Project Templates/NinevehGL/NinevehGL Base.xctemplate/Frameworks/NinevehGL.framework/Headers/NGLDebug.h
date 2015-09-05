/*
 *	NGLDebug.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 3/23/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLCamera.h"
#import "NGLMesh.h"

/*!
 *					Monitor to measure the performance of NinevehGL. (Singleton)
 *
 *					The NGLDebug includes many kinds of monitors and information. To all monitors you
 *					can set it to measure: the entire application, a specific camera or a single mesh.
 *
 *					NGLDebug is a singleton class and you shouldn't create a new instance of it. Instead,
 *					call the static method <code>#debugMonitor#</code> to have access to it. Then, you
 *					must call one of the <code>#startWithView:#</code> methods informing a UIView.
 *					The monitor will appear in the top of the informed UIView automatically.
 *
 *					To stop the monitor at any time, just call <code>#stopDebug#</code> method.
 *
 *	@see			startWithView:
 *	@see			startWithView:mesh:
 *	@see			startWithView:camera:
 *	@see			stopDebug
 *	@see			debugMonitor
 */
@interface NGLDebug : NSObject
{
@private
	// Targets.
	UIView					*_view;
	NGLMesh					*_mesh;
	NGLCamera				*_camera;
	
	// Timers.
	unsigned short			_frames;
	NSTimeInterval			_time;
	
	// Helpers.
	unsigned int			_polygons;
	unsigned int			_vertices;
	float					_fps;
	
	// UIKit.
	NSMutableString			*_text;
	UITextView				*_textView;
	NSNumberFormatter		*_format;
}

/*!
 *					Indicates if the debug monitor will be hidden or not. You can hide the debug monitor
 *					from the view if you're planning to use the debug values only, instead of showing them
 *					into the screen.
 */
@property (nonatomic, getter = isHidden) BOOL hidden;

/*!
 *					The debug polygons count. This value is updated every second.
 */
@property (nonatomic, readonly) unsigned int polygons;

/*!
 *					The debug vertices count. This value is updated every second.
 */
@property (nonatomic, readonly) unsigned int vertices;

/*!
 *					The debug frames per second. This value is updated every second.
 */
@property (nonatomic, readonly) float fps;

/*!
 *					Starts the NGLDebug to the entire application.
 *
 *					This method takes the view you want to see the monitor. The tracking data don't need
 *					necessarily be related with the informed UIView. The view is just a visual reference
 *					to place the monitor.
 *
 *	@param			view
 *					The UIView you want to see the monitor comes up.
 */
- (void) startWithView:(UIView *)view;

/*!
 *					Starts the NGLDebug to the entire application.
 *
 *					This method takes the view you want to see the monitor. The tracking data don't need
 *					necessarily be related with the informed UIView. The view is just a visual reference
 *					to place the monitor. Besides, this methods locks the monitor's focus on some specific
 *					mesh, reading the data only from that mesh.
 *
 *	@param			view
 *					The UIView you want to see the monitor comes up.
 *
 *	@param			mesh
 *					The #NGLMesh# which the monitor will have focus on.
 *
 *	@see			NGLMesh
 */
- (void) startWithView:(UIView *)view mesh:(NGLMesh *)mesh;

/*!
 *					Starts the NGLDebug to the entire application.
 *
 *					This method takes the view you want to see the monitor. The tracking data doesn't need
 *					necessarily be related with the informed UIView. The view is just a visual reference
 *					to place the monitor. Besides, this methods locks the monitor's focus on some specific
 *					camera, reading the data from the meshes linked with that camera.
 *
 *	@param			view
 *					The UIView you want to see the monitor comes up.
 *
 *	@param			camera
 *					The #NGLCamera# which the monitor will have focus on.
 *
 *	@see			UIView
 *	@see			NGLCamera
 */
- (void) startWithView:(UIView *)view camera:(NGLCamera *)camera;

/*!
 *					Stops the debug monitor.
 *
 *					Immediately stops the current monitor. The monitor will automatically exit the screen.
 */
- (void) stopDebug;

/*!
 *					Returns the singleton instance of NGLDebug.
 *
 *					NGLDebug works with one single core but with multiple outputs, which means you can
 *					have two or more monitors running on the screen at the same time.
 *
 *	@result			A singleton NGLDebug instance.
 */
+ (NGLDebug *) debugMonitor;

@end