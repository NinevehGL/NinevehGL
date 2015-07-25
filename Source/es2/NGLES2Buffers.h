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

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "NGLRuntime.h"

/*!
 *					Defines if a buffer will be VBO or IBO.
 *
 *					VBO buffers are used to store array of structure and IBOs are used to store
 *					array of indices.
 *
 *	@see			NGLES2Buffers::loadData:size:type:usage:
 *	
 *	@var			NGLES2BuffersTypeIndex
 *					Represents IBO type.
 *	
 *	@var			NGLES2BuffersTypeStructure
 *					Represents VBO type.
 */
typedef enum
{
	NGLES2BuffersTypeIndex		= GL_ELEMENT_ARRAY_BUFFER,
	NGLES2BuffersTypeStructure	= GL_ARRAY_BUFFER,
} NGLES2BuffersType;

/*!
 *					Instructs about the buffer usage.
 *
 *					Buffers can be used by three way:
 *
 *						- Static: Writed once and used many times;
 *						- Stream: Writed many times and used many times;
 *						- Dynamic: Writed once and used just few times.
 *
 *					Only the stream is a mutable storage, the other two are immutable storages.
 *
 *	@see			NGLES2Buffers::loadData:size:type:usage:
 *	
 *	@var			NGLES2BuffersUsageStatic
 *					Represents Static usage.
 *	
 *	@var			NGLES2BuffersUsageStream
 *					Represents Stream usage.
 *	
 *	@var			NGLES2BuffersUsageDynamic
 *					Represents Dynamic usage.
 */
typedef enum
{
	NGLES2BuffersUsageStatic	= GL_STATIC_DRAW,
	NGLES2BuffersUsageStream	= GL_STREAM_DRAW,
	NGLES2BuffersUsageDynamic	= GL_DYNAMIC_DRAW,
} NGLES2BuffersUsage;

/*!
 *					<strong>(Internal only)</strong> Creates, stores and manages a pair of buffer object.
 *
 *					Buffer object is a great OpenGL's feature. It can hold full datas in an optimized
 *					format to be processed in the GPU during the shaders processing. NGLES2Buffers is a
 *					lite and easy way to deal with these buffer objects. This class can easily create,
 *					store and manage the buffers for you.
 *
 *					Besides, NGLES2Buffers is reponsible for binding the pair of buffer. The binding
 *					process prepares the buffers to be used on the next drawing commands.
 */
@interface NGLES2Buffers : NSObject
{
@private
	GLuint					_ibo, _vbo;
}

/*!
 *					Loads a new buffer object inside OpenGL's core.
 *
 *					This method just creates one kind of buffer. You should call this twice to create
 *					a VBO and an IBO. If this method was called twice or more for the same type of buffer
 *					object, it will delete the oldest buffer of the same type.
 *
 *	@param			data
 *					A pointer to the data which will be stored in the buffer.
 *
 *	@param			size
 *					The data size in basic machine units (bytes).
 *
 *	@param			type
 *					The type of data to be loaded, that means, a VBO or an IBO.
 *
 *	@param			usage
 *					The intended usage for this new buffer object.
 */
- (void) loadData:(const void *)data
			 size:(int)size
			 type:(NGLES2BuffersType)type
			usage:(NGLES2BuffersUsage)usage;

/*!
 *					Binds the buffers, making it the current buffer of it's type.
 *
 *					If there is only one kind of buffer on this NGLES2Buffers instance, only that buffer
 *					object will be bounded, ignoring the other one.
 */
- (void) bind;

/*!
 *					Unbinds all buffer objects.
 *
 *					Any buffer object from any type will be unbinded, leaving the buffer object attachments
 *					free.
 */
- (void) unbind;

@end
