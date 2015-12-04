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
#import "NGLFunctions.h"
#import "NGLError.h"
#import "NGLMaterialMulti.h"
#import "NGLSurfaceMulti.h"

/*!
 *					<strong>(Internal only)</strong> This is the #NGLParserOBJ#'s pair to load and
 *					parse WaveFront Material files (.mtl).
 *
 *					NGLParserMTL is capable of parsing multiple files and extracting all material from
 *					there. The output will be a NSArray containing #NGLMaterial# instances.
 *
 *					The supported features for the current version of NGLParserMTL are:
 *
 *						- Ka (r g b);
 *						- Kd (r g b);
 *						- Ks (r g b);
 *						- Ke (r g b);
 *						- d (factor), Tr, Tf (r g b);
 *						- Ni;
 *						- Ns;
 *						- map_Ka;
 *						- map_Kd;
 *						- map_Ks;
 *						- map_Ke;
 *						- map_d;
 *						- map_Bump;
 *						- map_Ns.
 */
@interface NGLParserMTL : NSObject
{
@private
	// Helpers
	UInt32			_lines;
	NSString				*_finalPath;
	NSMutableArray			*_files;
	NSArray					*_cuted;
	const char				*_prefix;
	unsigned char			_cutedCount;
	
	// Materials
	NGLMaterial				*_currentMaterial;
	NGLMaterialMulti		*_materials;
	
	// Surfaces
	NGLSurface				*_currentSurface;
	NGLSurfaceMulti			*_surfaces;
	
	// Error API
	NGLError				*_error;
}

/*!
 *					Returns the material lib containing all the materials parsed from the loaded files.
 */
@property (nonatomic, readonly) NGLMaterialMulti *materials;

/*!
 *					Returns the surface lib containing all the surfaces parsed from the loaded files.
 */
@property (nonatomic, readonly) NGLSurfaceMulti *surfaces;

/*!
 *					This method loads and parses a MTL file.
 *
 *					Each call to this method will load and parse a MTL file. The file will be searched
 *					using the NinevehGL Path API.
 *
 *	@param			named
 *					In NinevehGL the "named" parameter is always related to the NinevehGL Path API, so you
 *					can inform the only the file's name or full path. The full path is related to the file
 *					system. If only the file's name is informed, NinevehGL will search for the file at the
 *					global path.
 */
- (void) loadFile:(NSString *)named;

/*!
 *					Generates a new surface instance.
 *
 *					This method creates a surface and starts using it. By calling the
 *					<code>#updateSurfaceLength#</code> the last created surface will be filled.
 *
 *	@param			name
 *					A NSString containing the name of the material.
 *
 *	@param			start
 *					The index to start using this material in the array of structures.
 *
 *	@see			updateSurfaceLength
 */
- (void) useMaterialWithName:(NSString *)name starting:(int)start;

/*!
 *					Fills the last created surface.
 *
 *					This method should be called once at every new index which continue using the last
 *					created surface. Every call to this method adds one more index to the surface length.
 *
 *	@see			useMaterialWithName:starting:
 */
- (void) updateSurfaceLength;

@end