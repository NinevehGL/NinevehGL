/*
 *	NGLTimer.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 7/1/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import <QuartzCore/QuartzCore.h>

#import "NGLRuntime.h"
#import "NGLCoreTimer.h"
#import "NGLMath.h"
#import "NGLArray.h"

/*!
 *					Returns the time that the application did stay in background mode. This time will
 *					return to 0 after the first non-background cycle have finished.
 *
 *	@result			A double data type representing the time.
 */
NGL_API double nglBackgroundTime(void);

/*!
 *					<strong>(Internal only)</strong> This is a singleton class. It's the main loop for
 *					all NinevehGL's core. (Singleton)
 *
 *					This class creates a single unique loop running with the interval defined by the
 *					constant NGL_MAX_FPS in #NGLCoreTimer#. The NGL_MAX_FPS represents the number of loop
 *					for each second.
 *
 *					As the NGLTimer is a singleton class, it can't be instantiated, so to call any method
 *					from it you must call the defaultTimer which will return the singleton instance for you.
 *
 *					This class is not responsible for any delay or any filter for each callback. Actually,
 *					the NGLTimer works like a library, holding the items with a retain message and
 *					calling the callback function inside each item through the loop cycles. The items must
 *					conform to the #NGLCoreTimer# protocol to be added.
 *
 *					The loop will start automatically when the singleton instance is called by the first
 *					time. You can stop and restart the loop.
 */
@interface NGLTimer : NSObject
{
@private
	BOOL					_paused;
	NSTimer					*_dispatch;
	
	NGLArray				*_collection;
}

/*!
 *					Pauses or resumes the timer.
 *
 *					Set this property to YES if you want to pause the animation temporary. Set it to NO
 *					again to resume the timer.
 *
 *					Its default value is NO.
 */
@property (nonatomic, getter = isPaused) BOOL paused;

/*!
 *					Adds an item from the loop cycle.
 *
 *					The items can't be duplicated, NGLTimer automatically will ignore attempts to insert
 *					the same item more than one time.
 *
 *	@param			item
 *					The object to be added, it must conform to #NGLCoreTimer# protocol.
 */
- (void) addItem:(id <NGLCoreTimer>)item;

/*!
 *					Removes an item from the loop cycle.
 *
 *	@param			item
 *					The object to be removed, it must conform to #NGLCoreTimer# protocol.
 */
- (void) removeItem:(id <NGLCoreTimer>)item;

/*!
 *					Removes all items from the loop cycle.
 */
- (void) removeAll;

/*!
 *					Returns the singleton instance of NGLTimer.
 *
 *					This method is the point of access to the NGLTimer singleton instance. All the classes
 *					that work with loop make use of NGLTimer to deal with the cycle.
 *
 *	@result			A singleton NGLTimer instance.
 */
+ (NGLTimer *) defaultTimer;

@end