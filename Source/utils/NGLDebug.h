/*
 *	Copyright (c) 2011-2015 NinevehGL. More information at: http://nineveh.gl
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

#import "NGLRuntime.h"
#import "NGLCoreTimer.h"
#import "NGLCamera.h"
#import "NGLView.h"
#import "NGLMesh.h"

/*!
 *					Monitor to measure the performance of NinevehGL. (Singleton)
 *
 *					The NGLDebug includes many kinds of monitors and information. To all monitors you
 *					can set it to measure: the entire application, a specific camera or a single mesh.
 *
 *					NGLDebug is a singleton class and you shouldn't create a new instance of it. Instead,
 *					call the static method <code>#debugMonitor#</code> to have access to it. Then, you
 *					must call one of the <code>#startWithView:#</code> methods informing a #NGLView#.
 *					The monitor will appear in the top of the informed #NGLView# automatically.
 *
 *					To stop the monitor at any time, just call <code>#stopDebug#</code> method.
 *
 *	@see			startWithView:
 *	@see			startWithView:mesh:
 *	@see			startWithView:camera:
 *	@see			stopDebug
 *	@see			debugMonitor
 *	@see			NGLView
 */
@interface NGLDebug : NSObject <NGLCoreTimer>
{
@private
	// Targets
	NGLView					*_view;
	NGLMesh					*_mesh;
	NGLCamera				*_camera;
	
	// Timers
	unsigned short			_fps;
	NSTimeInterval			_time;
	
	// UIKit
	NSString				*_text;
	UITextView				*_uiText;
	NSNumberFormatter		*_format;
}

/*!
 *					Starts the NGLDebug to the entire application.
 *
 *					This method takes the view you want to see the monitor. The tracking data don't need
 *					necessarily be related with the informed #NGLView#. The view is just a visual reference
 *					to place the monitor.
 *
 *	@param			view
 *					The #NGLView# you want to see the monitor comes up.
 *
 *	@see			NGLView
 */
- (void) startWithView:(NGLView *)view;

/*!
 *					Starts the NGLDebug to the entire application.
 *
 *					This method takes the view you want to see the monitor. The tracking data don't need
 *					necessarily be related with the informed #NGLView#. The view is just a visual reference
 *					to place the monitor. Besides, this methods locks the monitor's focus on some specific
 *					mesh, reading the data only from that mesh.
 *
 *	@param			view
 *					The #NGLView# you want to see the monitor comes up.
 *
 *	@param			mesh
 *					The #NGLMesh# which the monitor will have focus on.
 *
 *	@see			NGLView
 *	@see			NGLMesh
 */
- (void) startWithView:(NGLView *)view mesh:(NGLMesh *)mesh;

/*!
 *					Starts the NGLDebug to the entire application.
 *
 *					This method takes the view you want to see the monitor. The tracking data doesn't need
 *					necessarily be related with the informed #NGLView#. The view is just a visual reference
 *					to place the monitor. Besides, this methods locks the monitor's focus on some specific
 *					camera, reading the data from the meshes linked with that camera.
 *
 *	@param			view
 *					The #NGLView# you want to see the monitor comes up.
 *
 *	@param			camera
 *					The #NGLCamera# which the monitor will have focus on.
 *
 *	@see			NGLView
 *	@see			NGLCamera
 */
- (void) startWithView:(NGLView *)view camera:(NGLCamera *)camera;

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