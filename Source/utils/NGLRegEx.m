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