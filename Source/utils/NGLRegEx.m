/*
 *	NGLRegEx.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 9/6/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRegEx.h"

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

unsigned int nglRegExCount(NSString *original, NSString *regex, NGLRegExFlag flag)
{
	NSRegularExpression *reg;
	NSUInteger matches;
	
	// Creates the RegExp.
	reg = [NSRegularExpression regularExpressionWithPattern:regex options:(NSUInteger)flag error:nil];
	
	matches = [reg numberOfMatchesInString:original
								   options:NSMatchingReportCompletion
									 range:NSMakeRange(0, [original length])];
	
	return (unsigned int)matches;
}

BOOL nglRegExMatch(NSString *original, NSString *regex, NGLRegExFlag flag)
{
	return nglRegExCount(original, regex, flag) > 0;
}

NSString *nglRegExReplace(NSString *original, NSString *regex, NSString *string, NGLRegExFlag flag)
{
	NSRegularExpression *reg;
	
	// Creates the RegExp.
	reg = [NSRegularExpression regularExpressionWithPattern:regex options:(NSUInteger)flag error:nil];
	
	return [reg stringByReplacingMatchesInString:original
										 options:NSMatchingReportCompletion
										   range:NSMakeRange(0, [original length])
									withTemplate:string];
}