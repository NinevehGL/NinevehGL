/*
 *	NGLDebug.m
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

#import "NGLDebug.h"
#import "NGLTimer.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define DBG_SIZE		45

static NSString *const DBG_MONITOR = @"NinevehGL Stats - %@\n• Polys: %@    • Verts: %@    • FPS: %.1f";

static NSString *const DBG_ALL = @"Entire Application";

static NSString *const DBG_CAMERA = @"Single Camera";

static NSString *const DBG_MESH = @"Single Mesh";

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

// Actions definitions.
typedef enum
{
	NGLDebugActionInit,
	NGLDebugActionAdd,
	NGLDebugActionAnimateIn,
	NGLDebugActionAnimateOut,
	NGLDebugActionUpdate,
} NGLDebugAction;

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLDebug()

// Initiates the debug cycle.
- (void) startDebug;

// Updates the monitor on the screen.
- (void) uptadeMonitor;

// Perform all related action of UIKit on the main thread.
- (void) uikitAction:(NSNumber *)action;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLDebug

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************


#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		// Main Thread.
		[self performSelectorOnMainThread:@selector(uikitAction:)
							   withObject:[NSNumber numberWithInt:NGLDebugActionInit]
							waitUntilDone:NO];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) startDebug
{
	// Starts a new debug cycle.
	[[NGLTimer defaultTimer] addItem:self];
	
	// Main Thread.
	[self performSelectorOnMainThread:@selector(uikitAction:)
						   withObject:[NSNumber numberWithInt:NGLDebugActionAdd]
						waitUntilDone:NO];
}

- (void) uptadeMonitor
{
	NGLMesh *mesh;
	NSString *mode;
	NSArray *array;
	unsigned int triangles = 0;
	unsigned int vertices = 0;
	float frames = nglDefaultFPS / (float)(CFAbsoluteTimeGetCurrent() - _time);
	
	// Resets the time and frames count to the next check.
	_time = CFAbsoluteTimeGetCurrent();
	
	// Animates once the debug area if the NGLDebug already has enough substantial information.
	if (frames > 0 && _uiText.frame.origin.y == -DBG_SIZE)
	{
		// Main Thread.
		[self performSelectorOnMainThread:@selector(uikitAction:)
							   withObject:[NSNumber numberWithInt:NGLDebugActionAnimateIn]
							waitUntilDone:NO];
	}
	
	// Tracks the stats only for the visible meshes in a specific camera.
	if (_camera != nil)
	{
		mode = DBG_CAMERA;
		
		array = [_camera allMeshes];
		
		for (mesh in array)
		{
			if (mesh.visible)
			{
				triangles += mesh.indicesCount / 3;
				vertices += mesh.structuresCount / ((mesh.stride > 0) ? mesh.stride : 1);
			}
		}
	}
	// Tracks the stats only for a single mesh.
	else if (_mesh != nil)
	{
		mode = DBG_MESH;
		
		triangles += _mesh.indicesCount / 3;
		vertices += _mesh.structuresCount / ((_mesh.stride > 0) ? _mesh.stride : 1);
	}
	// Tracks the stats for all visible meshes in the application.
	else
	{
		mode = DBG_ALL;
		
		array = [NGLMesh allMeshes];
		
		for (mesh in array)
		{
			if (mesh.visible)
			{
				triangles += mesh.indicesCount / 3;
				vertices += mesh.structuresCount / ((mesh.stride > 0) ? mesh.stride : 1);
			}
		}
	}
	
	// Converts the numbers to an user friendly notation.
	NSString *tri = [_format stringFromNumber:[NSNumber numberWithInt:triangles]];
	NSString *ver = [_format stringFromNumber:[NSNumber numberWithInt:vertices]];
	
	// Updates the debug text.
	nglRelease(_text);
	_text = [[NSString alloc] initWithFormat:DBG_MONITOR, mode, tri, ver, frames];
	
	// Main Thread.
	[self performSelectorOnMainThread:@selector(uikitAction:)
						   withObject:[NSNumber numberWithInt:NGLDebugActionUpdate]
						waitUntilDone:NO];
}

- (void) uikitAction:(NSNumber *)action
{
	NGLDebugAction act = [action intValue];
	CGRect frame;
	float posY;
	
	switch (act)
	{
		case NGLDebugActionInit:
			// Defines the number formats.
			_format = [[NSNumberFormatter alloc] init];
			[_format setNumberStyle:NSNumberFormatterDecimalStyle];
			
			// Sets the layout to NGL Debug area.
			_uiText = [[UITextView alloc] init];
			[_uiText setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
			[_uiText setFont:[UIFont fontWithName:@"Verdana" size:10]];
			[_uiText setTextColor:[UIColor yellowColor]];
			[_uiText setFrame:CGRectMake(0, -DBG_SIZE, _view.bounds.size.width, DBG_SIZE)];
			[_uiText setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
			[_uiText setScrollEnabled:NO];
			[_uiText setEditable:NO];
			
			break;
		case NGLDebugActionAdd:
			// Adds the debug area only if it is not already placed there.
			if ([_uiText superview] != _view)
			{
				[_uiText removeFromSuperview];
				[_view addSubview:_uiText];
			}
			
			break;
		case NGLDebugActionAnimateIn:
		case NGLDebugActionAnimateOut:
			posY = (act == NGLDebugActionAnimateIn) ? 0 : -DBG_SIZE;
			frame = _uiText.frame;
			
			// Starts an animation using the UIView shortcuts and set its properties.
			[UIView beginAnimations:@"StatsMonitor" context:nil];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.75f];
			
			// Makes the changes for the debug area.
			[_uiText setFrame:CGRectMake(frame.origin.x, posY, frame.size.width, frame.size.height)];
			
			// Commits the animations above.
			[UIView commitAnimations];
			
			break;
		case NGLDebugActionUpdate:
			_uiText.text = _text;
			nglRelease(_text);
			
			break;
			
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) startWithView:(NGLView *)view
{
	// Setting targets.
	_view = view;
	_mesh = nil;
	_camera = nil;
	
	[self startDebug];
}

- (void) startWithView:(NGLView *)view mesh:(NGLMesh *)mesh
{
	// Setting targets.
	_view = view;
	_mesh = mesh;
	_camera = nil;
	
	[self startDebug];
}

- (void) startWithView:(NGLView *)view camera:(NGLCamera *)camera
{
	// Setting targets.
	_view = view;
	_mesh = nil;
	_camera = camera;
	
	[self startDebug];
}

- (void) stopDebug
{
	// Remove the debug from NGL Time Cycle.
	[[NGLTimer defaultTimer] removeItem:self];
	
	// Main Thread.
	[self performSelectorOnMainThread:@selector(uikitAction:)
						   withObject:[NSNumber numberWithInt:NGLDebugActionAnimateOut]
						waitUntilDone:NO];
}

- (void) timerCallBack
{
	_fps++;
	
	// Checks how many time passed by between a complete render cycle (1 second).
	if (_fps == nglDefaultFPS)
	{
		[self uptadeMonitor];
		
		_fps = 0;
	}
}

+ (NGLDebug *) debugMonitor
{
	// Persistent instance.
	static NGLDebug *_default = nil;
	
	// Allocates once with Grand Central Dispatch (GCD) routine. Thread safe.
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
	{
		_default = [[NGLDebug alloc] init];
	});
	
	return _default;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
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
	[_uiText removeFromSuperview];
	nglRelease(_uiText);
	nglRelease(_format);
	
	[super dealloc];
}

@end
