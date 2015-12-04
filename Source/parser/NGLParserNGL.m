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

#import "NGLParserNGL.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// Current NGL Binary file version.
#define NGL_FILE_VERSION		1.1f

static NSString *const NGL_EXTENSION = @"ngl";

static NSString *const NGL_FOLDER = @"NinevehGL";

static NSString *const NGL_ERROR_HEADER = @"Error while processing NGLParserNGL with file \"%@\".";

static NSString *const NGL_ERROR_NOT_FOUND = @"NinevehGL binary file was not found in the path.\n\
The path to the NGL binary file should reflect its real location, \
if only the file's name was specified, the search will be executed in the global path.\n\
For more information check the nglGlobalFilePath() function.";

static NSString *const NGL_ERROR_OUTDATED = @"There is a local NinevehGL binary file that is outdated \
and is not possible update this old version.\n\
Please, clear your cache files by following the instructions:\n\
- On the device: Delete the APP.\n\
- On the simulator: Delete ~/Library/Application Support/iPhone Simulator/<iOS version>/Applications/*.*";

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

// NGLMaterial map identifier structure.
typedef enum
{
	NGLMapAlpha				= 0x01, // Default
	NGLMapAmbient			= 0x02,
	NGLMapDiffuse			= 0x03,
	NGLMapEmissive			= 0x04,
	NGLMapSpecular			= 0x05,
	NGLMapShininess			= 0x06,
	NGLMapBump				= 0x07,
	NGLMapReflection		= 0x08,
} NGLMapType;

// NGLMesh structure.
// 12 bytes: 3 UInt32.
typedef struct
{
	UInt32	indicesCount;
	UInt32	structuresCount;
	UInt32	stride;
} NGLMeshBody;

// NGLMeshElement structure.
// 4 bytes: 4 UInt8.
typedef struct
{
	UInt8		component;
	UInt8		start;
	UInt8		length;
	UInt8		offsetInFace;
} NGLElementBody;

// NGLMaterial structure.
// 84 bytes: 5 float + 4 NGLvec4.
typedef struct
{	
	float			alpha;
	NGLvec4			ambientColor;
	NGLvec4			diffuseColor;
	NGLvec4			emissiveColor;
	NGLvec4			specularColor;
	float			shininess;
	float			reflectiveLevel;
	float			refraction;
} NGLMaterialBody;

// NGLTexture map structure.
// 4 bytes: 4 char.
typedef struct
{
	UInt8	type;
	UInt8	quality;
	UInt8	repeat;
	UInt8	optimize;
} NGLMapBody;

// NGLSurface structure.
// 8 bytes: 2 UInt32.
typedef struct
{
	UInt32	startData;
	UInt32	lengthData;
} NGLSurfaceBody;

// Full path to the NinevehGL binary folder in the Library directory.
static NSString		*_nglPath;

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLParserNGL()

// Resets the locator/pointer to the bit stream.
- (void) resetRange;

// Increments and returns a new locator/pointer to work on the bit stream.
- (NSRange) rangeUntil:(UInt32)length;

// Extracts the data from a NGL Binary file.
- (void) extractDataFromFile:(NSString *)fullPath;

// Creates and saves a NGL Binary file.
- (void) compressData:(NGLParserMesh *)parse file:(NSString *)fullPath;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLParserNGL

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		// Allocate once.
		if (_nglPath == nil)
		{
			// Create the full path to NinevehGL binary folder.
			NSArray *doc = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
			_nglPath = [[[doc objectAtIndex:0] stringByAppendingPathComponent:NGL_FOLDER] copy];
			
			// Create the folder with default configurations. This method automatically skips if the
			// folder already exist.
			[[NSFileManager defaultManager] createDirectoryAtPath:_nglPath
									  withIntermediateDirectories:YES
													   attributes:nil
															error:nil];
		}
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) resetRange
{
	_rangeIndex = 0;
	
	// Reseting loaded data.
	_loadedData = 0;
	_totalData = 1;
	
	// Ignores the parser progress.
	_parsedData = 1;
	_totalParsedData = 1;
}

- (NSRange) rangeUntil:(UInt32)length
{
	NSRange range = (NSRange){_rangeIndex,length};
	_rangeIndex += length;
	
	// Updates the loaded data.
	_loadedData = _rangeIndex;
	
	return range;
}

