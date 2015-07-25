/*
 *	NGLTimer.m
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

#import <objc/message.h>

#import "NGLTimer.h"
#import "NGLThread.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//  Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//  Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

// The background time.
static double _backgroundTime;

// The call back selector. Defined once to optimize the render cycle.
static SEL _selCallBack;

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLTimer()

// Setup the timer.
- (void) setupTimer;

// The timer cycle.
- (void) timerCycle:(NSTimer *)timer;

// Pause notifications.
- (void) pauseTimer:(NSNotification *)notification;

// Resume notifications.
- (void) resumeTimer:(NSNotification *)notification;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//  Public Interface
//
//**********************************************************************************************************

// Returns the last background time.
double nglBackgroundTime(void)
{
	return _backgroundTime;
}

@implementation NGLTimer

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic paused;

- (BOOL) isPaused { return _paused; }
- (void) setPaused:(BOOL)value
{
	_paused = value;
	
	// Start the timer. Must be synchronous to mantain the integrity when changing background states.
	nglThreadPerformSync(kNGLThreadRender, @selector(setupTimer), self);
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		// Initialization code here.
		_collection = [[NGLArray alloc] init];
		_backgroundTime = 0.0;
		_selCallBack = @selector(timerCallBack);
		
		// Defines the notifications for the application state changes.
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center removeObserver:self];
		
		[center addObserver:self
				   selector:@selector(pauseTimer:)
					   name:UIApplicationWillResignActiveNotification
					 object:nil];
		
		[center addObserver:self
				   selector:@selector(resumeTimer:)
					   name:UIApplicationDidBecomeActiveNotification
					 object:nil];
		
		[center addObserver:self
				   selector:@selector(pauseTimer:)
					   name:UIApplicationWillTerminateNotification
					 object:nil];
		
		// Starts the loop.
		self.paused = NO;
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//  Private Methods
//**************************************************

- (void) setupTimer
{
	// Clear the old timer.
	[_dispatch invalidate];
	_dispatch = nil;
	
	// Starting over the timer.
	if (!_paused)
	{
		// Uses NSTimer instead the new CADisplayLink because that new class doesn't support
		// all kind of frame rates as 31, 29, 24 and others.
		_dispatch = [NSTimer scheduledTimerWithTimeInterval:1.0 / (float)nglDefaultFPS
													 target:self
												   selector:@selector(timerCycle:)
												   userInfo:nil
													repeats:YES];
	}
}

- (void) timerCycle:(NSTimer *)timer
{
	/*
	//[_collection makeAllPointersPerformSelector:_selCallBack];
	/*/
	id item;
	nglFor (item, _collection)
	{
		nglMsg(item, _selCallBack);
	}
	//*/
	_backgroundTime = 0.0;
}

- (void) pauseTimer:(NSNotification *)notification
{
	self.paused = YES;
	_backgroundTime = CFAbsoluteTimeGetCurrent();
}

- (void) resumeTimer:(NSNotification *)notification
{
	if (_backgroundTime > 0.0)
	{
		self.paused = NO;
		_backgroundTime = CFAbsoluteTimeGetCurrent() - _backgroundTime;
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//  Self Public Methods
//**************************************************

- (void) addItem:(id <NGLCoreTimer>)item
{
	[_collection addPointerOnce:item];
}

- (void) removeItem:(id <NGLCoreTimer>)item
{
	[_collection removePointer:item];
}

- (void) removeAll
{
	[_collection removeAll];
}

+ (NGLTimer *) defaultTimer
{
	// Persistent instance.
	static NGLTimer *_default = nil;
	
	// Allocates once with Grand Central Dispatch (GCD) routine. Thread safe.
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
	{
		_default = [[NGLTimer alloc] init];
	});
	
	return _default;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//  Override Public Methods
//**************************************************

- (id) retain
{
	return self;
}

- (oneway void) release
{
	// Does nothing here.
}

- (id) autorelease
{
	return self;
}

- (NSUInteger) retainCount
{
    return NGL_MAX_32;
}

- (void) dealloc
{
	// Stops the timer.
	self.paused = YES;
	
	// Removes the notifications.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// Frees the memory.
	nglRelease(_collection);
	
	[super dealloc];
}

@end
