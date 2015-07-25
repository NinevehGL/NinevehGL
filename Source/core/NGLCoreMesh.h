/*
 *	NGLCoreMesh.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 2/22/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
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

- (void) drawTelemetry:(unsigned int)telemetry;

@end