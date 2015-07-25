/*
 *	NGLTween.h
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

#import "NGLRuntime.h"
#import "NGLCoreTimer.h"
#import "NGLEase.h"
#import "NGLError.h"

@class NGLTween;

/*!
 *					Defines the stop function.
 *
 *					When stopping a tween, you can choose to choose to stop in the current state or stop
 *					with the finished state of the tween.
 *
 *	@var			NGLTweenStopCurrent
 *					Represents that the tween will stop with the current state.
 *	
 *	@var			NGLTweenStopFinished
 *					Represents that the tween will stop with the finished state.
 */
typedef enum
{
	NGLTweenStopCurrent,
	NGLTweenStopFinished,
} NGLTweenStop;

#pragma mark -
#pragma mark Tween Keys
#pragma mark -
//**********************************************************************************************************
//
//	Tween Keys
//
//**********************************************************************************************************

/*!
 *					The name key for the #NGLTween#. Its value must be a NSString.
 */
NGL_API NSString *const kNGLTweenKeyName;

/*!
 *					The ease key for the #NGLTween#. Its value must be a NSString or NSValue with a pointer
 *					to a custom ease function.
 *
 *					The value to this property can be one
 *					<code>kNGLEase*</code> constant or a NSValue pointing to a C function. You can create
 *					your own ease function. To do that just create a function conforming to nglEase pointer
 *					and then pass a pointer to your function inside a NSValue.
 *
 *					<pre>
 *	
 *					float myCustomEase(float begin, float change, float time, float duration)
 *					{
 *						// My easing code.
 *					}
 *
 *					...
 *
 *					NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
 *												[NSValue valueWithPointer:&myCustomEase], kNGLTweenKeyEase,
 *												nil];
 *	
 *					[NGLTween tweenWithTarget:myTarget duration:1.0 values:settings];
 *
 *					</pre>
 *
 *					Check out the nglEase documentation to see details about the pre-defined ease functions.
 *
 *					The default value is kNGLEaseSmoothOut.
 *
 *	@see			kNGLEaseLinear
 *	@see			kNGLEaseSmoothOut
 *	@see			kNGLEaseSmoothIn
 *	@see			kNGLEaseSmoothInOut
 *	@see			kNGLEaseStrongOut
 *	@see			kNGLEaseStrongIn
 *	@see			kNGLEaseStrongInOut
 *	@see			kNGLEaseElasticOut
 *	@see			kNGLEaseElasticIn
 *	@see			kNGLEaseElasticInOut
 *	@see			kNGLEaseBounceOut
 *	@see			kNGLEaseBounceIn
 *	@see			kNGLEaseBounceInOut
 *	@see			kNGLEaseBackOut
 *	@see			kNGLEaseBackIn
 *	@see			kNGLEaseBackInOut
 */
NGL_API NSString *const kNGLTweenKeyEase;

/*!
 *					The delay key for the #NGLTween#. Its value must be a NSString or NSNumber.
 *
 *					Its value must be a NSNumber with float, representing the time in seconds.
 *
 *					The default value is 0.
 */
NGL_API NSString *const kNGLTweenKeyDelay;

/*!
 *					The start key for the #NGLTween#. Its value must be a NSString.
 *
 *					Its value must be #kNGLTweenStartPaused# to create a paused tween.
 *
 *	@see			kNGLTweenStartPaused
 *	@see			kNGLTweenStartImmediately
 */
NGL_API NSString *const kNGLTweenKeyStart;

/*!
 *					The reverse key to #NGLTween#. Its value must be a NSString.
 *
 *					Its value must be #kNGLTweenReverseYes# to start a reversed tween.
 *					The tween will happen in the reverse way, that means, from the final values to the
 *					initial values. The initial values are the current state.
 *
 *	@see			kNGLTweenReverseYes
 */
NGL_API NSString *const kNGLTweenKeyReverse;

