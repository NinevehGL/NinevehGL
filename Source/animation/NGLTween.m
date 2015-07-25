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

#import "NGLTween.h"
#import "NGLTimer.h"
#import "NGLArray.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//  Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Errors
//**************************************************
//	Errors
//**************************************************

static NSString *const TWE_ERROR_HEADER = @"Error while processing NGLParserOBJ with file \"%@\".";

static NSString *const TWE_ERROR_DATA_TYPE = @"The values to tween must be a NSString or a NSNumber.\n\
You are passing the argument:%@, which is not a NSString nor a NSNumber.";

#pragma mark -
#pragma mark Keys
//**************************************************
//	Keys
//**************************************************

NSString *const kNGLTweenKeyName = @"nglTweenKeyName";
NSString *const kNGLTweenKeyEase = @"nglTweenKeyEase";
NSString *const kNGLTweenKeyDelay = @"nglTweenKeyDelay";
NSString *const kNGLTweenKeyStart = @"nglTweenKeyStart";
NSString *const kNGLTweenKeyReverse = @"nglTweenKeyReverse";
NSString *const kNGLTweenKeyRepeat = @"nglTweenKeyRepeat";
NSString *const kNGLTweenKeyRepeatCount = @"nglTweenKeyCountRepeat";
NSString *const kNGLTweenKeyRepeatDelay = @"nglTweenKeyDelayRepeat";
NSString *const kNGLTweenKeyOverride = @"nglTweenKeyOverride";
NSString *const kNGLTweenKeyRetainTarget = @"nglTweenKeyRetainTarget";

NSString *const kNGLTweenStartPaused = @"nglTweenStartPaused";
NSString *const kNGLTweenStartImmediately = @"nglTweenStartImmediately";

NSString *const kNGLTweenReverseYes = @"nglTweenReverseYes";

NSString *const kNGLTweenRepeatLoop = @"nglTweenRepeatLoop";
NSString *const kNGLTweenRepeatMirror = @"nglTweenRepeatMirror";
NSString *const kNGLTweenRepeatMirrorEase = @"nglTweenRepeatMirrorEase";

NSString *const kNGLTweenOverrideCurrent = @"nglTweenOverrideCurrent";
NSString *const kNGLTweenOverrideFinished = @"nglTweenOverrideFinished";

NSString *const kNGLTweenRetainTargetYes = @"nglTweenRetainTargetYes";

NSString *const kNGLEaseLinear = @"nglEaseLinear";
NSString *const kNGLEaseSmoothOut = @"nglEaseSmoothOut";
NSString *const kNGLEaseSmoothIn = @"nglEaseSmoothIn";
NSString *const kNGLEaseSmoothInOut = @"nglEaseSmoothInOut";
NSString *const kNGLEaseStrongOut = @"nglEaseStrongOut";
NSString *const kNGLEaseStrongIn = @"nglEaseStrongIn";
NSString *const kNGLEaseStrongInOut = @"nglEaseStrongInOut";
NSString *const kNGLEaseElasticOut = @"nglEaseElasticOut";
NSString *const kNGLEaseElasticIn = @"nglEaseElasticIn";
NSString *const kNGLEaseElasticInOut = @"nglEaseElasticInOut";
NSString *const kNGLEaseBounceOut = @"nglEaseBounceOut";
NSString *const kNGLEaseBounceIn = @"nglEaseBounceIn";
NSString *const kNGLEaseBounceInOut = @"nglEaseBounceInOut";
NSString *const kNGLEaseBackOut = @"nglEaseBackOut";
NSString *const kNGLEaseBackIn = @"nglEaseBackIn";
NSString *const kNGLEaseBackInOut = @"nglEaseBackInOut";

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

// Binary delegate check.
typedef enum
{
	NGLTweenNone		= 0x00,
	NGLTweenWillStart	= 0x01,
	NGLTweenDidStart	= 0x02,
	NGLTweenWillRepeat	= 0x04,
	NGLTweenDidRepeat	= 0x08,
	NGLTweenWillFinish	= 0x10,
	NGLTweenDidFinish	= 0x20,
} NGLTweenInspector;

// Necessary to make strong references to the tweens.
static NGLArray *_tweens = nil;

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLTween()

