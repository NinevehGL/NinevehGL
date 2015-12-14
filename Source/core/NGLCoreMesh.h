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
#import "NGLMesh.h"

@class NGLMesh;

/*!
 *					The NGLCoreMesh protocol defines the basic methods for a mesh.
 *
 *					This protocol defines the methods necessary for each OpenGL version dependent part of
 *					a mesh. This could represents the changing the whole graphics pipeline.
 *
 *	@see			NGLMesh
 */
@protocol NGLCoreMesh <NSObject>

@required

/*!
 *					Indicates if the core mesh has the minimum necessary to receive a render call. While
 *					it's not ready no render calls should be made.
 */
@property (nonatomic, readonly) BOOL isReady;

/*!
 *					The percentage of the uploaded data within the range [0.0, 1.0]. The term "upload" is
 *					about the process of submit data to OpenGL, which is called server.
 */
@property (nonatomic, readonly) float loadedData;

/*!
 *					A pointer to the #NGLMesh# class that holds this core instance.
 *
 *	@see			NGLMesh
 */
@property (nonatomic, assign) NGLMesh *parent;

/*!
 *					Initiates the core mesh instance setting a parent #NGLMesh#.
 *
 *					This method initializes a core mesh and sets its #NGLMesh# parent property.
 *
 *	@param			mesh
 *					The #NGLMesh# instance that holds this core mesh instance.
 *
 *	@result			A new initialized instance.
 */
- (id) initWithParent:(NGLMesh *)mesh;

/*!
 *					Constructs the OpenGL Buffers for the mesh. Must be called before any render.
 *
 *					This method constructs the bridge between NinevehGL informations and the OpenGL.
 *
 *					This method should be called every time that occurs a change in the object structure.
 */
- (void) defineBuffers;

/*!
 *					Clean up all the buffers. Must be called to delete the OpenGL buffers.
 *
 *					This method erases all the buffers in this mesh and make it empty again.
 *
 *					This method should be called by the NGLCoreMesh owner before release it.
 */
- (void) clearBuffers;

/*!
 *					Draws the current mesh.
 *
 *					This method is the last to be called before the drawing happens inside the core.
 */
- (void) drawCoreMesh;

- (void) drawTelemetry:(UInt32)telemetry;

@end