/*!
 *					The reverse instruction key for the #NGLTween#. Its value must be a NSString.
 *
 *					The NSString can be:
 *
 *						- kNGLTweenRepeatLoop: Means the repetitions will restart from the begining;
 *						- kNGLTweenRepeatMirror: Means the repetitions will reverse the animation;
 *						- kNGLTweenRepeatMirrorEase: Mirrors the ease function as well.
 *
 *					You can set the repeat count.
 *
 *	@see			kNGLTweenRepeatLoop
 *	@see			kNGLTweenRepeatMirror
 *	@see			kNGLTweenRepeatMirrorEase
 *	@see			kNGLTweenKeyRepeatCount
 */
NGL_API NSString *const kNGLTweenKeyRepeat;

/*!
 *					The reverse count key for the #NGLTween#. Its value must be a NSString or NSNumber.
 *
 *					If no repeat count is set or is equal to 0 that means that the repeat will be infinity.
 *					Even if you set the repeat count, the repetitions will happen only if the
 *					#kNGLTweenKeyReverse# is set to #kNGLTweenReverseYes#.
 *
 *					The default value is 0.
 *
 *	@see			kNGLTweenKeyRepeat
 */
NGL_API NSString *const kNGLTweenKeyRepeatCount;

/*!
 *					The repeat delay key for the #NGLTween#. Its value must be a NSString or NSNumber.
 *
 *					The value represents the time in seconds. This delay will happen at each new repetition.
 *
 *					The default value is 0.
 *
 *	@see			kNGLTweenKeyRepeat
 */
NGL_API NSString *const kNGLTweenKeyRepeatDelay;

/*!
 *					The override key for the #NGLTween#. Its value must be a NSString.
 *
 *					The NSString can be:
 *
 *						- kNGLTweenOverrideCurrent: Means the override will occurs with the current state;
 *						- kNGLTweenOverrideFinished: Means the override will occurs with the fnished state.
 *
 *					This instruction will be used only if you are trying to make more than one tween on the
 *					same target. The old tween will stop immediately and the newer will start, respecting
 *					the new settings (delay, pause, etc.).
 *
 *					In case of no override, both tweens will still alive, performing their routine and
 *					affecting the same object at the same time.
 *
 *	@see			kNGLTweenOverrideCurrent
 *	@see			kNGLTweenOverrideFinished
 */
NGL_API NSString *const kNGLTweenKeyOverride;

/*!
 *					The reverse key to #NGLTween#. Its value must be a NSString.
 *
 *					Its value must be #kNGLTweenReverseYes# to start a reversed tween.
 *					The tween will happen in the reverse way, that means, from the final values to the
 *					initial values. The initial values are the current state.
 */
NGL_API NSString *const kNGLTweenKeyRetainTarget;

#pragma mark -
#pragma mark Tween Values
#pragma mark -
//**********************************************************************************************************
//
//	Tween Values
//
//**********************************************************************************************************

/*!
 *					Value to the #kNGLTweenKeyStart#.
 *
 *					With this value, the tween will not start automatically.
 */
NGL_API NSString *const kNGLTweenStartPaused;

/*!
 *					Value to the #kNGLTweenKeyStart#.
 *
 *					With this value, the tween will start immediately even with multithreading enabled.
 *					In this case, the target will assumes its initial position on the tween even if the
 *					tween has a delay key.
 */
NGL_API NSString *const kNGLTweenStartImmediately;

/*!
 *					Value to the #kNGLTweenKeyReverse#.
 *
 *					With this value, the tween will start from the end and goes to the begining.
 */
NGL_API NSString *const kNGLTweenReverseYes;

/*!
 *					Value to the kNGLTweenKeyRepeat key.
 *
 *					This value represents that a loop repetition will happen after the end of tween,
 *					restarting the tween immediately.
 *
 *	@see			kNGLTweenKeyRepeat
 */
NGL_API NSString *const kNGLTweenRepeatLoop;

/*!
 *					Value to the kNGLTweenKeyRepeat key.
 *
 *					This value represents that a mirror repetition will happen after the end of tween,
 *					reversing the tween until the initial values again. If more than one repeat count
 *					was set, the mirror will keep mirroring the last executed tween.
 *
 *					This key reverse the values but not the ease function.
 *
 *	@see			kNGLTweenKeyRepeat
 */
NGL_API NSString *const kNGLTweenRepeatMirror;

