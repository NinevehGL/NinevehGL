/*
 *	NGLMesh.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 11/6/10.
 *	Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLGlobal.h"
#import "NGLCoreTimer.h"
#import "NGLCoreEngine.h"
#import "NGLCoreMesh.h"
#import "NGLMatrix.h"
#import "NGLObject3D.h"
#import "NGLMeshElements.h"
#import "NGLMaterialMulti.h"
#import "NGLSurfaceMulti.h"
#import "NGLShadersMulti.h"
#import "NGLCamera.h"
#import "NGLGestures.h"
#import "NGLArray.h"

@class NGLMesh, NGLMeshElements, NGLCamera;

/*!
 *					It's the parsing object. It can hold the progress information, actual status and the
 *					referenced NGLMesh.
 *
 *					The progress property is the same as progress in UIProgressView, that means, it's in
 *					the range [0.0, 1.0].
 *
 *	@var			NGLParsing::progress
 *					Represents progress percentage in the range [0.0, 1.0].
 *
 *	@var			NGLParsing::isComplete
 *					A BOOL data type indicating if the parse process is complete.
 *
 *	@var			NGLParsing::isFailed
 *					A BOOL data type indicating if the parse process has or had failed.
 *
 *	@var			NGLParsing::mesh
 *					A reference to the NGLMesh instance that started the parse process.
 */
typedef struct
{
	float progress;
	BOOL isComplete;
	BOOL isFailed;
	NGL_ARC_ASSIGN NGLMesh *mesh;
} NGLParsing;

/*!
 *					The NGLMeshDelegate protocol defines the basic methods for an object register itself
 *					as observer to the loading process.
 *
 *					The observer can receive one notification about the start of the process, can receive
 *					many notifications about the progress, one notification about the end of the progress
 *					and one notification in case of errors.
 *
 *					For a UI convenience (UIKit), all the notifications will be delivered as asynchronous
 *					methods called in the main thread.
 *
 *					<b>IMPORTANT</b>: The callbacks messages are delivered asynchronously on the MAIN
 *					THREAD for your convenience. The progress notifications is generated respecting the
 *					NinevehGL FPS, so you will receive this notification in the same frequency as the
 *					application's FPS. Changing the FPS will immediately affect the interval of the
 *					progress notifications.
 *
 *					The notifications are about the loading process, which has two phases. There is no
 *					real difference between the notifications/messages of these phases. But NinevehGL
 *					follows a rule for these phases, the phases are:
 *
 *						- Parse Phase (80%): The first 80% of the process is about parsing the 3D file;
 *						- Upload Phase (20%): The last 20% of the process is about the uploading.
 *
 *					While the process is under 80% the mesh can't be rendered. Even if you try to make a
 *					render nothing will happen, the render call will be ignored. After the 80% the mesh can
 *					be rendered on the screen, however it is complete yet, you will see only some parts of
 *					the object (polygons).
 *
 *					For example, if you start loading a big city and place it in the render loop, during
 *					the first 80% of the loading process you will see nothing and after the 80% you can see
 *					some building and they will keep appearing until the loading process (upload phase)
 *					is done.
 *
 *					If you don't want to show the object while it's loading but want to place it in the
 *					render loop since the very begining, think about to set the #NGLMesh:visible# property
 *					to NO on the #meshLoadingWillStart:# callback and change it again to YES on the
 *					#meshLoadingDidFinish:# callback.
 *
 *					None of the following methods are mandatory.
 */
@protocol NGLMeshDelegate <NSObject>

@optional

/*!
 *					This is the very first method. This method is called even before the file be loaded in
 *					the memory.
 *
 *	@param			parsing
 *					The parsing object.
 *
 *	@see			NGLParsing
 */
- (void) meshLoadingWillStart:(NGLParsing)parsing;

/*!
 *					This method follows the NinevehGL FPS, that means, it's called with the same
 *					frequency/interval as the NinevehGL render.
 *
 *					This method updates the <code>progress</code> property in the parsing object.
 *					The progress' value is the same as the <code>progress</code> property in the
 *					UIProgressView, a float number with the range [0.0, 1.0].
 *
 *	@param			parsing
 *					The parsing object.
 *
 *	@see			NGLParsing
 */
- (void) meshLoadingProgress:(NGLParsing)parsing;

/*!
 *					This is the very last method. This method is called when the loading process is done.
 *
 *	@param			parsing
 *					The parsing object.
 *
 *	@see			NGLParsing
 */
- (void) meshLoadingDidFinish:(NGLParsing)parsing;

