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
	UInt32			_identifier;
	UInt32			_startData;
	UInt32			_lengthData;
}

/*!
 *					The identifier of this object.
 */
@property (nonatomic) UInt32 identifier;

/*!
 *					Represents the starting index inside of this surface on the mesh's array of indices.
 */
@property (nonatomic) UInt32 startData;

/*!
 *					Represents the length, in elements, of this surface on the mesh's array of indices.
 */
@property (nonatomic) UInt32 lengthData;

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
- (id) initWithStart:(UInt32)start length:(UInt32)length identifier:(UInt32)newId;

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
+ (id) surfacetWithStart:(UInt32)start length:(UInt32)length identifier:(UInt32)newId;

@end