// Sets the tween data for a collection.
- (void) setTweenData:(NSDictionary *)data forColletion:(NSMutableDictionary *)collection;

// Starts the tween.
- (void) startTween:(id)target duration:(float)seconds from:(NSDictionary *)from to:(NSDictionary *)to;

// Resets the timer variables.
- (void) resetTime;

// Defines the tween settings.
- (void) defineTweenSettings;

// Ends a cycke.
- (void) finishCycle;

// Sets the initial and final values.
- (void) setValuesAndRevert:(BOOL)revertValues revertEase:(BOOL)revertEase;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//  Public Interface
//
//**********************************************************************************************************

@implementation NGLTween

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize name = _name, target = _target;

@dynamic paused, delegate;

- (BOOL) paused { return _paused; }
- (void) setPaused:(BOOL)value
{
	// Avoids redundant calls.
	if (_paused == value)
	{
		return;
	}
	
	// Defines the last unpaused time.
	if (_lastTime == 0.0 || value)
	{
		_lastTime = CFAbsoluteTimeGetCurrent();
	}
	
	// Increments the idle time.
	if (!value)
	{
		_idleTime += CFAbsoluteTimeGetCurrent() - _lastTime;
	}
	
	_paused = value;
}

- (id <NGLTweenDelegate>) delegate { return _delegate; }
- (void) setDelegate:(id <NGLTweenDelegate>)value
{
	_delegate = value;
	
	// Using a single binary logic, generates an unique inspector number corresponding to
	// all the methods implemented by the delegate target.
	if (_delegate == nil)
	{
		_inspector = NGLTweenNone;
		return;
	}
	
	if ([_delegate respondsToSelector:@selector(tweenWillStart:)])
	{
		_inspector |= NGLTweenWillStart;
	}
	
	if ([_delegate respondsToSelector:@selector(tweenDidStart:)])
	{
		_inspector |= NGLTweenDidStart;
	}
	
	if ([_delegate respondsToSelector:@selector(tweenWillRepeat:)])
	{
		_inspector |= NGLTweenWillRepeat;
	}
	
	if ([_delegate respondsToSelector:@selector(tweenDidRepeat:)])
	{
		_inspector |= NGLTweenDidRepeat;
	}
	
	if ([_delegate respondsToSelector:@selector(tweenWillFinish:)])
	{
		_inspector |= NGLTweenWillFinish;
	}
	
	if ([_delegate respondsToSelector:@selector(tweenDidFinish:)])
	{
		_inspector |= NGLTweenDidFinish;
	}
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

+ (id) tweenTo:(NSDictionary *)to duration:(float)seconds target:(id)target
{
	NGLTween *tween = [[NGLTween alloc] init];
	
	[tween startTween:target duration:seconds from:nil to:to];
	
	return [tween autorelease];
}

+ (id) tweenFrom:(NSDictionary *)from duration:(float)seconds target:(id)target
{
	NGLTween *tween = [[NGLTween alloc] init];
	
	[tween startTween:target duration:seconds from:from to:nil];
	
	return [tween autorelease];
}

+ (id) tweenFrom:(NSDictionary *)from to:(NSDictionary *)to duration:(float)seconds target:(id)target
{
	NGLTween *tween = [[NGLTween alloc] init];
	
	[tween startTween:target duration:seconds from:from to:to];
	
	return [tween autorelease];
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//  Private Methods
//**************************************************

- (void) setTweenData:(NSDictionary *)data forColletion:(NSMutableDictionary *)collection
{
	// Copying values.
	id object;
	NSString *key;
	Class cString = [NSString class], cNumber = [NSNumber class];
	
	// Places each key in the correspondent collection.
	for (key in data)
	{
		object = [[data objectForKey:key] copy];
		
		if ([_target respondsToSelector:NSSelectorFromString(key)])
		{
			// Warning about invalid values (only NSString or NSNumber are allowed).
			if (![object isKindOfClass:cString] && ![object isKindOfClass:cNumber])
			{
				[NGLError errorInstantlyWithHeader:TWE_ERROR_HEADER
										andMessage:[NSString stringWithFormat:TWE_ERROR_DATA_TYPE, object]];
			}
			
			[collection setObject:object forKey:key];
			[_allKeys addObject:key];
		}
		else
		{
			[_settings setObject:object forKey:key];
		}
		
		nglRelease(object);
	}
}

- (void) startTween:(id)target duration:(float)seconds from:(NSDictionary *)from to:(NSDictionary *)to
{
	// Settings.
	_target = target;
	_targetClass = [target class];
	_duration = seconds;
	_settings = [[NSMutableDictionary alloc] init];
	_toValues = [[NSMutableDictionary alloc] init];
	_fromValues = [[NSMutableDictionary alloc] init];
	_allKeys = [[NSMutableArray alloc] init];
	_currentCycle = 0;
	_ready = NO;
	
	// Separating the tween settings and values from the inputs.
	[self setTweenData:from forColletion:_fromValues];
	[self setTweenData:to forColletion:_toValues];
	
	// Processing the tween settings.
	[self defineTweenSettings];
	
	// Allocates once.
	if (_tweens == nil)
	{
		_tweens = [[NGLArray alloc] initWithRetainOption];
	}
	
	// Adding the tween.
	[[NGLTimer defaultTimer] addItem:self];
	[_tweens addPointer:self];
}

- (void) resetTime
{
	_beginTime = 0.0;
	_currentTime = 0.0;
	_idleTime = CFAbsoluteTimeGetCurrent();
}

- (void) defineTweenSettings
{
	id value;
	
	[self resetTime];
	
	//*************************
	//	Name
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyName];
	
	nglRelease(_name);
	_name = (value) ? [value copy] : nil;
	
	//*************************
	//	Ease
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyEase];
	
	// Default value.
	if (value == nil)
	{
		_ease = &nglEaseSmoothOut;
	}
	// Custom ease algorithm.
	else if ([value isKindOfClass:[NSValue class]])
	{
		[value getValue:&_ease];
	}
	// Pre-defined algorithms.
	else if ([value isKindOfClass:[NSString class]])
	{
		if ([value isEqualToString:kNGLEaseLinear])
		{
			_ease = &nglEaseLinear;
		}
		else if ([value isEqualToString:kNGLEaseSmoothOut])
		{
			_ease = &nglEaseSmoothOut;
		}
		else if ([value isEqualToString:kNGLEaseSmoothIn])
		{
			_ease = &nglEaseSmoothIn;
		}
		else if ([value isEqualToString:kNGLEaseSmoothInOut])
		{
			_ease = &nglEaseSmoothInOut;
		}
		else if ([value isEqualToString:kNGLEaseStrongOut])
		{
			_ease = &nglEaseStrongOut;
		}
		else if ([value isEqualToString:kNGLEaseStrongIn])
		{
			_ease = &nglEaseStrongIn;
		}
		else if ([value isEqualToString:kNGLEaseStrongInOut])
		{
			_ease = &nglEaseStrongInOut;
		}
		else if ([value isEqualToString:kNGLEaseElasticOut])
		{
			_ease = &nglEaseElasticOut;
		}
		else if ([value isEqualToString:kNGLEaseElasticIn])
		{
			_ease = &nglEaseElasticIn;
		}
		else if ([value isEqualToString:kNGLEaseElasticInOut])
		{
			_ease = &nglEaseElasticInOut;
		}
		else if ([value isEqualToString:kNGLEaseBounceOut])
		{
			_ease = &nglEaseBounceOut;
		}
		else if ([value isEqualToString:kNGLEaseBounceIn])
		{
			_ease = &nglEaseBounceIn;
		}
		else if ([value isEqualToString:kNGLEaseBounceInOut])
		{
			_ease = &nglEaseBounceInOut;
		}
		else if ([value isEqualToString:kNGLEaseBackOut])
		{
			_ease = &nglEaseBackOut;
		}
		else if ([value isEqualToString:kNGLEaseBackIn])
		{
			_ease = &nglEaseBackIn;
		}
		else if ([value isEqualToString:kNGLEaseBackInOut])
		{
			_ease = &nglEaseBackInOut;
		}
	}
	
	//*************************
	//	Delay
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyDelay];
	
	_delay = (value) ? [value floatValue] : 0.0f;
	
	//*************************
	//	Start
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyStart];
	
	self.paused = ([value isEqualToString:kNGLTweenStartPaused]);
	
	// Sets the initial state.
	if ([value isEqualToString:kNGLTweenStartImmediately])
	{
		BOOL back = [[_settings objectForKey:kNGLTweenKeyReverse] isEqualToString:kNGLTweenReverseYes];
		[self setValuesAndRevert:back revertEase:NO];
	}
	
	//*************************
	//	Reverse
	//*************************
	// Initial values will be set later on. At the time the tween really starts.
	
	//*************************
	//	Repeat
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyRepeat];
	
	_repeating = ([value isEqualToString:kNGLTweenRepeatLoop] ||
				  [value isEqualToString:kNGLTweenRepeatMirror] ||
				  [value isEqualToString:kNGLTweenRepeatMirrorEase]);
	
	_mirrored = NO;
	
	//*************************
	//	Repeat Count
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyRepeatCount];
	
	_totalCycles = (_repeating) ? [value intValue] - 1 : 0;
	
	//*************************
	//	Repeat Delay
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyRepeatDelay];
	
	_delayRepeat = [value floatValue];
	
	//*************************
	//	Retain Target
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyRetainTarget];
	
	if ([value isEqualToString:kNGLTweenRetainTargetYes])
	{
		[_target retain];
	}
	
	//*************************
	//	Override
	//*************************
	value = [_settings objectForKey:kNGLTweenKeyOverride];
	
	if (value != nil)
	{
		BOOL stopFinished = [value isEqualToString:kNGLTweenOverrideFinished];
		NGLTweenStop stop = (stopFinished) ? NGLTweenStopFinished : NGLTweenStopCurrent;
		[NGLTween stopTweens:stop forTarget:_target];
	}
}

