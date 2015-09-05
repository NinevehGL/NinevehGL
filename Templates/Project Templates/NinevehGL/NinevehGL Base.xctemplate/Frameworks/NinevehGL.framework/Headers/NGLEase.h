/*
 *	NGLEase.h
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

/*!
 *					Defines the function format to be an ease function to #NGLTween#.
 *	
 *	@param			begin
 *					The initial value before the tween start.
 *	
 *	@param			change
 *					The difference between the final value and the initial value.
 *
 *	@param			time
 *					The current time in seconds.
 *
 *	@param			duration
 *					The total duration in seconds.
 *
 *	@result			The calculated scalar value to the current time.
 */
typedef float (*nglEase)(float begin, float change, float time, float duration);

/*!
 *					Defines the linear interpolation.
 *					<img src="http://nineveh.gl/imgs/ngleaselinear.jpg" />
 */
float nglEaseLinear(float begin, float change, float time, float duration);

/*!
 *					Defines the Smooth interpolation with easing out.
 *					<img src="http://nineveh.gl/imgs/ngleasesmoothout.jpg" />
 */
float nglEaseSmoothOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Smooth interpolation with easing in.
 *					<img src="http://nineveh.gl/imgs/ngleasesmoothin.jpg" />
 */
float nglEaseSmoothIn(float begin, float change, float time, float duration);

/*!
 *					Defines the Smooth interpolation with easing in and out.
 *					<img src="http://nineveh.gl/imgs/ngleasesmoothinout.jpg" />
 */
float nglEaseSmoothInOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Strong interpolation with easing out.
 *					<img src="http://nineveh.gl/imgs/ngleasestrongout.jpg" />
 */
float nglEaseStrongOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Strong interpolation with easing in.
 *					<img src="http://nineveh.gl/imgs/ngleasestrongin.jpg" />
 */
float nglEaseStrongIn(float begin, float change, float time, float duration);

/*!
 *					Defines the Strong interpolation with easing in and out.
 *					<img src="http://nineveh.gl/imgs/ngleasestronginout.jpg" />
 */
float nglEaseStrongInOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Elastic interpolation with easing out.
 *					<img src="http://nineveh.gl/imgs/ngleaseelasticout.jpg" />
 */
float nglEaseElasticOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Elastic interpolation with easing in.
 *					<img src="http://nineveh.gl/imgs/ngleaseelasticin.jpg" />
 */
float nglEaseElasticIn(float begin, float change, float time, float duration);

/*!
 *					Defines the Elastic interpolation with easing in and out.
 *					<img src="http://nineveh.gl/imgs/ngleaseelasticinout.jpg" />
 */
float nglEaseElasticInOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Bounce interpolation with easing out.
 *					<img src="http://nineveh.gl/imgs/ngleasebounceout.jpg" />
 */
float nglEaseBounceOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Bounce interpolation with easing in.
 *					<img src="http://nineveh.gl/imgs/ngleasebouncein.jpg" />
 */
float nglEaseBounceIn(float begin, float change, float time, float duration);

/*!
 *					Defines the Bounce interpolation with easing in and out.
 *					<img src="http://nineveh.gl/imgs/ngleasebounceinout.jpg" />
 */
float nglEaseBounceInOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Back interpolation with easing out.
 *					<img src="http://nineveh.gl/imgs/ngleasebackout.jpg" />
 */
float nglEaseBackOut(float begin, float change, float time, float duration);

/*!
 *					Defines the Back interpolation with easing in.
 *					<img src="http://nineveh.gl/imgs/ngleasebackin.jpg" />
 */
float nglEaseBackIn(float begin, float change, float time, float duration);

/*!
 *					Defines the Back interpolation with easing in and out.
 *					<img src="http://nineveh.gl/imgs/ngleasebackinout.jpg" />
 */
float nglEaseBackInOut(float begin, float change, float time, float duration);