/*!
 *					Value to the kNGLTweenKeyRepeat key.
 *
 *					This value represents that a mirror repetition will happen after the end of tween,
 *					reversing the tween and its ease function as well. Reversing the ease function means
 *					the "In" will become "Out" ease effect. It has no effect on "InOut" and
 *					"Linear" functions.
 *
 *	@see			kNGLTweenKeyRepeat
 */
NGL_API NSString *const kNGLTweenRepeatMirrorEase;

/*!
 *					Value to the kNGLTweenKeyOverride key. The overrided will stop with the current state.
 *
 *	@see			kNGLTweenKeyOverride
 */
NGL_API NSString *const kNGLTweenOverrideCurrent;

/*!
 *					Value to the kNGLTweenKeyOverride key. The overrided will stop with the final state.
 *
 *	@see			kNGLTweenKeyOverride
 */
NGL_API NSString *const kNGLTweenOverrideFinished;

/*!
 *					Value to the #kNGLTweenKeyRetainTarget#.
 *
 *					With this value, the tween will retain the target.
 */
NGL_API NSString *const kNGLTweenRetainTargetYes;

#pragma mark -
#pragma mark Tween Eases
#pragma mark -
//**********************************************************************************************************
//
//	Tween Eases
//
//**********************************************************************************************************

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseLinear function.
 *
 *	@see			nglEaseLinear
 */
NGL_API NSString *const kNGLEaseLinear;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseSmoothOut function.
 *
 *	@see			nglEaseSmoothOut
 */
NGL_API NSString *const kNGLEaseSmoothOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseSmoothIn function.
 *
 *	@see			nglEaseSmoothIn
 */
NGL_API NSString *const kNGLEaseSmoothIn;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseSmoothInOut function.
 *
 *	@see			nglEaseSmoothInOut
 */
NGL_API NSString *const kNGLEaseSmoothInOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseStrongOut function.
 *
 *	@see			nglEaseStrongOut
 */
NGL_API NSString *const kNGLEaseStrongOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseStrongIn function.
 *
 *	@see			nglEaseStrongIn
 */
NGL_API NSString *const kNGLEaseStrongIn;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseStrongInOut function.
 *
 *	@see			nglEaseStrongInOut
 */
NGL_API NSString *const kNGLEaseStrongInOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseElasticOut function.
 *
 *	@see			nglEaseElasticOut
 */
NGL_API NSString *const kNGLEaseElasticOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseElasticIn function.
 *
 *	@see			nglEaseElasticIn
 */
NGL_API NSString *const kNGLEaseElasticIn;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseElasticInOut function.
 *
 *	@see			nglEaseElasticInOut
 */
NGL_API NSString *const kNGLEaseElasticInOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseBounceOut function.
 *
 *	@see			nglEaseBounceOut
 */
NGL_API NSString *const kNGLEaseBounceOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseBounceIn function.
 *
 *	@see			nglEaseBounceIn
 */
NGL_API NSString *const kNGLEaseBounceIn;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseBounceInOut function.
 *
 *	@see			nglEaseBounceInOut
 */
NGL_API NSString *const kNGLEaseBounceInOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseBackOut function.
 *
 *	@see			nglEaseBackOut
 */
NGL_API NSString *const kNGLEaseBackOut;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseBackIn function.
 *
 *	@see			nglEaseBackIn
 */
NGL_API NSString *const kNGLEaseBackIn;

/*!
 *					Value to the kNGLTweenKeyEase key. Represents the nglEaseBackInOut function.
 *
 *	@see			nglEaseBackInOut
 */
NGL_API NSString *const kNGLEaseBackInOut;

/*!
 *					Protocol to NGLTween delegation.
 *
 *					This protocol defines optional methods to be called during a tween. All methods return
 *					pointers to the #NGLTween# that had generate that call, so you can interact with the
 *					original #NGLTween# instance.
 *
 *					The methods are:
 *
 *						- tweenWillStart: Called once immediately before the tween start (after all delays).
 *						- tweenDidStart: Called once immediately after the tween produce have produced the
 *							first movement.
 *						- tweenWillRepeat: Called every time before the tween start a new repetition.
 *						- tweenDidRepeat: Called every time after the tween have finished repetition.
 *						- tweenWillFinish: Called once immediately before the last movement of the tween.
 *						- tweenDidFinish: Called once after the tween complete, including all repetitions.
 */
