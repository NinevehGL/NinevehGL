/*
 *	NGLShaderMulti.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 2/18/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLShader.h"
#import "NGLIterator.h"
#import "NGLArray.h"

/*!
 *					Multi/Sub instance of NGLShader.
 *
 *					NGLShaderMulti is a special kind of NGLShader and represents a collection of
 *					multiple shaders. It allows you to create many shaders onto one single mesh. So you
 *					can use many behaviors using the same mesh instance.
 *
 *	@see			NGLShader
 */
@interface NGLShaderMulti : NSObject <NGLShader, NGLIterator, NSFastEnumeration>
{
@private
	NGLArray				*_collection;
}

/*!
 *					Initiates a shaders library based on many #NGLShader# instances.
 *
 *					This method initializes a shader library and puts many shaders into it.
 *
 *	@param			first
 *					The first shaders to be added.
 *
 *	@param			...
 *					A sequence of NGLShader instances separated by comma. This method requires a
 *					<code>nil</code> termination.
 *
 *	@result			A NGLShaderMulti instance.
 *
 *	@see			NGLShader
 */
- (id) initWithShaders:(NGLShader *)first, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 *					Initiates a shaders library based #NGLShader# protocol.
 *
 *					This method will check if the informed object is a simple #NGLShader# or a
 *					NGLShaderMulti and will automatically retain its items.
 *
 *	@param			shaders
 *					An object that conforms with the #NGLShader# protocol.
 *
 *	@result			A NGLShaderMulti instance.
 *
 *	@see			NGLShader
 */
- (id) initWithShadersKind:(id <NGLShader>)shaders;

/*!
 *					Adds a NGLShader instance to this shaders library.
 *
 *					The NGLShader instance will be internally retained.
 *
 *	@param			item
 *					The NGLShader instance to add.
 *
 *	@see			NGLShader
 */
- (void) addShaders:(NGLShader *)item;

/*!
 *					Adds a set of NGLShader instances to this shader library.
 *
 *					Just as the #addShaders:# method, every NGLShader will be internally retained.
 *
 *	@param			multi
 *					A NGLShaderMulti instance.
 *
 *	@param			flag
 *					Specifies if the new items will be copied or just retained.
 *
 *	@see			NGLShader
 */
- (void) addNGLShadersMulti:(NGLShaderMulti *)multi copyItems:(BOOL)flag;

/*!
 *					Checks if a shaders exists in this library.
 *
 *	@param			item
 *					The NGLShader to search for.
 *
 *	@see			NGLShader
 */
- (BOOL) hasShaders:(NGLShader *)item;

/*!
 *					Removes all shaders in this library. All the shaders will receive a release message.
 *
 *					If there is no shader in this library, this method does nothing.
 */
- (void) removeAll;

/*!
 *					Returns a shaders by its identifier.
 *
 *					This method returns a NGLShader. If the identifier was not found, then this method
 *					returns <code>nil</code>. If more than one shader has the same identifier, only the
 *					first occurence will be returned.
 *
 *	@param			identifier
 *					The identifier to search for.
 *
 *	@result			The pointer to the object in this library.
 *
 *	@see			NGLShader
 */
- (NGLShader *) shadersWithIdentifier:(unsigned int)identifier;

/*!
 *					Returns a shaders by its index.
 *
 *					This method returns a #NGLShader# based on its symbolical index. The index is just
 *					a convention defined by the order the item was added to this library. For example,
 *					the first added item is at index 0, the second is at index 1, and so on.
 *
 *					If a item is removed from this library, the array will be reorganized and the items
 *					will be represented by new indices. So use this method carefully.
 *
 *	@param			index
 *					The index of an object. The index is defined by the order it was added.
 *
 *	@result			The item in this library.
 *
 *	@see			NGLShader
 */
- (NGLShader *) shadersAtIndex:(unsigned int)index;

/*!
 *					Returns the number of instances in this library at the moment.
 *
 *	@result			An unsigned int data type.
 */
- (unsigned int) count;

/*!
 *					Returns an autoreleased instance of NGLShaderMulti.
 *
 *					This method creates a shader library with one shaders inside of it.
 *
 *	@param			first
 *					The first shaders to be added.
 *
 *	@result			A NGLShaderMulti autoreleased instance.
 *
 *	@see			NGLShader
 */
+ (id) shadersMultiWithShaders:(NGLShader *)first;

@end