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

#import <objc/message.h>

#import "NGLMesh.h"
#import "NGLThread.h"
#import "NGLTimer.h"

// Parsers
#import "NGLParserNGL.h"
#import "NGLParserOBJ.h"
#import "NGLParserDAE.h"

// OpenGL ES 2.x
#import "NGLES2Mesh.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Errors
//**************************************************
//	Errors
//**************************************************

static NSString *const MSH_ERROR_HEADER = @"Error while processing NGLMesh.";

static NSString *const MSH_ERROR_DATA_TYPE = @"The NGLMesh settings must be a NSString or a NSNumber.\n\
You are passing the argument:%@, which is not a NSString nor a NSNumber.";

#pragma mark -
#pragma mark Keys
//**************************************************
//	Keys
//**************************************************

NSString *const kNGLMeshKeyCentralize = @"autoCentralize";
NSString *const kNGLMeshKeyNormalize = @"autoNormalize";
NSString *const kNGLMeshKeyOriginal = @"useOriginal";

NSString *const kNGLMeshCentralizeYes = @"autoCentralizeYes";
NSString *const kNGLMeshOriginalYes = @"useOriginalYes";

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

// Global thread slots to the loading.
static unsigned int *_slots = NULL;

// Global pointer library to the meshes.
static NGLArray *_meshes;

// Binary delegate check.
typedef enum
{
	NGLMeshNone			= 0x00,
	NGLMeshWillStart	= 0x01,
	NGLMeshProgress		= 0x02,
	NGLMeshDidFinish	= 0x04,
	NGLMeshError		= 0x08,
	NGLMeshCompiled		= 0x10,
} NGLMeshInspector;


#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NGL3DFileType fileTypeForFile(NSString *fileNamed)
{
	NGL3DFileType type = NGL3DFileTypeNone;
	
	// Retrieves the file's type, based on the file's name.
	if ([fileNamed rangeOfString:@".dae" options:NSCaseInsensitiveSearch].length > 0)
	{
		type = NGL3DFileTypeDAE;
	}
	else if ([fileNamed rangeOfString:@".obj" options:NSCaseInsensitiveSearch].length > 0)
	{
		type = NGL3DFileTypeOBJ;
	}
	else if ([fileNamed rangeOfString:@".ngl" options:NSCaseInsensitiveSearch].length > 0)
	{
		type = NGL3DFileTypeNGL;
	}
	
	return type;
}

// Choose the best thread slot at this time. The best thread will be the one with less pending job.
static unsigned int parseSlot(void)
{
	int i;
	unsigned int min, index;
	
	// Initialize the slots once, setting all items to 0.
	if (_slots == NULL)
	{
		_slots = calloc(NGL_PARSE_THREADS, NGL_SIZE_UINT);
	}
	
	// Searches for the thread index with less work on it.
	for (i = NGL_PARSE_THREADS - 1, min = 0, index = 0; i >= 0; --i)
	{
		if (min >= _slots[i])
		{
			min = _slots[i];
			index = i;
		}
	}
	
	// Sums one on the selected slot.
	_slots[index] += 1;
	
	return ++index;
}

// Frees one number in a specific slot.
static void parseFreeSlot(unsigned int slot)
{
	--slot;
	
	if (slot < NGL_PARSE_THREADS)
	{
		_slots[slot] -= 1;
	}
}

// Recreates the buffers. This method sends a synchronous task to the core mesh thread.
static void fillCoreMesh(id <NGLCoreMesh> coreMesh)
{
	if (coreMesh != nil)
	{
		// Defining the buffers for the core mesh is made synchronously on a parallel thread.
		// By doing this, the upload will not affect the render cycle.
		nglThreadPerformSync(kNGLThreadHelper, @selector(defineBuffers), coreMesh);
	}
}

