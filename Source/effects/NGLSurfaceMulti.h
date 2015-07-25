/*
 *	NGLSurfaceMulti.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 2/11/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLSurface.h"
#import "NGLIterator.h"
#import "NGLArray.h"

/*!
 *					Multi/Sub instance of #NGLSurface#.
 *
 *					NGLSurfaceMulti is a special kind of #NGLSurface# and represents a collection of
 *					multiple surfaces. It allows you to create many surfaces onto one single mesh. So you
 *					can use many shaders behaviors using the same mesh instance.
 *
 *	@see			NGLSurface
 */
@interface NGLSurfaceMulti : NSObject <NGLSurface, NGLIterator, NSFastEnumeration>
{
@private
	NGLArray				*_collection;
}

/*!
 *					Initiates a surface library based on many #NGLSurface# instances.
 *
 *					This method initializes a surface library and puts many surfaces into it.
 *
 *	@param			first
 *					The first surface to be added.
 *
 *	@param			...
 *					A sequence of #NGLSurface# instances separated by comma. This method requires a
 *					<code>nil</code> termination.
 *
 *	@result			A NGLSurfaceMulti instance.
 *
 *	@see			NGLSurface
 */
- (id) initWithSurfaces:(NGLSurface *)first, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 *					Initiates a surface library based #NGLSurface# protocol.
 *
 *					This method will check if the informed object is a simple #NGLSurface# or a
 *					NGLSurfaceMulti and will automatically retain its items.
 *
 *	@param			surface
 *					An object that conforms with the #NGLSurface# protocol.
 *
 *	@result			A NGLSurfaceMulti instance.
 *
 *	@see			NGLSurface
 */
- (id) initWithSurfaceKind:(id <NGLSurface>)surface;

/*!
 *					Adds a #NGLSurface# instance to this surface library.
 *
 *					The #NGLSurface# instance will be internally retained.
 *
 *	@param			item
 *					The #NGLSurface# instance to add.
 *
 *	@see			NGLSurface
 */
- (void) addSurface:(NGLSurface *)item;

/*!
 *					Adds a set of #NGLSurface# instances to this surface library.
 *
 *					Just as the #addSurface:# method, every NGLMaterial will be internally retained.
 *
 *	@param			multi
 *					A NGLSurfaceMulti instance.
 *
 *	@param			flag
 *					Specifies if the new items will be copied or just retained.
 *
 *	@see			NGLSurface
 */
- (void) addNGLSurfaceMulti:(NGLSurfaceMulti *)multi copyItems:(BOOL)flag;

/*!
 *					Checks if a surface exists in this library.
 *
 *	@param			item
 *					The NGLShaders to search for.
 *
 *	@see			NGLSurface
 */
- (BOOL) hasSurface:(NGLSurface *)item;

/*!
 *					Removes all surfaces in this library. All the surfaces will receive a release message.
 *
 *					If there is no surface in this library, this method does nothing.
 */
- (void) removeAll;

/*!
 *					Returns a surface by its identifier.
 *
 *					This method returns a #NGLSurface#. If the identifier was not found, then this method
 *					returns <code>nil</code>. If more than one surface has the same identifier, only the
 *					first occurence will be returned.
 *
 *	@param			identifier
 *					The identifier to search for.
 *
 *	@result			The pointer to the object in this library.
 *
 *	@see			NGLSurface
 */
- (NGLSurface *) surfaceWithIdentifier:(unsigned int)identifier;

/*!
 *					Returns a surface by its index.
 *
 *					This method returns a #NGLSurface# based on its symbolical index. The index is just
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
 *	@see			NGLSurface
 */
- (NGLSurface *) surfaceAtIndex:(unsigned int)index;

/*!
 *					Returns the number of instances in this library at the moment.
 *
 *	@result			An unsigned int data type.
 */
- (unsigned int) count;

/*!
 *					Returns an autorelease instance of NGLSurfaceMulti.
 *
 *					This method creates a surface library with one surface inside of it.
 *
 *	@param			first
 *					The first surface to be added.
 *
 *	@result			A NGLSurfaceMulti autoreleased instance.
 *
 *	@see			NGLSurface
 */
+ (id) surfaceMultiWithSurface:(NGLSurface *)first;

@end