/*!
 *					This method can be called at any time. Even when it's called, all the other
 *					notifications will still happening.
 *
 *	@param			parsing
 *					The parsing object.
 *
 *	@see			NGLParsing
 */
- (void) meshLoadingError:(NGLParsing)parsing;

/*!
 *					This method is called when an explicity call to #compileCoreMesh# is made is finished.
 *					When this method is called, the mesh is ready to render again.
 *
 *	@param			parsing
 *					The parsing object.
 *
 *	@see			NGLParsing
 */
- (void) meshCompilingDidFinish:(NGLParsing)parsing;

@end

#pragma mark -
#pragma mark Mesh Keys
#pragma mark -
//**********************************************************************************************************
//
//	Mesh Keys
//
//**********************************************************************************************************

/*!
 *					This key represents if the final mesh will be or not centralized. The auto centralize
 *					process changes all the vertex positions placing the object's center on origin of the
 *					world {0.0 ,0.0 ,0.0}.
 *
 *					The data type for this key is a BOOL.
 *
 *	@see			NGLMesh::initWithFile:settings:delegate:
 *	@see			NGLMesh::loadFile:file:settings:
 */
NGL_API NSString *const kNGLMeshKeyCentralize;

/*!
 *					This key represents if the final mesh will have or not its vertices positions
 *					normalized to a range. In other words, this feature will stretch or shrink the whole
 *					original mesh, assuming a maximum value.
 *
 *					You must specify a number (NSNumber or NSString) that represents the normalization.
 *					For example, if you specify 1.0 the mesh will be bound into the center of a cube with
 *					dimensions 1.0 x 1.0 x 1.0.
 *
 *					The data type for this key is a float (NSNumber or NSString).
 *
 *	@see			NGLMesh::initWithFile:settings:delegate:
 *	@see			NGLMesh::loadFile:file:settings:
 */
NGL_API NSString *const kNGLMeshKeyNormalize;

/*!
 *					This key represents if the NinevehGL Parse API can make use of the binary cached file
 *					or not. The NinevehGL Binary file is automatically generated every time you parse a
 *					mesh from a 3D file. It's a parsed true copy from the original, using it can be almost
 *					85 times faster than parsing the original one.
 *
 *					For more information about the NinevehGL Binary file consult the official page:
 *					<a href="http://nineveh.gl/binary" target="_blank">http://nineveh.gl/binary</a>
 *
 *					The data type for this key is a BOOL.
 *
 *	@see			NGLMesh::initWithFile:settings:delegate:
 *	@see			NGLMesh::loadFile:file:settings:
 */
NGL_API NSString *const kNGLMeshKeyOriginal;

#pragma mark -
#pragma mark Mesh Values
#pragma mark -
//**********************************************************************************************************
//
//	Mesh Values
//
//**********************************************************************************************************

/*!
 *					Value to the #kNGLMeshKeyCentralize#.
 *
 *					With this value the mesh will be centralized at the origin of the world {0.0 ,0.0 ,0.0}.
 */
NGL_API NSString *const kNGLMeshCentralizeYes;

/*!
 *					Value to the #kNGLMeshKeyOriginal#.
 *
 *					With this value any cached file will be ignored and the original file will be loaded
 *					and parsed. This process can replace previous files in the cache.
 */
NGL_API NSString *const kNGLMeshOriginalYes;