// Clears all the buffers from core mesh. This method sends a synchronous task to the core mesh thread.
static void emptyCoreMesh(id <NGLCoreMesh> coreMesh)
{
	if (coreMesh != nil)
	{
		// The clean up is made on the render thread to avoid OpenGL of using a released object.
		nglThreadPerformSync(kNGLThreadRender, @selector(clearBuffers), coreMesh);
	}
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLMesh()

// Initializes a new instance.
- (void) initialize;

// Recreates the core mesh.
- (void) updateCoreMesh;

// Deletes the current current core mesh.
- (void) deleteCoreMesh;

// Defines the bounding box based on the current mesh's structure.
- (void) defineBoundingBox;

// Defines the delegate inspector, an instruction to the loading call backs.
- (void) defineDelegate;

// Constructs the mesh based on a NGLParserMesh model.
- (void) defineMeshFromParser;

// Defines the parser settings.
- (void) defineParserSettings:(NGLParserMesh *)parser;

// Sends notifications to the delegate target.
- (void) parserNotification:(NGLMeshInspector)action;

// <THREADED> This method runs asynchronous on other thread(s).
// Loads any supported kind of 3D files.
- (void) loadFile;

// <THREADED> This method runs asynchronous on other thread(s).
// Copies this mesh asynchronously to make sure the load was completed.
- (void) makeCopyTo:(id)aCopy shared:(BOOL)isShared;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLMesh

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize parsing = _parsing, indices = _indices, structures = _structures, indicesCount = _iCount,
			structuresCount = _sCount, stride = _stride, meshElements = _meshElements,
			material = _material, surface = _surface, shaders = _shaders, visible = _visible,
			touchable = _touchable, gestureRecognizers = _gestures;

@dynamic matrixMVP, matrixMInverse, matrixMVInverse, delegate, fileNamed, fileSettings;

- (NGLmat4 *) matrixMVP
{
	return &_mvpMatrix;
}

- (NGLmat4 *) matrixMInverse
{
	return &_mIMatrix;
}

- (NGLmat4 *) matrixMVInverse
{
	return &_mvIMatrix;
}

- (id <NGLMeshDelegate>) delegate { return _delegate; }
- (void) setDelegate:(id<NGLMeshDelegate>)value
{
	// Avoids changes during a loading process.
	if (!_isParsing)
	{
		_delegate = value;
		_delegateClass = [_delegate class];
		
		[self defineDelegate];
	}
}

- (NSString *) fileNamed { return _fileNamed; }
- (void) setFileNamed:(NSString *)value
{
	// Avoids changes during a loading process.
	if (!_isParsing)
	{
		// Frees the previous memories and copies the new one.
		nglRelease(_fileNamed);
		_fileNamed = [value copy];
	}
}

- (NSDictionary *) fileSettings { return _fileSettings; }
- (void) setFileSettings:(NSDictionary *)value
{
	// Avoids changes during a loading process.
	if (!_isParsing)
	{
		// Frees the previous memories and retains the new one.
		nglRelease(_fileSettings);
		_fileSettings = [value copy];
	}
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		[self initialize];
	}
	
	return self;
}

