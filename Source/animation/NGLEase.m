/*
 *	NGLEase.m
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

#import "NGLEase.h"
#import "NGLMath.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kTWEEN_0_36			0.363636f
#define kTWEEN_0_54			0.545454f
#define kTWEEN_0_72			0.727272f
#define kTWEEN_0_81			0.818181f
#define kTWEEN_0_90			0.909090f
#define kTWEEN_0_95			0.954545f
#define kTWEEN_1_65			1.656565f
#define kTWEEN_3_23			3.232323f
#define kTWEEN_7_56			7.562525f

#pragma mark -
#pragma mark Common Interpolations
#pragma mark -
//**********************************************************************************************************
//
//  Common Interpolations
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Linear
//**************************************************
//	Linear
//**************************************************

float nglEaseLinear(float begin, float change, float time, float duration)
{
	return change * time / duration + begin;
}

#pragma mark -
#pragma mark Smooth
//**************************************************
//	Smooth
//**************************************************

float nglEaseSmoothOut(float begin, float change, float time, float duration)
{
	time /= duration;
	return -change * time * (time - 2.0f) + begin;
}

float nglEaseSmoothIn(float begin, float change, float time, float duration)
{
	time /= duration;
	return change * time * time + begin;
}

float nglEaseSmoothInOut(float begin, float change, float time, float duration)
{
	if ((time /= duration * 0.5f) < 1.0f)
	{
		return change * 0.5f * time * time + begin;
	}
	
	--time;
	return -change * 0.5f * ((time) * (time - 2.0f) - 1.0f) + begin;
}

#pragma mark -
#pragma mark Strong
//**************************************************
//	Strong
//**************************************************

float nglEaseStrongOut(float begin, float change, float time, float duration)
{
	float power = -powf(2.0f, -10.0f * time / duration) + 1.0f;
	return (time == duration) ? begin + change : change * power + begin;
}

float nglEaseStrongIn(float begin, float change, float time, float duration)
{
	if (time == 0.0f)
	{
		return begin;
	}
	
	return change * powf(2.0f, 10.0f * (time / duration - 1.0f)) + begin - change * 0.001f;
}

float nglEaseStrongInOut(float begin, float change, float time, float duration)
{
	if (time == 0.0f)
	{
		return begin;
	}
	else if (time == duration)
	{
		return begin + change;
	}
	else if ((time /= duration * 0.5f) < 1.0f)
	{
		return change * 0.5f * powf(2.0f, 10.0f * --time) + begin;
	}
	
	return change * 0.5f * (-powf(2.0f, -10.0f * --time) + 2.0f) + begin;
}

#pragma mark -
#pragma mark Special Interpolations
#pragma mark -
//**********************************************************************************************************
//
//  Special Interpolations
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Elastic
//**************************************************
//	Elastic
//**************************************************

float nglEaseElasticOut(float begin, float change, float time, float duration)
{
	float x = change, y = duration * 0.3f, z = y / 4.0f;
	
	if (time == 0.0f)
	{
		return begin;
	} 
	else if ((time /= duration) == 1.0f)
	{
		return begin + change;
	}
	
	return x * powf(2.0f, -10.0f * time) * sinf((time * duration - z) * kNGL_2PI / y) + change + begin;
}

float nglEaseElasticIn(float begin, float change, float time, float duration)
{
	float x = change, y = duration * 0.3f, z = y / 4.0f;
	
	if (time == 0.0f)
	{
		return begin;
	} 
	else if ((time /= duration) == 1.0f)
	{
		return begin + change;
	}
	
	return -x * powf(2.0f, 10.0f * --time) * sinf((time * duration - z) * kNGL_2PI / y) + begin;
}

float nglEaseElasticInOut(float begin, float change, float time, float duration)
{
	float x = change, y = duration * 0.45f, z = y / 4.0f, powTime;
	
	if (time == 0.0f)
	{
		return begin;
	} 
	else if ((time /= duration * 0.5f) == 2.0f)
	{
		return begin + change;
	}
	
	if (time < 1.0)
	{
		powTime = powf(2.0f, 10.0f * --time);
		return -0.5f * x * powTime * sinf((time * duration - z ) * kNGL_2PI / y) + begin;
	}
	
	powTime = powf(2.0f, -10.0f * --time);
	return 0.5f * x * powTime * sinf((time * duration - z) * kNGL_2PI / y) + change + begin;
}

#pragma mark -
#pragma mark Bounce
//**************************************************
//	Bounce
//**************************************************

float nglEaseBounceOut(float begin, float change, float time, float duration)
{
	if ((time /= duration) < kTWEEN_0_36)
	{
		return change * (kTWEEN_7_56 * time * time) + begin;
	}
	else if (time < kTWEEN_0_72)
	{
		time -= kTWEEN_0_54;
		return change * (kTWEEN_7_56 * time * time + kTWEEN_0_72) + begin;
	}
	else if (time < kTWEEN_0_90)
	{
		time -= kTWEEN_0_81;
		return change * (kTWEEN_7_56 * time * time + kTWEEN_0_95) + begin;
	}
	
	time -= kTWEEN_0_95;
	return change * (kTWEEN_7_56 * time * time + kTWEEN_0_95) + begin;
}

float nglEaseBounceIn(float begin, float change, float time, float duration)
{
	return change - nglEaseBounceOut(0.0f, change, duration - time, duration) + begin;
}

float nglEaseBounceInOut(float begin, float change, float time, float duration)
{
	if (time < duration * 0.5f)
	{
		return nglEaseBounceIn(0.0f, change, time * 2.0f, duration) * 0.5f + begin;
	}
	
	return nglEaseBounceOut(0.0f, change, time * 2.0f - duration, duration) * 0.5f + change * 0.5f + begin;
}

#pragma mark -
#pragma mark Back
//**************************************************
//	Back
//**************************************************

float nglEaseBackOut(float begin, float change, float time, float duration)
{
	time = time / duration - 1.0f;
	return change * (time * time * ((kTWEEN_1_65 + 1.0f) * time + kTWEEN_1_65) + 1.0f) + begin;
}

float nglEaseBackIn(float begin, float change, float time, float duration)
{
	time /= duration;
	return change * time * time * ((kTWEEN_1_65 + 1.0f) * time - kTWEEN_1_65) + begin;
}

float nglEaseBackInOut(float begin, float change, float time, float duration)
{
	if ((time /= duration * 0.5f) < 1.0f)
	{
		return change * 0.5f * (time * time * ((kTWEEN_3_23 + 1.0f) * time - kTWEEN_3_23)) + begin;
	}
	
	time -= 2.0f;
	return change * 0.5f * (time * time * ((kTWEEN_3_23 + 1.0f) * time + kTWEEN_3_23) + 2.0f) + begin;
}