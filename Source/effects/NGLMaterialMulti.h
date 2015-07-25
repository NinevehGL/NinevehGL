/*
 *	NGLMaterialMulti.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/16/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLMaterial.h"
#import "NGLIterator.h"
#import "NGLArray.h"

/*!
 *					Multi/Sub instance of #NGLMaterial#.
 *
 *					NGLMaterialMulti is a special kind of #NGLMaterial# and represents a collection of
 *					multiple materials. It allows you to create many materials onto one single mesh.
 *					So you can use many shaders behaviors using the same mesh instance.
 *
 *	@see			NGLMaterial
 */
@interface NGLMaterialMulti : NSObject <NGLMaterial, NGLIterator, NSFastEnumeration>
{
@private
	NGLArray				*_collection;
}

/*!
 *					Initiates a material library based on many #NGLMaterial# instances.
 *
 *					This method initializes a material library and puts many materials into it.
 *
 *	@param			first
 *					The first material to be added.
 *
 *	@param			...
 *					A sequence of #NGLMaterial# instances separated by commas. This method must end with
 *					a <code>nil</code> element.
 *
 *	@result			A NGLMaterialMulti instance.
 *
 *	@see			NGLMaterial
 */
- (id) initWithMaterials:(NGLMaterial *)first, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 *					Initiates a material library based #NGLMaterial# protocol.
 *
 *					This method will check if the informed object is a simple #NGLMaterial# or a
 *					NGLMaterialMulti and will automatically retain its items.
 *
 *	@param			material
 *					An object that conforms with the #NGLMaterial# protocol.
 *
 *	@result			A NGLMaterialMulti instance.
 *
 *	@see			NGLMaterial
 */
- (id) initWithMaterialKind:(id <NGLMaterial>)material;

/*!
 *					Adds a #NGLMaterial# instance to this material library.
 *
 *					The #NGLMaterial# instance will be internally retained.
 *
 *	@param			item
 *					The #NGLMaterial# instance to add.
 *
 *	@see			NGLMaterial
 */
- (void) addMaterial:(NGLMaterial *)item;

/*!
 *					Adds a set of #NGLMaterial# instances to this material library.
 *
 *					Just as the #addMaterial:# method, every NGLMaterial will be internally retained.
 *
 *	@param			multi
 *					A NGLMaterialMulti instance.
 *
 *	@param			flag
 *					Specifies if the new items will be copied or just retained.
 *
 *	@see			NGLMaterial
 */
- (void) addNGLMaterialMulti:(NGLMaterialMulti *)multi copyItems:(BOOL)flag;

/*!
 *					Checks if a material exists in this library.
 *
 *	@param			item
 *					The NGLMaterial to search for.
 *
 *	@see			NGLMaterial
 */
- (BOOL) hasMaterial:(NGLMaterial *)item;

/*!
 *					Removes all materials in this library. All the materials will receive a release message.
 *
 *					If there is no material in this library, this method does nothing.
 */
- (void) removeAll;

/*!
 *					Returns a material by its name.
 *
 *					This method returns a #NGLMaterial#. If the identifier was not found, then this method
 *					returns <code>nil</code>. If more than one material has the same name, only the first
 *					occurence will be returned.
 *
 *	@param			name
 *					A NSString containing the material's name to search for.
 *
 *	@result			The pointer to the object in this library.
 *
 *	@see			NGLMaterial
 */
- (NGLMaterial *) materialWithName:(NSString *)name;

/*!
 *					Returns a material by its identifier.
 *
 *					This method returns a #NGLMaterial#. If the identifier was not found, then this method
 *					returns <code>nil</code>. If more than one material has the same identifier, only the
 *					first occurence will be returned.
 *
 *	@param			identifier
 *					The identifier to search for.
 *
 *	@result			The pointer to the object in this library.
 *
 *	@see			NGLMaterial
 */
- (NGLMaterial *) materialWithIdentifier:(unsigned int)identifier;

/*!
 *					Returns a material by its index.
 *
 *					This method returns a #NGLMaterial# based on its symbolical index. The index is just
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
 *	@see			NGLMaterial
 */
- (NGLMaterial *) materialAtIndex:(unsigned int)index;

/*!
 *					Returns the number of instances in this library at the moment.
 *
 *	@result			An unsigned int data type.
 */
- (unsigned int) count;

/*!
 *					Returns an autorelease instance of NGLMaterialMulti.
 *
 *					This method creates a material library with one material inside of it.
 *
 *	@param			first
 *					The first material to be added.
 *
 *	@result			A NGLMaterialMulti autoreleased instance.
 *
 *	@see			NGLMaterial
 */
+ (id) materialMultiWithMaterial:(NGLMaterial *)first;

@end