- (id) initWithFile:(NSString *)named settings:(NSDictionary *)dict delegate:(id <NGLMeshDelegate>)target
{
	if ((self = [super init]))
	{
		[self initialize];
		
		NGL3DFileType type;
		
		// Delegate.
		self.delegate = target;
		
		// File type.
		type = fileTypeForFile(named);
		if (type != NGL3DFileTypeNone)
		{
			[self loadFile:named settings:dict type:type];
		}
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	// Allocates once.
	if (_meshes == nil)
	{
		_meshes = [[NGLArray alloc] init];
	}
	
	// Adds the current mesh if it was not already in there.
	[_meshes addPointerOnce:self];
	
	// Settings.
	_visible = YES;
	_meshElements = [[NGLMeshElements alloc] init];
	_gestures = [[NGLArray alloc] initWithRetainOption];
}

- (void) updateCoreMesh
{
	// At this point, the mesh must have a valid structure to proceed.
	if (_iCount == 0 && _sCount == 0)
	{
		return;
	}
	
	id <NGLCoreMesh> newCore, oldCore = _coreMesh;
	
	// Starts the new engine.
	switch (nglDefaultEngine)
	{
		case NGLEngineVersionES2:
		default:
			newCore = [[NGLES2Mesh alloc] initWithParent:self];
			break;
	}
	
	// If there is a loading in progress, the new core is
	// updated immediately to be able to render while uploading.
	// The processing of filling the mesh core is always made synchronously.
	if (!_isCompiling)
	{
		_coreMesh = newCore;
		fillCoreMesh(newCore);
	}
	else
	{
		fillCoreMesh(newCore);
		_coreMesh = newCore;
	}
	
	// Clears the buffers and release the instance.
	emptyCoreMesh(oldCore);
	
	// Releases the old core mesh.
	nglRelease(oldCore);
	
	// Defining the bounding box for the new structure. Must be done before free the structures.
	[self defineBoundingBox];
	
	// Frees the data.
	nglFree(_indices);
	nglFree(_structures);
}

- (void) deleteCoreMesh
{
	// Clears the buffers and release the instance.
	emptyCoreMesh(_coreMesh);
	
	// Releases the current core mesh.
	nglRelease(_coreMesh);
}

- (void) defineBoundingBox
{
	unsigned int i, n;
	float vx, vy, vz;
	NGLvec3 vMin, vMax;
	unsigned char vertexStart = (*[_meshElements elementWithComponent:NGLComponentVertex]).start;
	
	// Avoids non-valid structures for 3D bounding boxes.
	if (_stride >= 3)
	{
		//*************************
		//	Limits
		//*************************
		// Resets all the adjusts.
		vx = _structures[vertexStart];
		vy = _structures[vertexStart + 1];
		vz = _structures[vertexStart + 2];
		vMin = (NGLvec3){vx, vy, vz};
		vMax = (NGLvec3){vx, vy, vz};
		
		for (i = 0; i < _sCount; i += _stride)
		{
			n = i + vertexStart;
			
			vx = _structures[n];
			vy = _structures[n + 1];
			vz = _structures[n + 2];
			
			// Stores the minimum value for vertices coordinates.
			vMin.x = (vMin.x > vx) ? vx : vMin.x;
			vMin.y = (vMin.y > vy) ? vy : vMin.y;
			vMin.z = (vMin.z > vz) ? vz : vMin.z;
			
			// Stores the maximum value for vertices coordinates.
			vMax.x = (vMax.x < vx) ? vx : vMax.x;
			vMax.y = (vMax.y < vy) ? vy : vMax.y;
			vMax.z = (vMax.z < vz) ? vz : vMax.z;
		}
		/*
		NGLvec3 vCen;
		// Calculates the object's center.
		vCen.x = (vMax.x + vMin.x) * 0.5f;
		vCen.y = (vMax.y + vMin.y) * 0.5f;
		vCen.z = (vMax.z + vMin.z) * 0.5f;
		vMin = nglVec3Subtract(vMin, vCen);
		vMax = nglVec3Subtract(vMax, vCen);
		//*/
	}
	else
	{
		vMin = kNGLvec3Zero;
		vMax = kNGLvec3Zero;
	}
	
	nglBoundingBoxDefine(&_boundingBox, (NGLbounds){vMin, vMax});
}

- (void) defineDelegate
{
	// Using a single binary logic, generates an unique inspector number
	// corresponding to all the methods implemented by the delegate target.
	_inspector = NGLMeshNone;
	
	if ([_delegate respondsToSelector:@selector(meshLoadingWillStart:)])
	{
		_inspector |= NGLMeshWillStart;
	}
	
	if ([_delegate respondsToSelector:@selector(meshLoadingProgress:)])
	{
		_inspector |= NGLMeshProgress;
	}
	
	if ([_delegate respondsToSelector:@selector(meshLoadingDidFinish:)])
	{
		_inspector |= NGLMeshDidFinish;
	}
	
	if ([_delegate respondsToSelector:@selector(meshLoadingError:)])
	{
		_inspector |= NGLMeshError;
	}
	
	if ([_delegate respondsToSelector:@selector(meshCompilingDidFinish:)])
	{
		_inspector |= NGLMeshCompiled;
	}
}

- (void) defineMeshFromParser
{
	NGLParserMesh *parser = _parser;
	
	// Sets the change's properties to the parser.
	[self defineParserSettings:parser];
	
	// Sets the array of indices and array of structures.
	[self setIndices:parser.indices count:parser.indicesCount];
	[self setStructures:parser.structures count:parser.structuresCount stride:parser.stride];
	
	if (!_isCompiling)
	{
		// Set the start data for each element in the array of structures.
		[_meshElements addFromElements:parser.meshElements];
		
		// Sets the materials, only if they was not set outside during the loading.
		if (_material == nil)
		{
			self.material = parser.material;
		}
		
		// Sets the surfaces, only if they was not set outside during the loading.
		if (_surface == nil)
		{
			self.surface = parser.surface;
		}
	}
	
	// Updates the mesh's core, only if this mesh has a valid structure.
	[self updateCoreMesh];
}

- (void) defineParserSettings:(NGLParserMesh *)parser
{
	id object, value;
	BOOL isClass;
	NSString *key;
	Class cString = [NSString class], cNumber = [NSNumber class];
	
	NGLError *error = [[NGLError alloc] initWithHeader:MSH_ERROR_HEADER];
	
	// Sets the change's properties to the parser.
	for (key in _fileSettings)
	{
		object = [_fileSettings objectForKey:key];
		isClass = ([object isKindOfClass:cString] || [object isKindOfClass:cNumber]);
		
		// Generate error to invalid settings.
		if (!isClass)
		{
			error.message = [NSString stringWithFormat:MSH_ERROR_DATA_TYPE, object];
		}
	}
	
	// Centralize
	value = [_fileSettings objectForKey:kNGLMeshKeyCentralize];
	[parser setAutoCentralize:[value isEqualToString:kNGLMeshCentralizeYes]];
	
	// Normalize
	value = [_fileSettings objectForKey:kNGLMeshKeyNormalize];
	[parser setAutoNormalize:[value floatValue]];
	
	[error showError];
	nglRelease(error);
}

- (void) parserNotification:(NGLMeshInspector)action
{
	SEL selector;
	unsigned int check = NGLMeshNone;
	
	// Avoids unecessary processes.
	if (_inspector == NGLMeshNone)
	{
		return;
	}
	
	// Every load with a valid delegate target (implementing at least one method)
	// Will pass through here at least 3 times: starting, checking error and finishing.
	switch (action)
	{
		case NGLMeshWillStart:
			selector = @selector(meshLoadingWillStart:);
			check = NGLMeshWillStart;
			
			// Updates the parsing.
			_parsing = (NGLParsing) {0.0f, NO, NO, self};
			
			// Starts the progress notification. It will run on the Render Thread.
			[[NGLTimer defaultTimer] addItem:self];
			
			break;
		case NGLMeshProgress:
			selector = @selector(meshLoadingProgress:);
			check = NGLMeshProgress;
			
			// Updates the parsing.
			_parsing.progress = ([_parser loadedData] * 0.8f) + ([_coreMesh loadedData] * 0.2f);
			
			// Avoids new notifications after complete.
			if (_parsing.isComplete)
			{
				return;
			}
			
			break;
		case NGLMeshDidFinish:
			selector = @selector(meshLoadingDidFinish:);
			check = NGLMeshDidFinish;
			
			// Changes the selector to the compiling call back, if needed.
			if (_isCompiling)
			{
				selector = @selector(meshCompilingDidFinish:);
				check = NGLMeshCompiled;
			}
			
			// Updates the parsing.
			_parsing.progress = 1.0f;
			_parsing.isComplete = YES;
			
			// Finishes the progress notification.
			[[NGLTimer defaultTimer] removeItem:self];
			
			break;
		case NGLMeshError:
			selector = @selector(meshLoadingError:);
			check = NGLMeshError;
			
			// Checks if the parser has any error.
			if (![_parser hasError])
			{
				return;
			}
			
			// Updates the parsing.
			_parsing.isFailed = YES;
			
			break;
		default:
			selector = NULL;
			break;
	}
	
	// Performs the a method if the delegate target responds to the method.
	if ((_inspector & check))
	{
		dispatch_async(dispatch_get_main_queue(), ^(void)
		{
			// Avoids invalid or released delegate.
			if (nglPointerIsValidToClass(_delegate, _delegateClass))
			{
				((id (*)(id, SEL, NGLParsing))objc_msgSend)(_delegate, selector, _parsing);
			}
			else
			{
				_inspector = NGLMeshNone;
			}
		});
	}
}

- (void) loadFile
{
	// This function can take a while until fully complete.
	// Depending on the 3D file, it can take many seconds.
	NGLParserNGL *nglFile = [[NGLParserNGL alloc] init];
	NSString *useOriginal = [_fileSettings objectForKey:kNGLMeshKeyOriginal];
	BOOL isBinary = (_parserClass == [NGLParserNGL class]);
	BOOL hasCache = [nglFile hasCache:_fileNamed];
	BOOL useCache = (![useOriginal isEqualToString:kNGLMeshOriginalYes] && hasCache);
	
	// Allocates the parser memory.
	_parser = (useCache) ? [nglFile retain] : [[_parserClass alloc] init];
	
	//*************************
	//	Notifications
	//*************************
	// Notifications will be delivered to the delegate in the main thread.
	[self parserNotification:NGLMeshWillStart];
	
	//*************************
	//	Parsing
	//*************************
	// If the original is not requested, tries to decode the cached file.
	// Decoding doesn't show any error if the file was not found.
	if (useCache)
	{
		// Decodes the cached file.
		[nglFile decodeCache:_fileNamed];
	}
	// If the original is requested or no valid caches are found, parses the original.
	else
	{
		// Loads the 3D file.
		[_parser loadFile:_fileNamed];
	}
	
	//*************************
	//	Notifications
	//*************************
	// Notifications will be delivered to the delegate in the main thread.
	[self parserNotification:NGLMeshError];
	
	//*************************
	//	Parsing
	//*************************
	// Just proceeds with no errors.
	if (![_parser hasError])
	{
		// Only saves the optimized stream copy (NGL Binary File) if it's allowed.
		// NGL encoding automatically aborts in case of invalid original targets.
		if (!isBinary && !useCache)
		{
			[nglFile encodeCache:_parser withName:_fileNamed];
		}
		
		// Gets information from the parser.
		[self defineMeshFromParser];
	}
	
	// Frees the memory.
	nglRelease(_parser);
	nglRelease(nglFile);
	
	// Frees the used slot in the NinevehGL Parser threads.
	parseFreeSlot(_slot);
	
	//*************************
	//	Notifications
	//*************************
	// Notifications will be delivered to the delegate in the main thread.
	[self parserNotification:NGLMeshDidFinish];
	
	
	// Unlocks the loading methods.
	_isParsing = NO;
	_isCompiling = NO;
}

- (void) makeCopyTo:(id)aCopy shared:(BOOL)isShared
{
	NGLMesh *copy = aCopy;
	
	// Copying properties.
	copy.visible = _visible;
	
	//TODO create shared MeshCore (OpenGL ES 2), instead of this.
	copy.fileNamed = _fileNamed;
	copy.fileSettings = _fileSettings;
	[copy.meshElements addFromElements:_meshElements];
	//TODO
	//self.volumeBox;
	
	if (isShared)
	{
		copy.material = _material;
		copy.shaders = _shaders;
		copy.surface = _surface;
	}
	else
	{
		id <NGLMaterial> cMaterial = [_material copy];
		id <NGLShaders> cShaders = [_shaders copy];
		id <NGLSurface> cSurface = [_surface copy];
		
		copy.material = cMaterial;
		copy.shaders = cShaders;
		copy.surface = cSurface;
		
		nglRelease(cMaterial);
		nglRelease(cShaders);
		nglRelease(cSurface);
	}
	
	[copy compileCoreMesh];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) timerCallBack
{
	[self parserNotification:NGLMeshProgress];
}

- (void) loadFile:(NSString *)named settings:(NSDictionary *)dict type:(NGL3DFileType)type
{
	// Avoids new loads during a loading process.
	if (!_isParsing)
	{
		// Sets the file attributes.
		self.fileNamed = named;
		self.fileSettings = (nglDefaultImportSettings != nil) ? nglDefaultImportSettings : dict;
		
		// Locks the loading methods.
		_isParsing = YES;
		
		// Resets some settings of this mesh when this call represents a new loading.
		if (!_isCompiling)
		{
			self.material = nil;
			self.surface = nil;
			
			[self defineDelegate];
		}
		
		// Chooses the class based on 3D file type.
		switch (type)
		{
			case NGL3DFileTypeDAE:
				_parserClass = [NGLParserDAE class];
				break;
			case NGL3DFileTypeOBJ:
				_parserClass = [NGLParserOBJ class];
				break;
			case NGL3DFileTypeNGL:
				_parserClass = [NGLParserNGL class];
				break;
			default:
				return;
				break;
		}
		
		// Chooses a slot in the NinevehGL Parser threads. This slot must be freed after parsing.
		_slot = parseSlot();
		
		// Starts or queue this load in the selected parser tread. The Parser Thread is a short-lived one.
		NSString *threadName = [NSString stringWithFormat:@"%@-%i", kNGLThreadParser, _slot];
		nglThreadPerformAsync(threadName, @selector(loadFile), self);
	}
}

- (void) cancelLoading
{
	[_parser cancelLoading];
}

- (void) compileCoreMesh
{
	// Reloading the structure from NGL Binary file.
	if (!_isParsing)
	{
		/*
		NGLParserNGL *parser = [[NGLParserNGL alloc] init];
		
		// Reload the saved cache if it's valid.
		if ([parser hasCache:_fileNamed])
		{
			[parser decodeCache:_fileNamed];
			
			// Sets the change's properties to the parser.
			[self defineParserSettings:parser];
			
			// Rebind the mesh's structure.
			[self setIndices:parser.indices count:parser.indicesCount];
			[self setStructures:parser.structures count:parser.structuresCount stride:parser.stride];
		}
		
		nglRelease(parser);
		
		[self updateCoreMesh];
		/*/
		// The new settings is equal the last one, however it will not load the original file.
		NSMutableDictionary *cacheSettings = [NSMutableDictionary dictionaryWithDictionary:_fileSettings];
		[cacheSettings removeObjectForKey:kNGLMeshKeyOriginal];
		
		// There are no new notifications about the loading process, just about the explicit compilation.
		_inspector &= NGLMeshCompiled;
		_isCompiling = YES;
		
		// Reloads the cached file and avoids this method of proceeding.
		[self loadFile:_fileNamed settings:cacheSettings type:NGL3DFileTypeNGL];
		//*/
	}
}

- (void) drawMeshWithCamera:(NGLCamera *)camera
{
	// Avoids to render a mesh while the upload is not ready yet.
	if (_coreMesh.isReady)
	{
		// Multiplies the matrices VIEW_PROJECTION by the MODEL resulting in the
		// MODEL_VIEW_PROJECTION matrix to this mesh.
		// This matrix is used to calculate the final position for each vertex.
		nglMatrixMultiply(*camera.matrixViewProjection, *self.matrix, _mvpMatrix);
		
		// Generates the INVERSE_MODEL matrix.
		// This matrix is used to calculate the Light vectors.
		// As the original matrix is the rotation matrix (Orthographic Matrix),
		// we can take its transpose as being the same of its inverse.
		nglMatrixTranspose(*self.matrixOrtho, _mIMatrix);
		
		// Takes the original camera matrix, which is by default inverted in relation to the object space,
		// and post-multiply it by the INVERSE_MODEL matrix, generating the INVERSE_MODEL_VIEW matrix.
		// This inverse matrix is used to calculate the Eye vector in shaders.
		nglMatrixMultiply(_mIMatrix, *camera.matrix, _mvIMatrix);
		
		// Draws this mesh.
		[_coreMesh drawCoreMesh];
	}
}

- (void) drawMeshWithCamera:(NGLCamera *)camera usingTelemetry:(unsigned int)telemetry
{
	// Avoids to render a mesh while the upload is not ready yet.
	if (_coreMesh.isReady)
	{
		// Multiplies the matrices VIEW_PROJECTION by the MODEL resulting in the
		// MODEL_VIEW_PROJECTION matrix to this mesh.
		// This matrix is used to calculate the final position for each vertex.
		nglMatrixMultiply(*camera.matrixViewProjection, *self.matrix, _mvpMatrix);
		
		// Draws this mesh.
		[_coreMesh drawTelemetry:telemetry];
	}
}

- (void) setIndices:(unsigned int *)newIndices count:(unsigned int)newCount
{
	// Copies the memory of array of indices.
	_indices = realloc(_indices, newCount * NGL_SIZE_UINT);
	memcpy(_indices, newIndices, newCount * NGL_SIZE_UINT);
	_iCount = newCount;
}

- (void) setStructures:(float *)newStructures count:(unsigned int)newCount stride:(unsigned int)newStride
{
	// Copies the memory of array of structures.
	_structures = realloc(_structures, newCount * NGL_SIZE_FLOAT);
	memcpy(_structures, newStructures, newCount * NGL_SIZE_FLOAT);
	_sCount = newCount;
	_stride = newStride;
}

+ (void) updateAllMeshes
{
	NGLMesh *mesh;
	
	//for (mesh in _meshes)
	nglFor (mesh, _meshes)
	{
		[mesh compileCoreMesh];
	}
}

+ (void) emptyAllMeshes
{
	NGLMesh *mesh;
	
	//for (mesh in _meshes)
	nglFor (mesh, _meshes)
	{
		[mesh deleteCoreMesh];
	}
}

+ (NSArray *) allMeshes
{
	return [_meshes allPointers];
}

#pragma mark NGLGestureRecognizer
//*************************
//	NGLGestureRecognizer
//*************************

- (void) addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
	nglGestureAdd(self, gestureRecognizer);
}