/*!
 *					The base class to every mesh in NinevehGL.
 *
 *					This is the mesh class. It's your point of access and probably will be the class
 *					you will have more contact with. It can be called at every frame to produce object
 *					transformations. It holds the materials, shaders and surfaces instances to work with
 *					a specific mesh. It manages the parsing process and controls all the meshes of the
 *					view and application. In fact, this is the most important NinevehGL class to your work.
 *
 *					Delving technically inside its structure:
 *
 *					This is an abstract class, which means that alone it does nothing.
 *					Here is the basic structure to work with any OpenGL programmable pipeline.
 *					This class set some rules to work with programmable pipeline, it:
 *
 *						- Always work with "array of structures" and "array of indices";
 *						- Prepares the elements which will be dynamicaly set, like vertex position,
 *							vertex normal, vertex texture coordinate, vertex tangent and vertex bitangent.
 *						- Constructs the necessary matrices at the render time.
 *						- Updates the meshes when a global change happens in the OpenGL's core.
 *
 *					Besides, this class extends the base #NGLObject3D#, so it's the bridge to make any
 *					3D transformations. Another important NGLMesh's responsability is to store the
 *					materials, custom shaders and surfaces. These three APIs let you do almost anything
 *					to customize the shaders behaviors, using all the power of the OpenGL programmable
 *					pipeline.
 *
 *					NGLMesh offers a simple way to instruct the NinevehGL if this mesh could be rendered
 *					or not. With the <code>#visible#</code> property you can skip the entire rendering
 *					process to this mesh, even avoiding the vertex shader processing.
 *
 *					One of the most important NGLMesh's features is that this class is the point of
 *					access to the NinevehGL's Parse API. The Parse API can easily load and parse 3D files
 *					and all its related shader behaviors. All that you need to do is to export your
 *					3D scene from a 3D software, place the file (or files) in your project and pass the
 *					file's name/path to one of the NGLMesh's constructor methods.
 *
 *					This actual Parse API is prepared to work with:
 *
 *						- WaveFront Object Files (.obj);
 *						- COLLADA Object Files (.dae);
 *						- NinevehGL Binary Files (.ngl).
 *
 *					Any copy (simple copy or copyInstance) of NGLMesh will be made asynchronous (when using
 *					multithreading) and after the loading process finishes. So, you can make a copy of a
 *					NGLMesh even if it's loading a 3D file. The structure will be copied into the new
 *					NGLMesh after the loading, respecting the copy type.
 *
 *					The loading process is one of the most expensive tasks in NinevehGL. If you are using
 *					NinevehGL with multithreading mode turned ON, the loading process task will use two
 *					distincts background threads:
 *
 *						- A thread to load and parse the 3D file;
 *						- A thread to upload the parsed data to the OpenGL core (CoreMesh).
 *
 *					Working on file represents 80% of the loading process and the upload represents 20% of
 *					the entire process. So if you are monitoring the process, you will see that the mesh
 *					can't be rendered until 80%. However, after the 80% the mesh can be rendered but it's
 *					not completed yet.
 *
 *					If running on multithreading mode, NinevehGL can generate statuses callbacks for the
 *					process, in order to receive the messages a class must conforms to the
 *					#NGLMeshDelegate# protocol.
 *
 *	@see			NGLMeshDelegate
 */
@interface NGLMesh : NGLObject3D <NGLCoreTimer, NGLGestureRecognizer>
{
@private
	// Matrices
	NGLmat4					_mvpMatrix;
	NGLmat4					_mIMatrix;
	NGLmat4					_mvIMatrix;
	
	// Structure
	unsigned int			*_indices;
	float					*_structures;
	unsigned int			_iCount;
	unsigned int			_sCount;
	unsigned int			_stride;
	NGLMeshElements			*_meshElements;
	
	// Properties
	id <NGLMaterial>		_material;
	id <NGLShaders>			_shaders;
	id <NGLSurface>			_surface;
	BOOL					_visible;
	BOOL					_touchable;
	
	// Importing
	id <NGLCoreMesh>		_coreMesh;
	id						_parser;
	Class					_parserClass;
	NSString				*_fileNamed;
	NSDictionary			*_fileSettings;
	
	// Delegate
	id <NGLMeshDelegate>	_delegate;
	Class					_delegateClass;
	unsigned int			_inspector;
	
	// Helpers
	unsigned int			_slot;
	NGLParsing				_parsing;
	BOOL					_isParsing;
	BOOL					_isCompiling;
	
	// Gestures
	NGLArray				*_gestures;
}

/*!
 *					The final MODEL_VIEW_PROJECTION matrix.
 */
@property (nonatomic, readonly) NGLmat4 *matrixMVP;

/*!
 *					The final orthogonal MODEL_INVERSE matrix (doesn't include the scale).
 */
@property (nonatomic, readonly) NGLmat4 *matrixMInverse;

/*!
 *					The final orthogonal MODEL_VIEW_INVERSE matrix (doesn't include the scale).
 */
@property (nonatomic, readonly) NGLmat4 *matrixMVInverse;

/*!
 *					The delegate must conform to #NGLMeshDelegate# protocol. If there is a loading process
 *					in progress this call will do nothing.
 *
 *	@see			NGLMeshDelegate
 */
@property (nonatomic, assign) id <NGLMeshDelegate> delegate;

/*!
 *					The parsing information. This property will return NULL if there is no parsing under
 *					processing at this time.
 */
@property (nonatomic, readonly) NGLParsing parsing;

/*!
 *					The array of indices's length.
 */
@property (nonatomic, readonly) unsigned int indicesCount;

/*!
 *					The array of structures's length.
 */
