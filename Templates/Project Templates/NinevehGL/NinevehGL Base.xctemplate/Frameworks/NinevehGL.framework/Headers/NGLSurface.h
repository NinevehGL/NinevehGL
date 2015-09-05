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
#import "NGLFunctions.h"

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
 *					<strong>(Internal only)</strong> An object that holds the material scalar values.
 *
 *					This structure is used as a fixed pointer to preserve the necessary information (memory)
 *					to the material's scalar values.
 *
 *	@see			NGLvec4
 *
 *	@var			NGLMaterialValues::alpha
 *					Represents the alpha value.
 *
 *	@var			NGLMaterialValues::ambientColor
 *					Represents the ambient color.
 *
 *	@var			NGLMaterialValues::diffuseColor
 *					Represents the diffuse color.
 *
 *	@var			NGLMaterialValues::emissiveColor
 *					Represents the emissive color.
 *
 *	@var			NGLMaterialValues::specularColor
 *					Represents the specular color.
 *
 *	@var			NGLMaterialValues::shininess
 *					Represents the shininess.
 *
 *	@var			NGLMaterialValues::reflectiveLevel
 *					Represents the reflective level.
 *
 *	@var			NGLMaterialValues::refraction
 *					Represents the refraction.
 */
typedef struct
{
	void			*startDataPointer;
	unsigned int	startData;
	unsigned int	lengthData;
} NGLSurfaceValues;

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
 *					NGLMaterial ID            NGLSurface ID             NGLShader ID
 *					     |1|   --------------->   |1|    <---------------     |1|
 *
 *
 *					     |2| (unused)     |--->   |3|    <---------------     |3|
 *					                      |
 *					                      |            (no custom material)
 *					     |3|   -----------|       |4|    <---------------     |4|
 *
 *					          (no custom shader)
 *					     |7|   --------------->   |7|                         |5| (unused)
 *
 *					</pre>
 *
 *					The NGLSurface is the coordinator to construct the surface of a mesh. As in the
 *					example above, if a #NGLMaterial# or NGLShader doesn't have the same ID as
 *					NGLSurface, they will be ignored in the mesh's compilation process.
 *
 *					If no NGLSurface was specified, a default NGLSurface will be used. The default
 *					NGLSurface always cover the entire mesh.
 *
 *	@see			NGLMaterial
 *	@see			NGLShader
 */
@interface NGLSurface : NSObject <NGLSurface>
{
@private
	unsigned int			_identifier;
	NGLSurfaceValues		_values;
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
 *					<strong>(Internal only)</strong> Returns a pointer to the surface scalar values.
 *					You should not call this method directly.
 */
@property (nonatomic, readonly) NGLSurfaceValues *values;

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
 *					Returns an autoreleased instance of NGLSurface.
 *
 *					This method creates a surface using the default NGLSurface.
 *
 *	@result			A NGLSurface autoreleased instance.
 */
+ (id) surface;

/*!
 *					Returns an autoreleased instance of NGLSurface.
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