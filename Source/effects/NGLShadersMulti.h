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
#import "NGLShaders.h"
#import "NGLIterator.h"
#import "NGLArray.h"

/*!
 *					Multi/Sub instance of NGLShaders.
 *
 *					NGLShadersMulti is a special kind of NGLShaders and represents a collection of
 *					multiple shaders. It allows you to create many shaders onto one single mesh. So you
 *					can use many behaviors using the same mesh instance.
 *
 *	@see			NGLShaders
 */
@interface NGLShadersMulti : NSObject <NGLShaders, NGLIterator, NSFastEnumeration>
{
@private
	NGLArray				*_collection;
}

/*!
 *					Initiates a shaders library based on many #NGLShaders# instances.
 *
 *					This method initializes a shader library and puts many shaders into it.
 *
 *	@param			first
 *					The first shaders to be added.
 *
 *	@param			...
 *					A sequence of NGLShaders instances separated by comma. This method requires a
 *					<code>nil</code> termination.
 *
 *	@result			A NGLShadersMulti instance.
 *
 *	@see			NGLShaders
 */
- (id) initWithShaders:(NGLShaders *)first, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 *					Initiates a shaders library based #NGLShaders# protocol.
 *
 *					This method will check if the informed object is a simple #NGLShaders# or a
 *					NGLShadersMulti and will automatically retain its items.
 *
 *	@param			shaders
 *					An object that conforms with the #NGLShaders# protocol.
 *
 *	@result			A NGLShadersMulti instance.
 *
 *	@see			NGLShaders
 */
- (id) initWithShadersKind:(id <NGLShaders>)shaders;

/*!
 *					Adds a NGLShaders instance to this shaders library.
 *
 *					The NGLShaders instance will be internally retained.
 *
 *	@param			item
 *					The NGLShaders instance to add.
 *
 *	@see			NGLShaders
 */
- (void) addShaders:(NGLShaders *)item;

/*!
 *					Adds a set of NGLShaders instances to this shader library.
 *
 *					Just as the #addShaders:# method, every NGLShaders will be internally retained.
 *
 *	@param			multi
 *					A NGLShadersMulti instance.
 *
 *	@param			flag
 *					Specifies if the new items will be copied or just retained.
 *
 *	@see			NGLShaders
 */
- (void) addNGLShadersMulti:(NGLShadersMulti *)multi copyItems:(BOOL)flag;

/*!
 *					Checks if a shaders exists in this library.
 *
 *	@param			item
 *					The NGLShaders to search for.
 *
 *	@see			NGLShaders
 */
- (BOOL) hasShaders:(NGLShaders *)item;

/*!
 *					Removes all shaders in this library. All the shaders will receive a release message.
 *
 *					If there is no shader in this library, this method does nothing.
 */
- (void) removeAll;

/*!
 *					Returns a shaders by its identifier.
 *
 *					This method returns a NGLShaders. If the identifier was not found, then this method
 *					returns <code>nil</code>. If more than one shader has the same identifier, only the
 *					first occurence will be returned.
 *
 *	@param			identifier
 *					The identifier to search for.
 *
 *	@result			The pointer to the object in this library.
 *
 *	@see			NGLShaders
 */
- (NGLShaders *) shadersWithIdentifier:(unsigned int)identifier;

/*!
 *					Returns a shaders by its index.
 *
 *					This method returns a #NGLShaders# based on its symbolical index. The index is just
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
 *	@see			NGLShaders
 */
- (NGLShaders *) shadersAtIndex:(unsigned int)index;

/*!
 *					Returns the number of instances in this library at the moment.
 *
 *	@result			An unsigned int data type.
 */
- (unsigned int) count;

/*!
 *					Returns an autorelease instance of NGLShadersMulti.
 *
 *					This method creates a shader library with one shaders inside of it.
 *
 *	@param			first
 *					The first shaders to be added.
 *
 *	@result			A NGLShadersMulti autoreleased instance.
 *
 *	@see			NGLShaders
 */
+ (id) shadersMultiWithShaders:(NGLShaders *)first;

@end