- (void) extractDataFromFile:(NSString *)fullPath
{
	NSData *data = nglDataFromFile(fullPath);
	UInt32 i, j;
	
	// Resets the helpers.
	[self resetRange];
	
	// Gets the total data.
	_totalData = [data length];
	
	//*************************
	//	Header
	//*************************
	
	// File version.
	float version;
	
	// Retrieves the NGL binary file version.
	[data getBytes:&version range:[self rangeUntil:NGL_SIZE_FLOAT]];
	
	// Prevents incorrect bytes count.
	if (version < NGL_FILE_VERSION)
	{
		NSString *header = [NSString stringWithFormat:NGL_ERROR_HEADER, fullPath];
		[NGLError errorInstantlyWithHeader:header andMessage:NGL_ERROR_OUTDATED];
		return;
	}
	
	//*************************
	//	Mesh structure
	//*************************
	
	// Basic body properties.
	UInt32 elementCount;
	NGLElementBody elementBody;
	NGLElement element;
	NGLMeshBody meshBody;
	
	// Retrieves the mesh elements count.
	[data getBytes:&elementCount range:[self rangeUntil:NGL_SIZE_UINT]];
	
	i = 0;
	while (i < elementCount)
	{
		// Retrieves the mesh elements.
		[data getBytes:&elementBody range:[self rangeUntil:sizeof(NGLElementBody)]];
		
		// Constructs the mesh elements.
		element.component = elementBody.component;
		element.start = elementBody.start;
		element.length = elementBody.length;
		element.offsetInFace = elementBody.offsetInFace;
		
		// Puts the constructed element in the mesh elements.
		[[self meshElements] addElement:element];
		
		++i;
	}
	
	// Retrieves the mesh properties.
	[data getBytes:&meshBody range:[self rangeUntil:sizeof(NGLMeshBody)]];
	
	// Constructs the parsed properties.
	_iCount = meshBody.indicesCount;
	_sCount = meshBody.structuresCount;
	_stride = meshBody.stride;
	
	// Prepare to retrieve the mesh's arrays.
	_indices = realloc(_indices, _iCount * NGL_SIZE_UINT);
	_structures = realloc(_structures, _sCount * NGL_SIZE_FLOAT);
	
	// Retrieves the mesh's arrays.
	[data getBytes:_indices range:[self rangeUntil:_iCount * NGL_SIZE_UINT]];
	[data getBytes:_structures range:[self rangeUntil:_sCount * NGL_SIZE_FLOAT]];
	
	//*************************
	//	Materials
	//*************************
	
	// Names.
	unsigned short nameLength;
	char *name;
	
	// Materials.
	UInt32 materialsCount;
	UInt32 materialID;
	NGLMaterial *material;
	NGLMaterialBody materialBody;
	
	// Textures.
	UInt32  mapsCount;
	unsigned short mapKind;
	NGLTexture *map;
	NGLMapBody mapBody;
	
	// Retrieves the materials count.
	[data getBytes:&materialsCount range:[self rangeUntil:NGL_SIZE_UINT]];
	
	i = 0;
	while (i < materialsCount)
	{
		// Retrieves the material's indentifier.
		[data getBytes:&materialID range:[self rangeUntil:NGL_SIZE_UINT]];
		
		// Retrieves the material's name
		[data getBytes:&nameLength range:[self rangeUntil:NGL_SIZE_USHORT]];
		name = malloc(nameLength * NGL_SIZE_CHAR);
		[data getBytes:name range:[self rangeUntil:nameLength * NGL_SIZE_CHAR]];
		
		// Retrieves the material's body
		[data getBytes:&materialBody range:[self rangeUntil:sizeof(NGLMaterialBody)]];
		
		// Constructs the material's properties.
		material = [[NGLMaterial alloc] init];
		material.name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
		material.identifier = materialID;
		material.alpha = materialBody.alpha;
		material.ambientColor = materialBody.ambientColor;
		material.diffuseColor = materialBody.diffuseColor;
		material.emissiveColor = materialBody.emissiveColor;
		material.specularColor = materialBody.specularColor;
		material.shininess = materialBody.shininess;
		material.reflectiveLevel = materialBody.reflectiveLevel;
		material.refraction = materialBody.refraction;
		
		// Resets for texture's loop.
		nglFree(name);
		j = 0;
		
		// Retrieves the textures count.
		[data getBytes:&mapsCount range:[self rangeUntil:NGL_SIZE_UINT]];
		
		while (j < mapsCount)
		{
			// Retrieves the kind of texture.
			[data getBytes:&mapKind range:[self rangeUntil:NGL_SIZE_USHORT]];
			
			// Retrieves the texture's indentifier.
			[data getBytes:&nameLength range:[self rangeUntil:NGL_SIZE_USHORT]];
			name = malloc(nameLength * NGL_SIZE_CHAR);
			[data getBytes:name range:[self rangeUntil:nameLength * NGL_SIZE_CHAR]];
			
			// Retrieves the texture's body.
			[data getBytes:&mapBody range:[self rangeUntil:sizeof(NGLMapBody)]];
			
			// Constructs the texture's properties.
			map = [[NGLTexture alloc] init];
			map.filePath = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
			map.type = mapBody.type;
			map.quality = mapBody.quality;
			map.repeat = mapBody.repeat;
			map.optimize = mapBody.optimize;
			
			// Puts this texture at the correct place in the material.
			switch (mapKind)
			{
				case NGLMapAlpha:
					material.alphaMap = map;
					break;
				case NGLMapAmbient:
					material.ambientMap = map;
					break;
				case NGLMapDiffuse:
					material.diffuseMap = map;
					break;
				case NGLMapEmissive:
					material.emissiveMap = map;
					break;
				case NGLMapShininess:
					material.shininessMap = map;
					break;
				case NGLMapSpecular:
					material.specularMap = map;
					break;
				case NGLMapBump:
					material.bumpMap = map;
					break;
				case NGLMapReflection:
					material.reflectiveMap = map;
					break;
			}
			
			// Resets for the next texture loop.
			nglFree(name);
			nglRelease(map);
			
			++j;
		}
		
		// Puts the final material in the materials library.
		[_material addMaterial:material];
		
		// Resets for the next material loop.
		nglRelease(material);
		
		++i;
	}
	
	//*************************
	//	Surfaces
	//*************************
	
	// Surfaces.
	UInt32 surfacesCount;
	UInt32 surfaceID;
	NGLSurface *surface;
	NGLSurfaceBody surfaceBody;
	
	// Retrieves the materials count.
	[data getBytes:&surfacesCount range:[self rangeUntil:NGL_SIZE_UINT]];
	
	i = 0;
	while (i < surfacesCount)
	{
		// Retrieves the surface's indentifier.
		[data getBytes:&surfaceID range:[self rangeUntil:NGL_SIZE_UINT]];
		
		// Retrieves the surface's body
		[data getBytes:&surfaceBody range:[self rangeUntil:sizeof(NGLSurfaceBody)]];
		
		// Constructs the surface's properties.
		surface = [[NGLSurface alloc] initWithStart:surfaceBody.startData
											 length:surfaceBody.lengthData
										 identifier:surfaceID];
		
		// Puts the final surface in the surfaces library.
		[_surface addSurface:surface];
		
		// Resets for the next surface loop.
		nglRelease(surface);
		
		++i;
	}
}