@protocol NGLTweenDelegate <NSObject>

@optional

/*!
 *					This method is called once immediately before the tween start (after all delays).
 *
 *	@param			tween
 *					The tween instance that have generated this call.
 */
- (void) tweenWillStart:(NGLTween *)tween;

/*!
 *					This method is called once immediately after the tween produce have produced the
 *					first movement.
 *
 *	@param			tween
 *					The tween instance that have generated this call.
 */
- (void) tweenDidStart:(NGLTween *)tween;

/*!
 *					This method is called every time before the tween start a new repetition.
 *
 *	@param			tween
 *					The tween instance that have generated this call.
 */
- (void) tweenWillRepeat:(NGLTween *)tween;

/*!
 *					This method is called every time after the tween have finished repetition.
 *
 *	@param			tween
 *					The tween instance that have generated this call.
 */
- (void) tweenDidRepeat:(NGLTween *)tween;

/*!
 *					This method is called once immediately before the last movement of the tween.
 *
 *	@param			tween
 *					The tween instance that have generated this call.
 */
- (void) tweenWillFinish:(NGLTween *)tween;

/*!
 *					This method is called once after the tween complete, including all repetitions.
 *
 *	@param			tween
 *					The tween instance that have generated this call.
 */
- (void) tweenDidFinish:(NGLTween *)tween;

@end

/*!
 *					#NGLTween# is responsible for creating and managing interpolations to scalar properties,
 *					that means, floating values, throughout a time.
 *
 *					The tweens can have ease In and/or Out interpolations. The tweens are created with an
 *					instance of #NGLTween#, you can choose to hold it or not. Even if you choose don't
 *					retain its instance, you are able to retrieve it later based on its name or target.
 *
 *					The tween can be paused and resumed by using the <code>#paused#</code> property, you can
 *					also cancel the tween with <code>#cancelTween#</code> or restart it by calling the
 *					<code>#restartTween#</code> method.
 *
 *					The #NGLTween# works with the delegate concept. You can define a delegate class to
 *					receive messages from events of your tween, like "will start", "will repeat",
 *					"did finish" and others.
 *
 *					#NGLTween# is a sophisticated way to deal with animations because it makes use of
 *					NGLTimer, the unique optimized timer of NinevehGL. You can even define infinity
 *					animations with #NGLTween#.
 *
 *					To initialize a tween you must use <code>#tweenWithTarget:duration:values:#</code> or
 *					<code>#initWithTarget:duration:values:#</code> methods. The single <code>init</code>
 *					has no effect. The tween will start on the next render cycle, respecting the current
 *					NinevehGL Global FPS.
 */
@interface NGLTween : NSObject <NGLCoreTimer>
{
@private
	NSString				*_name;
	id <NGLTweenDelegate>	_delegate;
	unsigned int			_inspector;
	
	id						_target;
	Class					_targetClass;
	float					_duration;
	
	float					_deltaTime;
	double					_beginTime, _currentTime, _lastTime, _idleTime;
	
	unsigned int			_currentCycle, _totalCycles;
	BOOL					_repeating;
	BOOL					_mirrored;
	BOOL					_paused;
	BOOL					_ready;
	float					_delay;
	float					_delayRepeat;
	
	NSMutableDictionary		*_settings;
	NSMutableDictionary		*_toValues;
	NSMutableDictionary		*_fromValues;
	NSMutableArray			*_allKeys;
	float					*_allValues;
	
	nglEase					_ease;
}

/*!
 *					Pauses or resumes the animation. When set to YES, it pauses immediatly the tween.
 *
 *					There is no limit of time for a paused tween, it will keep paused until you set this
 *					property to NO again, which will resume the tween.
 *
 *					When you resume, the tween continues from the same point it was paused.
 */
@property (nonatomic) BOOL paused;

/*!
 *					The name is an identifier.
 *
 *					You can use the name to retrieve a #NGLTween# instance later.
 *					This property can't be changed and must be defined when you construct the tween.
 */
@property (nonatomic, readonly) NSString *name;

/*!
 *					The target of the tween.
 *
 *					The changes will happen on this object. This property can't be changed and must be
 *					defined when you construct the tween.
 */
