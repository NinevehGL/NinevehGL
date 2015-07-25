/*
 *	NGLSurface.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/29/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLCopying.h"

/*!
 *					Defines the NGLSurface protocol.
 *
 *					This protocol defines the NGLSurface kind, it can be produced many NGLSurface types,
 *					like:
 *
 *						- Standard;
 *						- Multi/Sub.
 */
@protocol NGLSurface <NSObject, NGLCopying>

@end

/*!
 *					The instructions to cover a mesh.
 *
 *					NGLSurface is something very abstract, but it's a very important part in the
 *					shader creation process. It's like a blue print that defines and delimits the area
 *					of each material onto the mesh. NGLSurface is organized by its
 *					<code>#identifier#</code> (ID). Each ID must match with the desired material and
 *					custom shader. For example:
 *
 *					<pre>
 *
 *					NGLMaterial ID            NGLShaders ID             NGLSurface ID
 *					       1      ---------->       1      ----------->       1
 *
 *					                 |------------------------------|
 *					       2      ---|              3      ------|  |->       2
 *					                    |------------------------|
 *					                    |                        |
 *					       3      ------|           4      ---|  |---->       3
 *					                                          |
 *					                                          |
 *					       7                        7         |------->       4
 *
 *					</pre>
 *
 *					The NGLSurface is the coordinator to construct the surface of a mesh. As in the
 *					example above, if a #NGLMaterial# or NGLShaders doesn't have the same ID as
 *					NGLSurface, they will be ignored in the mesh's compilation process.
 *
 *					If no NGLSurface was specified, a default NGLSurface will be used. The default
 *					NGLSurface always cover the entire mesh.
 *
 *	@see			NGLMaterial
 *	@see			NGLShaders
 */
@interface NGLSurface : NSObject <NGLSurface>
{
@private
	unsigned int			_identifier;
	unsigned int			_startData;
	unsigned int			_lengthData;
}

/*!
 *					The identifier of this object.
 */
@property (nonatomic) unsigned int identifier;

/*!
 *					Represents the starting index inside of this surface on the mesh's array of indices.
 */
@property (nonatomic) unsigned int startData;

/*!
 *					Represents the length, in elements, of this surface on the mesh's array of indices.
 */
@property (nonatomic) unsigned int lengthData;

/*!
 *					Initiates a new instance with a start data, length data and an identifier.
 *
 *	@param			start
 *					The starting index for data.
 *
 *	@param			length
 *					The length of data.
 *
 *	@param			newId
 *					The identifier to this instance.
 *
 *	@result			A new initialized instance.
 */
- (id) initWithStart:(unsigned int)start length:(unsigned int)length identifier:(unsigned int)newId;

/*!
 *					Returns an autorelease instance of NGLSurface.
 *
 *					This method creates a surface using the default NGLSurface.
 *
 *	@result			A NGLSurface autoreleased instance.
 */
+ (id) surface;

/*!
 *					Returns an autorelease instance of NGLSurface.
 *
 *					This method creates a surface. This method sets a starting index to it, a length data
 *					and an identifier.
 *
 *	@param			start
 *					The starting index for data.
 *
 *	@param			length
 *					The length of data.
 *
 *	@param			newId
 *					The identifier to this instance.
 *
 *	@result			A NGLSurface autoreleased instance.
 */
+ (id) surfacetWithStart:(unsigned int)start length:(unsigned int)length identifier:(unsigned int)newId;

@end