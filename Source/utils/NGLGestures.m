/*
 *	NGLGestures.m
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

#import "NGLGestures.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Classes
//**************************************************
//	Private Classes
//**************************************************

/*!
 *					<strong>(Internal only)</strong> Tiny class helps to manage the Cocoa Touch gestures.
 */
@interface NGLGesture : NSObject <UIGestureRecognizerDelegate>

- (void) gestureHandler:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation NGLGesture

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	NSLog(@"BEGGINING %@",gestureRecognizer);
	return YES;
}

- (void) gestureHandler:(UIGestureRecognizer *)gestureRecognizer
{
	NSLog(@"HANDLING %@",gestureRecognizer);
}

@end

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

static NSMutableDictionary *_gestures;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NGLGesture * getDefaultGesture(void)
{
	static NGLGesture *_default = nil;
	
	if (_default == nil)
	{
		_default = [[NGLGesture alloc] init];
	}
	
	return _default;
}

static UIView * getMainView(void)
{
	static UIView *_default = nil;
	
	// Uses the first application window as the main view.
	if (_default == nil)
	{
		_default = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	}
	
	return _default;
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

void nglGestureAdd(id <NGLGestureRecognizer> target, UIGestureRecognizer *gesture)
{
	// Avoids invalid targets.
	if (target == nil || gesture == nil)
	{
		return;
	}
	
	NGLArray *gestureTrack;
	Class gestureClass = [gesture class];
	NSString *gestureName = NSStringFromClass(gestureClass);
	UIGestureRecognizer *realGesture;
	
	// Checks if the gesture has a trackable array.
	// If not, creates a new trackable array and a real gesture.
	if (!(gestureTrack = [_gestures objectForKey:gestureName]))
	{
		// Sets the trackable array. Without retain option.
		gestureTrack = [NGLArray array];
		[_gestures setObject:gestureTrack forKey:gestureName];
		
		// Creating the real gesture.
		realGesture = [[gestureClass alloc] initWithTarget:getDefaultGesture()
													action:@selector(gestureHandler:)];
		realGesture.delegate = getDefaultGesture();
		
		[getMainView() addGestureRecognizer:realGesture];
		
		nglRelease(realGesture);
	}
	
	// Registers the target once in the trackable array and adds the gesture once to the target.
	[gestureTrack addPointerOnce:target];
	[[target gestureRecognizers] addPointerOnce:gesture];
}

void nglGestureRemove(id <NGLGestureRecognizer> target, UIGestureRecognizer *gesture)
{
	// Avoids invalid targets.
	if (target == nil || gesture == nil)
	{
		return;
	}
	
	NGLArray *gestureTrack;
	Class gestureClass = [gesture class];
	NSString *gestureName = NSStringFromClass(gestureClass);
	UIGestureRecognizer *realGesture;
	
	// Checks if the gesture has a trackable array.
	// If so, removes the target from the trackable array and the symbolical gesture from target.
	if ((gestureTrack = [_gestures objectForKey:gestureName]))
	{
		[gestureTrack removePointer:target];
		[[target gestureRecognizers] removePointer:gesture];
	}
	
	// If the current trackable array for the gesture in question reaches 0 count
	// then excludes the real gesture from the main view.
	if (gestureTrack != nil && [gestureTrack count] == 0)
	{
		// Finds the real gesture in the gestureRecognizers array.
		NSArray *gestures = [getMainView() gestureRecognizers];
		for (realGesture in gestures)
		{
			if ([realGesture class] == gestureClass)
			{
				break;
			}
		}
		
		[getMainView() removeGestureRecognizer:realGesture];
	}
}

void nglGestureRemoveAll(id <NGLGestureRecognizer> target)
{
	// Avoids invalid targets.
	if (target == nil)
	{
		return;
	}
	
	// Loops through all gestures for the target in question and removes each of them.
	UIGestureRecognizer *gesture;
	NGLArray *array = [target gestureRecognizers];
	nglFor(gesture, array)
	{
		nglGestureRemove(target, gesture);
	}
}

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

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************