@property (nonatomic, readonly) unsigned int structuresCount;

/*!
 *					The array of structures's stride in computer basic units (bits).
 */
@property (nonatomic, readonly) unsigned int stride;

/*!
 *					Pointer to the array of indices containing the instructions to work with OpenGL
 *					programmable pipeline.
 */
@property (nonatomic, readonly) unsigned int *indices;

/*!
 *					Pointer to the array of structures containing all the information about this
 *					mesh' structure.
 */
@property (nonatomic, readonly) float *structures;

/*!
 *					Pointer to the elements of this mesh.
 *
 *	@see			NGLMeshElements
 */
@property (nonatomic, readonly) NGLMeshElements *meshElements;

/*!
 *					This property can be set to any #NGLMaterial#. This includes the basic material
 *					#NGLMaterial# and the multi/sub material #NGLMaterialMulti#.
 *					To use Multi/Sub materials you should set at least one surface. Otherwise, the
 *					default clay material will be used in place.
 *
 *					Besides, if no material was set (or set to nil) the default clay material will be used.
 *
 *	@see			NGLMaterial
 *	@see			NGLMaterialMulti
 */
@property (nonatomic, retain) id <NGLMaterial> material;

/*!
 *					This property can be set to any NGLShaders. This include the basic shaders
 *					NGLShaders and the multi/sub shaders #NGLShadersMulti#.
 *					To use Multi/Sub materials you should set at least one surface. Otherwise, no custom
 *					shaders will be used in place.
 *
 *					Besides, if no custom shaders was set (or set to nil) this mesh will work only with
 *					the NinevehGL Shaders.
 *
 *	@see			NGLShaders
 *	@see			NGLShadersMulti
 */
@property (nonatomic, retain) id <NGLShaders> shaders;

/*!
 *					This property can be set to any #NGLSurface#. This include the basic surface
 *					#NGLSurface# and the multi/sub surface #NGLSurfaceMulti#.
 *
 *					Besides, if no surface was set (or set to nil) no surface information will be used
 *					in place.
 *
 *	@see			NGLSurface
 *	@see			NGLSurfaceMulti	
 */
@property (nonatomic, retain) id <NGLSurface> surface;

/*!
 *					Indicates whether this mesh will be visible or not to the render process. If this
 *					is set to NO, all the render steps will be skipped to this mesh.
 *
 *					The default value is YES.
 */
@property (nonatomic, getter = isVisible) BOOL visible;

/*!
 *					Indicates whether this mesh will accept touches or not. If this is set to NO, 
 *					any kind of touch will be recognized by this object.
 *
 *					The default value is YES.
 */
@property (nonatomic, getter = isTouchable) BOOL touchable;

/*!
 *					<strong>(Internal only)</strong> You should not call this one manually.
 *
 *					Defines the internal file's name or path. If there is a loading process in progress
 *					this call will do nothing.
 */
@property (nonatomic, copy) NSString *fileNamed;

/*!
 *					<strong>(Internal only)</strong> You should not call this one manually.
 *
 *					Defines the internal file settings for the loading process. If there is a loading
 *					process in progress this call will do nothing.
 */
@property (nonatomic, copy) NSDictionary *fileSettings;

/*!
 *					Initiates the mesh from any supported 3D files with some properties.
 *
 *					This method automatically tries to recognize the 3D file based on its extension and
 *					choose the appropriated parsing process. The current version can work with:
 *						- WaveFront OBJ file (.obj);
 *						- COLLADA file (.dae);
 *						- NinevehGL Binary file (.ngl).
 *
 *					The string used for the name and the dictionary used for settings will be internally
 *					copied, as shows the #fileNamed# and #fileSettings# properties.
 *
 *	@param			named
 *					In NinevehGL the "named" parameter is always related to the NinevehGL Path API, so you
 *					can inform the only the file's name or full path. The full path is related to the file
 *					system. If only the file's name is informed, NinevehGL will search for the file at the
 *					global path.
 *
 *	@param			dict
 *					A NSDictionary containing the keys and values to the preset.
 *
 *	@param			target
 *					The delegate target, it must conforms to NGLMeshDelegate protocol.
 *
 *	@result			A new initialized instance.
 *
 *	@see			kNGLMeshKeyCentralize
 *	@see			kNGLMeshKeyNormalize
 *	@see			kNGLMeshKeyOriginal
 *	@see			NGLMeshDelegate
 */
- (id) initWithFile:(NSString *)named settings:(NSDictionary *)dict delegate:(id <NGLMeshDelegate>)target;

