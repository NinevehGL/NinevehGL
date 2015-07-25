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