- (void) finishCycle
{
	[self resetTime];
	++_currentCycle;
	
	// Checks for the last cycle and ends this tween.
	if (_currentCycle > _totalCycles)
	{
		[self stopTween:NGLTweenStopCurrent];
		return;
	}
	
	NSString *repeat = [_settings objectForKey:kNGLTweenKeyRepeat];
	
	if ([repeat isEqualToString:kNGLTweenRepeatMirror])
	{
		// Changes the mirror state.
		_mirrored = !_mirrored;
		[self setValuesAndRevert:YES revertEase:NO];
	}
	else if ([repeat isEqualToString:kNGLTweenRepeatMirrorEase])
	{
		// Changes the mirror state.
		_mirrored = !_mirrored;
		[self setValuesAndRevert:YES revertEase:YES];
	}
	
	// The repetitions delay just affect the not mirrored tween.
	if (!_mirrored)
	{
		_delay = _delayRepeat;
	}
}

- (void) setValuesAndRevert:(BOOL)revertValues revertEase:(BOOL)revertEase
{
	NSString *key;
	id object;
	BOOL isRelative;
	float fromValue, toValue, originalValue;
	float inValue, outValue;
	float *valuesPtr, *reversePtr;
	
	// Defines the absolute start value and the final relative value only once per tween instance.
	if (!_ready)
	{
		_ready = YES;
		
		// Sets a pointer to all values.
		_allValues = malloc(2 * [_allKeys count] * NGL_SIZE_FLOAT);
		valuesPtr = _allValues;
		
		for (key in _allKeys)
		{
			// Gets the target's current value for this key.
			originalValue = [[_target valueForKeyPath:key] floatValue];
			
			//*************************
			//	From values
			//*************************
			object = [_fromValues objectForKey:key];
			object = (object != nil) ? object : [NSNumber numberWithFloat:originalValue];
			
			// NSString values will be taken as a relative value and NSNumber will be taken as absolute.
			isRelative = [object isKindOfClass:[NSString class]];
			
			// Retrieves the floating numbers.
			fromValue = (isRelative) ? originalValue + [object floatValue] : [object floatValue];
			
			//*************************
			//	To values
			//*************************
			object = [_toValues objectForKey:key];
			object = (object != nil) ? object : [NSNumber numberWithFloat:originalValue];
			
			// NSString values will be taken as a relative value and NSNumber will be taken as absolute.
			isRelative = [object isKindOfClass:[NSString class]];
			
			// Retrieves the floating numbers.
			toValue = (isRelative) ? originalValue + [object floatValue] : [object floatValue];
			
			//*************************
			//	Final values
			//*************************
			// Sets the initial absolute value and the change value.
			inValue = (revertValues) ? toValue : fromValue;
			outValue = (revertValues) ? fromValue - toValue : toValue - fromValue;
			
			// Stores the final values.
			*valuesPtr++ = inValue;
			*valuesPtr++ = outValue;
			
			// Sets the target initial values.
			[_target setValue:[NSNumber numberWithFloat:inValue] forKeyPath:key];
		}
		
		// Releases the values, they will not be necessary anymore.
		nglRelease(_toValues);
		nglRelease(_fromValues);
	}
	else
	{
		// Sets pointers to all values.
		valuesPtr = _allValues;
		reversePtr = _allValues;
		
		for (key in _allKeys)
		{
			// Retrieves the values.
			fromValue = *valuesPtr++;
			toValue = *valuesPtr++;
			
			// Revert the values.
			*reversePtr++ = fromValue + toValue;
			*reversePtr++ = -toValue;
		}
	}
	
	if (revertEase)
	{
		if (_ease == &nglEaseSmoothOut)
		{
			_ease = &nglEaseSmoothIn;
		}
		else if (_ease == &nglEaseSmoothIn)
		{
			_ease = &nglEaseSmoothOut;
		}
		else if (_ease == &nglEaseStrongOut)
		{
			_ease = &nglEaseStrongIn;
		}
		else if (_ease == &nglEaseStrongIn)
		{
			_ease = &nglEaseStrongOut;
		}
		else if (_ease == &nglEaseElasticOut)
		{
			_ease = &nglEaseElasticIn;
		}
		else if (_ease == &nglEaseElasticIn)
		{
			_ease = &nglEaseElasticOut;
		}
		else if (_ease == &nglEaseBounceOut)
		{
			_ease = &nglEaseBounceIn;
		}
		else if (_ease == &nglEaseBounceIn)
		{
			_ease = &nglEaseBounceOut;
		}
		else if (_ease == &nglEaseBackOut)
		{
			_ease = &nglEaseBackIn;
		}
		else if (_ease == &nglEaseBackIn)
		{
			_ease = &nglEaseBackOut;
		}	
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//  Self Public Methods
//**************************************************

- (void) timerCallBack
{
	// Processes the pause.
	if (_paused)
	{
		return;
	}
	
	// Counts the background time, that means, the time which application was in background mode.
	if (nglBackgroundTime() > 0.0)
	{
		_idleTime += nglBackgroundTime();
	}
	
	// Gets the tween time respecting the pause and delay.
	_currentTime = CFAbsoluteTimeGetCurrent() - _idleTime;
	
	// Processes delays.
	if (_delay > _currentTime)
	{
		return;
	}
	else
	{
		_delay = 0.0f;
	}
	
	// Calculates the current delta of the time.
	_beginTime = (_beginTime == 0.0) ? _currentTime : _beginTime;
	_deltaTime = (float)(_currentTime - _beginTime);
	_deltaTime = (_deltaTime > _duration) ? _duration : _deltaTime;
	
	// Checks if the delegate still valid.
	if (_delegate == nil)
	{
		_inspector = 0;
	}
	
	// Pre-Callback calls.
	if (_deltaTime == 0.0)
	{
		if (_currentCycle == 0)
		{
			if (_inspector & NGLTweenWillStart)
			{
				[_delegate tweenWillStart:self];
			}
			
			// Sets the initial state.
			BOOL back = [[_settings objectForKey:kNGLTweenKeyReverse] isEqualToString:kNGLTweenReverseYes];
			
			if (!_ready)
			{
				[self setValuesAndRevert:back revertEase:NO];
			}
		}
		else if (_inspector & NGLTweenWillRepeat)
		{
			[_delegate tweenWillRepeat:self];
		}
	}
	else if (_deltaTime == _duration && _currentCycle >= _totalCycles && _inspector & NGLTweenWillFinish)
	{
		[_delegate tweenWillFinish:self];
	}
	
	// Just performs the tween is the target still valid.
	if (nglPointerIsValidToClass(_target, _targetClass))
	{
		float begin, change, value;
		float *valuesPtr;
		NSString *key;
		
		// Sets a pointer to all values.
		valuesPtr = _allValues;
		
		// Calculates the new value and update the target.
		for (key in _allKeys)
		{
			begin = *valuesPtr++;
			change = *valuesPtr++;
			
			value = _ease(begin, change, _deltaTime, _duration);
			[_target setValue:[NSNumber numberWithFloat:value] forKeyPath:key];
		}
	}
	// If the target dies during the tween, the tween will die as well.
	else
	{
		[self stopTween:NGLTweenStopCurrent];
	}
	
	// Post-Callback calls.
	if (_deltaTime == 0.0 && _currentCycle == 0 && _inspector & NGLTweenDidStart)
	{
		[_delegate tweenDidStart:self];
	}
	else if (_deltaTime == _duration)
	{
		if (_currentCycle > 0 && _inspector & NGLTweenDidRepeat)
		{
			[_delegate tweenDidRepeat:self];
		}
		
		if (_currentCycle >= _totalCycles && _inspector & NGLTweenDidFinish)
		{
			[_delegate tweenDidFinish:self];
		}
		
		// Ends a cycle.
		[self finishCycle];
	}
}

- (void) restartTween
{
	[self resetTime];
	
	if (_mirrored)
	{
		NSString *repeat = [_settings objectForKey:kNGLTweenKeyRepeat];
		[self setValuesAndRevert:YES revertEase:[repeat isEqualToString:kNGLTweenRepeatMirrorEase]];
		_mirrored = NO;
	}
	
	_currentCycle = 0;
}

- (void) stopTween:(NGLTweenStop)option
{
	NSString *retain;
	NSString *repeat;
	NSString *key;
	float begin, change;
	float *valuesPtr;
	
	switch (option)
	{
		case NGLTweenStopFinished:
			if (_mirrored)
			{
				repeat = [_settings objectForKey:kNGLTweenKeyRepeat];
				[self setValuesAndRevert:YES revertEase:[repeat isEqualToString:kNGLTweenRepeatMirrorEase]];
				_mirrored = NO;
			}
			
			// Sets a pointer to all values.
			valuesPtr = _allValues;
			
			// Sets all the keys for the final value in the current cycle.
			for (key in _allKeys)
			{
				begin = *valuesPtr++;
				change = *valuesPtr++;
				
				[_target setValue:[NSNumber numberWithFloat:begin + change] forKeyPath:key];
			}
			break;
		default:
			break;
	}
	
	// Releases the retained target.
	retain = [_settings objectForKey:kNGLTweenKeyRetainTarget];
	if ([retain isEqualToString:kNGLTweenRetainTargetYes])
	{
		nglRelease(_target);
	}
	
	// Removing tween.
	[[NGLTimer defaultTimer] removeItem:self];
	[_tweens removePointer:self];
}

+ (NSArray *) tweensWithTarget:(id)target
{
	NGLTween *tween;
	NSMutableArray *tweens = [NSMutableArray array];
	
	nglFor(tween, _tweens)
	{
		if (tween.target == target)
		{
			[tweens addObject:tween];
		}
	}
	
	return ([tweens count] > 0) ? tweens : nil;
}

+ (NSArray *) tweensWithName:(NSString *)name
{
	NGLTween *tween;
	NSMutableArray *tweens = [NSMutableArray array];
	
	nglFor(tween, _tweens)
	{
		if ([tween.name isEqualToString:name])
		{
			[tweens addObject:tween];
		}
	}
	
	return ([tweens count] > 0) ? tweens : nil;
}

+ (void) stopTweens:(NGLTweenStop)option forTarget:(id)target
{
	NGLTween *tween;
	
	nglFor(tween, _tweens)
	{
		if (tween.target == target)
		{
			[tween stopTween:option];
		}
	}
}

+ (void) stopTweens:(NGLTweenStop)option forName:(NSString *)name
{
	NGLTween *tween;
	
	nglFor(tween, _tweens)
	{
		if ([tween.name isEqualToString:name])
		{
			[tween stopTween:option];
		}
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//  Override Public Methods
//**************************************************

- (void) dealloc
{
	nglRelease(_name);
	nglRelease(_settings);
	nglRelease(_allKeys);
	
	nglFree(_allValues);
	
	[super dealloc];
}

@end