@property (nonatomic, readonly) id target;

/*!
 *					The delegate must conform to #NGLTweenDelegate# protocol.
 *
 *	@see			NGLTweenDelegate
 */
@property (nonatomic, assign) id <NGLTweenDelegate> delegate;

/*!
 *					Restarts the tween from the beginig.
 *
 *					This method restarts the whole tween, even the repetitions it has.
 */
- (void) restartTween;

/*!
 *					Stops the tween immediately.
 *
 *					You can choose if the tween will stop in the current state or if it'll go to the end,
 *					assuming the final state. If the tween is in a loop, the final state is the end of
 *					the current loop cycle.
 *
 *	@param			option
 *					The type of the stopping. The tween can stop at the very current moment with the
 *					current state or stop with the initial state. The finished states is about the
 *					final state of the current loop cycle.
 *
 *	@see			NGLTweenStop
 */
- (void) stopTween:(NGLTweenStop)option;

/*!
 *					Initializes a #NGLTween# instance with a target, duration and settings.
 *
 *	@param			to
 *					A NSDictionary containing the list of settings/values that this tween is going to.
 *
 *	@param			seconds
 *					The duration of the tween in seconds.
 *
 *	@param			target
 *					The target of the tween. Only the scalar properties can be tweened.
 *
 *	@result			A new autoreleased instance.
 */
+ (id) tweenTo:(NSDictionary *)to duration:(float)seconds target:(id)target;

/*!
 *					Initializes a #NGLTween# instance with a target, duration and settings.
 *
 *	@param			from
 *					A NSDictionary containing the list of settings/values that this tween is coming from.
 *
 *	@param			seconds
 *					The duration of the tween in seconds.
 *
 *	@param			target
 *					The target of the tween. Only the scalar properties can be tweened.
 *
 *	@result			A new autoreleased instance.
 */
+ (id) tweenFrom:(NSDictionary *)from duration:(float)seconds target:(id)target;

/*!
 *					Initializes a #NGLTween# instance with a target, duration and settings.
 *
 *	@param			from
 *					A NSDictionary containing the list of settings/values that this tween is coming from.
 *
 *	@param			to
 *					A NSDictionary containing the list of settings/values that this tween is going to.
 *
 *	@param			seconds
 *					The duration of the tween in seconds.
 *
 *	@param			target
 *					The target of the tween. Only the scalar properties can be tweened.
 *
 *	@result			A new autoreleased instance.
 */
+ (id) tweenFrom:(NSDictionary *)from to:(NSDictionary *)to duration:(float)seconds target:(id)target;

/*!
 *					Returns a #NGLTween# instance with the informed target.
 *
 *					If more than one #NGLTween# was found, only the first match will be returned.
 *
 *	@param			target
 *					The target of the tween you are looking for.
 *
 *	@result			The related #NGLTween# instance or nil if not found.
 */
+ (NSArray *) tweensWithTarget:(id)target;

/*!
 *					Returns a #NGLTween# instance with the informed name.
 *
 *					If more than one #NGLTween# was found, only the first match will be returned.
 *
 *	@param			name
 *					The name of the tween you are looking for.
 *
 *	@result			The related #NGLTween# instance or nil if not found.
 */
+ (NSArray *) tweensWithName:(NSString *)name;

/*!
 *					Acts as #stopTween:# method, but working for all tweens of a specific target.
 *
 *	@param			option
 *					The type of the stopping. The tween can stop at the very current moment with the
 *					current state. The finished state will send the target to the final state in the
 *					current tween loop.
 *
 *	@param			target
 *					The target wich has tweens you want to remove.
 *
 *	@see			NGLTweenStop
 */
+ (void) stopTweens:(NGLTweenStop)option forTarget:(id)target;

/*!
 *					Acts as #stopTween:# method, but working for all tweens with a specific name.
 *
 *	@param			option
 *					The type of the stopping. The tween can stop at the very current moment with the
 *					current state. The finished state will send the target to the final state in the
 *					current tween loop.
 *
 *	@param			target
 *					The target wich has tweens you want to remove.
 *
 *	@see			NGLTweenStop
 */
+ (void) stopTweens:(NGLTweenStop)option forName:(NSString *)name;

@end