- (void) compressData:(NGLParserMesh *)parse file:(NSString *)fullPath
{
	NSMutableData *data = [[NSMutableData alloc] init];
	
	//*************************
	//	Header
	//*************************
	
	// File version.
	float version = NGL_FILE_VERSION;
	
	// Inserts the file version.
	[data appendBytes:&version length:NGL_SIZE_FLOAT];
	
	//*************************
	//	Mesh structure
	//*************************
	
	// Basic body properties.
	UInt32 elementCount;
	NGLElementBody elementBody;
	NGLElement *element;
	NGLMeshBody meshBody;
	NGLMeshElements *elements = parse.meshElements;
	
	// Prepares the mesh elements count.
	elementCount = [elements count];
	
	// Inserts the mesh elements count.
	[data appendBytes:&elementCount length:NGL_SIZE_UINT];
	
	while ((element = [elements nextIterator]))
	{
		// Prepares mesh element.
		elementBody.component = (*element).component;
		elementBody.start = (*element).start;
		elementBody.length = (*element).length;
		elementBody.offsetInFace = (*element).offsetInFace;
		
		// Inserts current element.
		[data appendBytes:&elementBody length:sizeof(NGLElementBody)];
	}
	
	// Prepares the mesh's properties.
	meshBody.indicesCount = parse.indicesCount;
	meshBody.structuresCount = parse.structuresCount;
	meshBody.stride = parse.stride;
	
	// Inserts the mesh's properties.
	[data appendBytes:&meshBody length:sizeof(NGLMeshBody)];
	
	// Inserts the mesh's arrays.
	[data appendBytes:parse.indices length:parse.indicesCount * NGL_SIZE_UINT];
	[data appendBytes:parse.structures length:parse.structuresCount * NGL_SIZE_FLOAT];
	
	//*************************
	//	Materials
	//*************************
	
	// Material Library.
	NGLMaterialMulti *mtlLib = parse.material;
	
	// Names.
	unsigned short nameLength;
	char *name;
	
	// Materials.
	UInt32 materialsCount;
	UInt32 materialID;
	NGLMaterial *material;
	NGLMaterialBody materialBody;
	
	// Textures.
	UInt32 mapsCount;
	unsigned short mapKind;
	NGLTexture *map;
	NGLMapBody mapBody;
	
	// Prepares the materials count.
	materialsCount = [mtlLib count];
	
	// Inserts the materials count.
	[data appendBytes:&materialsCount length:NGL_SIZE_UINT];
	
	for (material in mtlLib)
	{
		// Prepares the material's identifier.
		materialID = material.identifier;
		
		// Prepares the material's name.
		name = (char *)[material.name UTF8String];
		nameLength = strlen(name) + 1;
		
		// Prepares the material's properties.
		materialBody.alpha = material.alpha;
		materialBody.ambientColor = material.ambientColor;
		materialBody.diffuseColor = material.diffuseColor;
		materialBody.emissiveColor = material.emissiveColor;
		materialBody.specularColor = material.specularColor;
		materialBody.shininess = material.shininess;
		materialBody.reflectiveLevel = material.reflectiveLevel;
		materialBody.refraction = material.refraction;
		
		// Inserts the material's identifier.
		[data appendBytes:&materialID length:NGL_SIZE_UINT];
		
		// Inserts the material's identifier.
		[data appendBytes:&nameLength length:NGL_SIZE_USHORT];
		[data appendBytes:name length:nameLength * NGL_SIZE_CHAR];
		
		// Inserts the material's properties.
		[data appendBytes:&materialBody length:sizeof(NGLMaterialBody)];
		
		// Prepares the maps count.
		mapsCount = 0;
		mapsCount += (material.alphaMap != nil);
		mapsCount += (material.ambientMap != nil);
		mapsCount += (material.diffuseMap != nil);
		mapsCount += (material.emissiveMap != nil);
		mapsCount += (material.specularMap != nil);
		mapsCount += (material.shininessMap != nil);
		mapsCount += (material.bumpMap != nil);
		mapsCount += (material.reflectiveMap != nil);
		
		// Inserts the maps count.
		[data appendBytes:&mapsCount length:NGL_SIZE_UINT];
		
		mapKind = NGLMapAlpha;
		while (mapKind < NGLMapReflection + 1)
		{
			// Finds the correct texture map based on the loop index.
			switch (mapKind)
			{
				case NGLMapAlpha:
					map = material.alphaMap;
					break;
				case NGLMapAmbient:
					map = material.ambientMap;
					break;
				case NGLMapDiffuse:
					map = material.diffuseMap;
					break;
				case NGLMapEmissive:
					map = material.emissiveMap;
					break;
				case NGLMapSpecular:
					map = material.specularMap;
					break;
				case NGLMapShininess:
					map = material.shininessMap;
					break;
				case NGLMapBump:
					map = material.bumpMap;
					break;
				case NGLMapReflection:
					map = material.reflectiveMap;
					break;
			}
			
			// If the texture map doesn't exist in the current material, skip to the next one.
			if (map == nil)
			{
				++mapKind;
				continue;
			}
			
			// Prepares the texture's name.
			name = (char *)[map.filePath UTF8String];
			nameLength = strlen(name) + 1;
			
			// Prepares the texture's properties.
			mapBody.type = map.type;
			mapBody.quality = map.quality;
			mapBody.repeat = map.repeat;
			mapBody.optimize = map.optimize;
			
			// Inserts the texture's identifier.
			[data appendBytes:&mapKind length:NGL_SIZE_USHORT];
			
			// Inserts the texture's name.
			[data appendBytes:&nameLength length:NGL_SIZE_USHORT];
			[data appendBytes:name length:nameLength * NGL_SIZE_CHAR];
			
			// Inserts the texture's properties.
			[data appendBytes:&mapBody length:sizeof(NGLMapBody)];
			
			++mapKind;
		}
	}
	
	//*************************
	//	Surfaces
	//*************************
	
	// Surface library.
	NGLSurfaceMulti		*sufLib = parse.surface;
	
	// Surfaces.
	UInt32 surfacesCount;
	UInt32 surfaceID;
	NGLSurface *surface;
	NGLSurfaceBody surfaceBody;
	
	// Prepares the surfaces count.
	surfacesCount = [sufLib count];
	[data appendBytes:&surfacesCount length:NGL_SIZE_UINT];
	
	for (surface in sufLib)
	{
		// Prepares the surface's identifier.
		surfaceID = surface.identifier;
		
		// Prepares the surface's properties.
		surfaceBody.startData = surface.startData;
		surfaceBody.lengthData = surface.lengthData;
		
		// Inserts the surface's identifier.
		[data appendBytes:&surfaceID length:NGL_SIZE_UINT];
		
		// Inserts the surface's properties.
		[data appendBytes:&surfaceBody length:sizeof(NGLSurfaceBody)];
	}
	
	//*************************
	//	Saving file
	//*************************
	
	[data writeToFile:fullPath atomically:YES];
	
	// Frees the memories.
	nglRelease(data);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (BOOL) hasCache:(NSString *)named
{
	NSString *fullPath;
	NSDictionary *attributes;
	
	// Constructs the NGL file's name based on an original name.
	// The NGL file's name will be "<OriginalName>.<NGL_EXTENSION>".
	NSString *nglFile = [nglGetFileName(named) stringByAppendingPathExtension:NGL_EXTENSION];
	
	//*************************
	//	Original file
	//*************************
	
	// Gets the file attributes from the original file.
	fullPath = nglMakePath(named);
	attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
	
	// Cheks if the original file exists.
	if (attributes == nil)
	{
		return NO;
	}
	
	// Gets the modification date from the original file.
	NSDate *originalDate = [attributes objectForKey:NSFileModificationDate];
	
	//*************************
	//	NGL file
	//*************************
	
	// Gets the file attributes from the NGL file.
	fullPath = [_nglPath stringByAppendingPathComponent:nglFile];
	attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
	
	// Checks if the NGL file exists.
	if (attributes == nil)
	{
		return NO;
	}
	
	// Gets the modification date from the NGL file.
	NSDate *nglDate = [attributes objectForKey:NSFileModificationDate];
	
	//*************************
	//	Original VS NGL
	//*************************
	
	// If the original file is a new version compared to NGL file, ignore the NGL file.
	// Positive time interval, comparing the modification date from the original file with the
	// NGL file, means wich the original is newer than NGL file, so use the original one.
	if ([originalDate timeIntervalSinceDate:nglDate] > 0)
	{
		return NO;
	}
	
	return YES;
}

- (void) decodeCache:(NSString *)named
{
	// Constructs the NGL file's name based on an original name.
	// The NGL file's name will be "<OriginalName>.<NGL_EXTENSION>".
	NSString *nglFile = [nglGetFileName(named) stringByAppendingPathExtension:NGL_EXTENSION];
	
	// NGL file always is saved inside a reserved folder in <APPLICATION_HOME>/Library path.
	// This is a secure path properly backuped by application's transfers and updatefileName
	NSString *fullPath = [_nglPath stringByAppendingPathComponent:nglFile];
	
	// Proceeds processing the NGL file data. Only valid path at this point.
	[self extractDataFromFile:fullPath];
}

- (void) encodeCache:(NGLParserMesh *)parser withName:(NSString *)named
{
	// Aborts the encode process if the original parse was invalid.
	if (parser == nil)
	{
		return;
	}
	
	// Constructs the NGL file's name based on an original name.
	// The NGL file's name will be "<OriginalName>.<NGL_EXTENSION>".
	NSString *nglFile = [nglGetFileName(named) stringByAppendingPathExtension:NGL_EXTENSION];
	
	// NGL file always is saved inside a reserved folder in <APPLICATION_HOME>/Library path.
	// This is a secure path properly backuped by application's transfers and updatefileName
	NSString *fullPath = [_nglPath stringByAppendingPathComponent:nglFile];
	
	[self compressData:parser file:fullPath];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) loadFile:(NSString *)named
{
	NSString *fullPath;
	
	// Defines the error header.
	_error.header = [NSString stringWithFormat:NGL_ERROR_HEADER,named];
	
	// Finds full path to the NGL file based on informed path or global path.
	fullPath = nglMakePath(named);
	
	// Checks if the file exists in the full path.
	if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
	{
		[self extractDataFromFile:fullPath];
	}
	else
	{
		_error.message = NGL_ERROR_NOT_FOUND;
		[_error showError];
	}
}

- (void) dealloc
{
	[super dealloc];
}

@end