/*!
 *					Loads a new mesh based on a file type with properties.
 *
 *					This method loads a new mesh with all properties and structures from a 3D file.
 *					Any older mesh's information will be replaced by the new mesh.
 *					The file will be searched using the NinevehGL Path API.
 *	
 *					If your application is running NinevehGL on multithreading mode, this method will
 *					ignore new calls while the last loading is happening.
 *
 *					The string used for the name and the dictionary used for settings will be internally
 *					copied, as shows the #fileNamed# and #fileSettings# properties.
 *
 *	@param			named
 *					In NinevehGL the "named" parameter is always related to the NinevehGL Path API, so you
 *					can inform the only the file's name or full path. The full path is related to the file
 *					system. If only the file's name is informed, NinevehGL will search for the file at the
 *					global path.
 *
 *	@param			dict
 *					A NSDictionary containing the keys and values to the preset.
 *	
 *	@param			type
 *					The file type. It can be any of the NGL3DFileType values.
 *
 *	@see			kNGLMeshKeyCentralize
 *	@see			kNGLMeshKeyNormalize
 *	@see			kNGLMeshKeyOriginal
 */
- (void) loadFile:(NSString *)named settings:(NSDictionary *)dict type:(NGL3DFileType)type;

//- (void) loadMeshManually:(NSString *)named;
//- (void) insertData:(float *)data count:(unsigned int)count type:(NGLComponent)component;
//- (void) insertFaces:(unsigned int *)faces count:(unsigned int)count;

/*!
 *					Stops the loading process. Cancelling the process is not immediately, it can
 *					take few more cycles to release all the allocated memory.
 *
 *					If you are using NinevehGL with multithreading, remember that the load will retain
 *					this mesh to work on a background thread. So, if you want to release and dealloc
 *					this mesh before the load finish you should call this method.
 */
- (void) cancelLoading;

/*!
 *					Compiles the final mesh and constructs the OpenGL's shaders. This method starts an
 *					asynchronous task and it may take a while to complete.
 *
 *					The mesh data (array of structure and array of indices) will be reloaded from the
 *					local binary cache. The loading will run as any other mesh loading: using two other
 *					threads (if the application is in multithreading mode).
 *
 *					This method should be called after any change in materials, shaders or surfaces.
 *					Calls to this method during another Loading Process will be ignored.
 */
- (void) compileCoreMesh;

/*!
 *					<strong>(Internal only)</strong> You should not set this property manually.
 *
 *					Starts the render process with a specific camera.
 *
 *	@param			camera
 *					The camera that is capturing this mesh.
 */
- (void) drawMeshWithCamera:(NGLCamera *)camera;

- (void) drawMeshWithCamera:(NGLCamera *)camera usingTelemetry:(unsigned int)telemetry;

/*!
 *					Sets the array of indices.
 *
 *					Use this method to create the array of indices and set its length.
 *
 *	@param			newIndices
 *					Pointer to the array of indices. All the memory pointed by this parameter will be
 *					copied internally to avoid inconsistences and weak references.
 *
 *	@param			newCount
 *					The array of indice's length. As the array of indices is a C array, you need to specify
 *					its length.
 */
- (void) setIndices:(unsigned int *)newIndices count:(unsigned int)newCount;

/*!
 *					Sets the array of structures.
 *
 *					Use this method to create the array of structures, set its length and its stride.
 *
 *	@param			newStructures
 *					Pointer to the array of structures. All the memory pointed by this parameter
 *					will be copied internally to avoid inconsistences and weak references.
 *
 *	@param			newCount
 *					The array of structures's length. As array of indices is a C array, you need to
 *					specify its length.
 *
 *	@param			newStride
 *					The array of structures's stride. This stride must be in elements, not basic
 *					machine units.
 */
- (void) setStructures:(float *)newStructures count:(unsigned int)newCount stride:(unsigned int)newStride;

/*!
 *					<strong>(Internal only)</strong> You should not call this one manually.
 *
 *					This method affects all NGLMesh in the memory. It'll update all core meshes.
 */
+ (void) updateAllMeshes;

/*!
 *					<strong>(Internal only)</strong> You should not call this one manually.
 *
 *					This method affects all NGLMesh in the memory. It'll clean up all core meshes.
 */
+ (void) emptyAllMeshes;

/*!
 *					<strong>(Internal only)</strong> You should not call this one manually.
 *
 *					Gets all the meshes currently in the application's memory.
 *
 *	@result			A NSArray containing all the meshes.
 */
+ (NSArray *) allMeshes;

@end