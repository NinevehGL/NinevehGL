/*
 *	NGLSLSource.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/23/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLFunctions.h"
#import "NGLError.h"

/*!
 *					The mode which the new shader code will be joined in the current shader.
 *
 *					This mode will be used by methods which change the shader structure.
 *
 *	@see			NGLSLSource::addHeader:mode:
 *	@see			NGLSLSource::addBody:mode:
 *	@see			NGLSLSource::addFromFile:mode:
 *	@see			NGLSLSource::addFromString:mode:
 *	@see			NGLSLSource::addFromShader:mode:
 *	
 *	@var			NGLSLAddModeSet
 *					This mode will completely replace the older code by the new one.
 *
 *	@var			NGLSLAddModePrepend
 *					This mode will add the new code below the older code. By this way, you can use
 *					the variables and definitions of the older one.
 *
 *	@var			NGLSLAddModeAppend
 *					This mode will add the new code above the older code. By this way, you can't use
 *					the variables and definitions of the older code. But the older code could use
 *					the definitions and variables defined by this new code.
 */
typedef enum
{
	NGLSLAddModeSet		= 0x01,
	NGLSLAddModePrepend	= 0x02,
	NGLSLAddModeAppend	= 0x03,
} NGLSLAddMode;

/*!
 *					Constructs a complete shader string to compile later on.
 *
 *					NGLSLSource is prepared to integrate many shader files and/or strings into one single
 *					shader. You can set the header and body of the shader separately.
 */
@interface NGLSLSource : NSObject
{
@private
	// Contents
	NSMutableString			*_header;
	NSMutableString			*_body;
	
	// Error API
	NGLError				*_error;
}

/*!
 *					The final shader data. This string contains the shader in the final format according
 *					to the GLSL ES.
 */
@property (nonatomic, readonly) NSString *shaderData;

/*!
 *					The current header string.
 */
@property (nonatomic, readonly) NSString *headerData;

/*!
 *					The current body string.
 */
@property (nonatomic, readonly) NSString *bodyData;

/*!
 *					Initializes this NGLSLSource based on a shader file.
 *
 *					Any previous string in this shader will be deleted and replaced by the new content.
 *					The file will be searched using the NinevehGL Path API.
 *
 *	@param			filePath
 *					The path to the file using NinevehGL Path API.
 *
 *	@result			A new initialized NGLSLSource instance.
 */
- (id) initWithFile:(NSString *)filePath;

/*!
 *					Initializes this NGLSLSource based on a shader file.
 *
 *					Any previous string in this shader will be deleted and replaced by the new content.
 *
 *	@param			string
 *					The shader string.
 *
 *	@result			A new initialized NGLSLSource instance.
 */
- (id) initWithString:(NSString *)string;

/*!
 *					Initializes this NGLSLSource based on another NGLSLSource.
 *
 *					Any previous string in this shader will be deleted and replaced by the new content.
 *
 *	@param			shader
 *					The NGLSLSource instance.
 *
 *	@result			A new initialized NGLSLSource instance.
 */
- (id) initWithSource:(NGLSLSource *)shader;

/*!
 *					Initializes this NGLSLSource based on a header and a body strings.
 *
 *					Any previous string in this shader will be deleted and replaced by the new content.
 *
 *	@param			header
 *					A NSString containing the new header.
 *
 *	@param			body
 *					A NSString containing the new body.
 *
 *	@result			A new initialized NGLSLSource instance.
 */
- (id) initWithHeader:(NSString *)header andBody:(NSString *)body;

/*!
 *					Joins a new header content within the current shader content.
 *
 *					The new content will be added following the <code>mode</code> instructions. It can
 *					be added first, last or replace the old content.
 *
 *	@param			header
 *					A NSString containing the new header.
 *
 *	@param			mode
 *					Specifies the mode in which the new content will be added.
 *
 *	@see			NGLSLAddMode
 */
- (void) addHeader:(NSString *)header mode:(NGLSLAddMode)mode;

/*!
 *					Joins a new body content within the current shader content.
 *
 *					The new content will be added following the <code>mode</code> instructions. It can
 *					be added first, last or replace the old content.
 *
 *	@param			body
 *					A NSString containing the new body.
 *
 *	@param			mode
 *					Specifies the mode in which the new content will be added.
 *
 *	@see			NGLSLAddMode
 */
- (void) addBody:(NSString *)body mode:(NGLSLAddMode)mode;

/*!
 *					Joins new shader content from a file within the current shader content.
 *
 *					The new content will be added following the <code>mode</code> instructions. It can
 *					be added first, last or replace the old content.
 *
 *	@param			filePath
 *					A NSString containing the path. It uses NinevehGL Path API. 
 *
 *	@param			mode
 *					Specifies the mode in which the new content will be added.
 *
 *	@see			NGLSLAddMode
 */
- (void) addFromFile:(NSString *)filePath mode:(NGLSLAddMode)mode;

/*!
 *					Joins new shader content from a string within the current shader content.
 *
 *					The new content will be added following the <code>mode</code> instructions. It can
 *					be added first, last or replace the old content.
 *
 *	@param			string
 *					A NSString containing the new shader content. 
 *
 *	@param			mode
 *					Specifies the mode in which the new content will be added.
 *
 *	@see			NGLSLAddMode
 */
- (void) addFromString:(NSString *)string mode:(NGLSLAddMode)mode;

/*!
 *					Joins new shader content from another NGLSLSource within the current shader content.
 *
 *					The new content will be added following the <code>mode</code> instructions. It can
 *					be added first, last or replace the old content.
 *
 *	@param			shader
 *					A NGLSLSource instance. 
 *
 *	@param			mode
 *					Specifies the mode in which the new content will be added.
 *
 *	@see			NGLSLAddMode
 */
- (void) addFromSource:(NGLSLSource *)shader mode:(NGLSLAddMode)mode;

/*!
 *					Searches for a string/pattern inside this shader.
 *
 *					The string can be a literal string or a RegEx pattern. This method will search for the
 *					pattern in the header only. That means, will search for a declaration.
 *
 *	@param			pattern
 *					A string representing the literal search or a RegEx pattern.
 */
- (BOOL) hasHeader:(NSString *)pattern;

/*!
 *					Searches for a string/pattern inside this shader.
 *
 *					The string can be a literal string or a RegEx pattern. This method will search for the
 *					pattern in the body only. That means, will search for a usage.
 *
 *	@param			pattern
 *					A string representing the literal search or a RegEx pattern.
 */
- (BOOL) hasBody:(NSString *)pattern;

/*!
 *					Searches for a string/pattern inside this shader.
 *
 *					The string can be a literal string or a RegEx pattern. This method will search for the
 *					pattern in all the shader, including header and body.
 *
 *	@param			pattern
 *					A string representing the literal search or a RegEx pattern.
 */
- (BOOL) hasPattern:(NSString *)pattern;

@end