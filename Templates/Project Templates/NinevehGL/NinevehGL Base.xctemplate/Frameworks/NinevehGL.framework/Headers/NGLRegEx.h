/*
 *	NGLRegEx.h
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
typedef enum
{
	NGLRegExFlagGDM = 1 << 3 | 1 << 4,
	NGLRegExFlagGDMI = 1 << 0 | 1 << 3 | 1 << 4,
} NGLRegExFlag;

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
