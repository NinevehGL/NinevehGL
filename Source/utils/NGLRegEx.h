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
 *					Defines option flags to a regular expression function.
 *
 *						- G (Global): More than one match can occur, the RegEx will stop only in the end;
 *						- D (Dotall): Allow . (dot) to match any character, including line separators;
 *						- M (Multiline): Allow ^ and $ to match the start and end of lines;
 *						- I (Ignore Case): Upper and lower case are treat without distinction.
 *
 *	@var			NGLRegExFlagGDM
 *					Represents Global, Dotall and Multiline.
 *	
 *	@var			NGLRegExFlagGDMI
 *					Represents Global, Dotall, Multiline and Ignore Case.
 */
typedef NS_OPTIONS(NSUInteger, NGLRegExFlag)
{
	NGLRegExFlagGDM = 1 << 3 | 1 << 4,
	NGLRegExFlagGDMI = 1 << 0 | 1 << 3 | 1 << 4,
};

/*!
 *					Matches a regular expression against a string counting the number of ocurrences.
 *					If no match found, this function will return 0.
 *	
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to be performed.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			An unsigned int indicating the number of occurences of the regular expression.
 */
NGL_API unsigned int nglRegExCount(NSString *original, NSString *regex, NGLRegExFlag flag);

/*!
 *					Matches a regular expression against a string. If no match found, this function will
 *					return NO, if one or more matches is found, then this function will return YES.
 *	
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to be performed.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			A BOOL data type indicating if the regular expression found any match.
 */
NGL_API BOOL nglRegExMatch(NSString *original, NSString *regex, NGLRegExFlag flag);

/*!
 *					Searches and replace a string by using regular expression.
 *	
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to be performed.
 *
 *	@param			pattern
 *					The pattern (conforming to regular expression patterns) that will replace the matched
 *					regex.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			The resulting NSString. This string is an auto-released instance.
 */
NGL_API NSString *nglRegExReplace(NSString *original, NSString *regex, NSString *string, NGLRegExFlag flag);