- (void) removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
	nglGestureRemove(self, gestureRecognizer);
}

- (void) removeAllGestureRecognizers
{
	nglGestureRemoveAll(self);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) defineCopyTo:(id)aCopy shared:(BOOL)isShared
{
	[super defineCopyTo:aCopy shared:isShared];
	
	// Prepares the invocation to async task.
	// It's better to always use NSInvocation to minimize the delays between copying and parsing.
	SEL selector = @selector(makeCopyTo:shared:);
	NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:self];
	[invocation setSelector:selector];
	[invocation setArgument:&aCopy atIndex:2];
	[invocation setArgument:&isShared atIndex:3];
	[invocation retainArguments];
	
	// Avoids copying during a loading process.
	if (!_isParsing)
	{
		[invocation invoke];
	}
	else
	{
		// Starts or queue this load in the selected parser tread.
		NSString *name = [NSString stringWithFormat:@"%@-%i", kNGLThreadParser, _slot];
		nglThreadPerformAsync(name, @selector(invoke), invocation);
	}
}
/*
- (NSString *) description
{
	NSString *string = [NSString stringWithFormat:@"\n%@\n\
						Visible: %@\n\
						Materials: %@\n\
						Shaders: %@\n\
						Surfaces: %@\n",
						[super description],
						_visible ? @"YES" : @"NO",
						_material,
						_shaders,
						_surface];
	
	return string;
}
//*/
- (void) dealloc
{
	[self cancelLoading];
	[self deleteCoreMesh];
	nglGestureRemoveAll(self);
	
	// Mesh data.
	nglFree(_indices);
	nglFree(_structures);
	nglRelease(_meshElements);
	nglRelease(_material);
	nglRelease(_surface);
	nglRelease(_shaders);
	
	// Parser settings.
	nglRelease(_fileNamed);
	nglRelease(_fileSettings);
	
	// Gestures
	nglRelease(_gestures);
	
	// Removes this NGLMesh from the mesh collection.
	[_meshes removePointer:self];
	
	// Releases the collection if it becomes empty.
	if ([_meshes count] == 0)
	{
		nglRelease(_meshes);
	}
	
	[super dealloc];
}

@end