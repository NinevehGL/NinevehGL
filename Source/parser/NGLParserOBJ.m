/*
 *	NGLParserOBJ.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 12/2/10.
 *	Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import "NGLParserOBJ.h"

#import "NGLRegEx.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static NSString *const OBJ_ERROR_HEADER = @"Error while processing NGLParserOBJ with file \"%@\".";

static NSString *const OBJ_ERROR_NO_FILE = @"At line %i.\n\
The WaveFront Object file was not found in the specified path.\n\
The path to the OBJ file should reflect its real location, \
if only the file's name was specified, the search will be executed in the global path.\n\
For more information check the nglGlobalFilePath() function.";

static NSString *const OBJ_ERROR_NO_FACES = @"At line %i.\n\
No valid faces found in this file.\n\
Faces should have the structure v/vt/vn or equivalent, where only the \"v\" is mandatory.";

static NSString *const OBJ_ERROR_IMCOMPLETE_VALUES = @"At line %i.\n\
Incomplete value line.\n\
Each vertex line (v) need to has at least 3 valid values.\n\
Each texture coordenate line (vt) need to has at least 2 valid values.\n\
Each normal line (vn) need to has at least 3 valid values.";

static NSString *const OBJ_ERROR_MULTIPLE_MTL = @"At line %i.\n\
Two or more materials in the same face.\n\
The face is the most basic representation of a polygon. At each polygon (face) only one material \
should be assigned. So only the first assigned material will be valid.";

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// Converts the OBJ face format into a vector, NGLivec3.
static NGLivec3 objFaceToVector(const char *cFace)
{
	nglCStringReplaceChar((char *)cFace, '/', NGL_BLANK_CHAR);
	
	// By setting the default face to 1 avoids incorrect indices, since the first index in OBJ files is 1.
	NGLivec3 face = (NGLivec3){1,1,1};
	char *cTempFace;
	
	face.x = (int)strtol(cFace, &cTempFace, 10);
	face.y = (cTempFace[1] != NGL_BLANK_CHAR) ? (int)strtol(cTempFace, &cTempFace, 10) : 1;
	face.z = (cTempFace[2] != NGL_BLANK_CHAR) ? (int)strtol(cTempFace, &cTempFace, 10) : 1;
	
	return face;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLParserOBJ()

- (void) defineStride;
- (void) updateGroups;

- (void) processFace:(NSString *)face;
- (void) processLine:(NSString *)line;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLParserOBJ

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
		// Allocates once.
		if (_mtlParser == nil)
		{
			_mtlParser = [[NGLParserMTL alloc] init];
		}
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) defineStride
{
	_stride = 0;
	
	// Defines the vertex element as a 4 floats.
	[_meshElements addElement:(NGLElement){NGLComponentVertex, _stride, 4, 0}];
	_stride = 4;
	
	// Defines the texture coordinate element as a 2 floats, if needed.
	if (_tCount > 0)
	{
		[_meshElements addElement:(NGLElement){NGLComponentTexcoord, _stride, 2, 1}];
		_stride += 2;
	}
	
	// Defines the normal element as a 3 floats, if needed.
	if (_nCount > 0)
	{
		[_meshElements addElement:(NGLElement){NGLComponentNormal, _stride, 3, 2}];
		_stride += 3;
	}
	
	_sCache = NO;
}

- (void) updateGroups
{
	[_faceStore removeAllObjects];
	
	_groups = realloc(_groups, (_gCount + 1) * NGL_SIZE_IVEC3);
	
	// Stores the index/stride to the current group elements.
	_groups[_gCount] = (NGLivec3){_vCount, _tCount, _nCount};
	
	// Sets the current group index, which will be used in the faces processing.
	_currentGrp = _gCount;
	
	++_gCount;
}

- (void) processFace:(NSString *)face
{
	unsigned int *faces;
	NGLivec3 vFace, vGroup;
	
	_faces = realloc(_faces, (++_facesCount * _facesStride) * NGL_SIZE_INT);
	
	// Prepares the pointer to work with current face.
	faces = _faces + ((_facesCount - 1) * _facesStride);
	
	// Returns a NGLvec3 containing the values for vertex, vertex texture and vertex normal elements.
	vFace = objFaceToVector([face UTF8String]);
	vGroup = (_groups != NULL) ? _groups[_currentGrp] : kNGLivec3Zero;
	
	// Processes the face. The elements order to OBJ files is always v/vt/vn.
	// Besides, deals with 3DS MAX negative face indexing and adjusts the index, OBJ index starts at 1.
	*faces++ = vFace.x + (vFace.x < 0 ? vGroup.x : -1);
	*faces++ = vFace.y + (vFace.y < 0 ? vGroup.y : -1);
	*faces = vFace.z + (vFace.z < 0 ? vGroup.z : -1);
	
	// Updates the length of the current surface.
	[_mtlParser updateSurfaceLength];
}

- (void) processLine:(NSString *)line
{
	++_lines;
	
	// Skips the blank and comment lines.
	if ([line length] < 3 || [line hasPrefix:@"#"])
	{
		return;
	}
	else
	{
		// Cuts the line.
		_cuted = nglGetArray(line);
		_cutedCount = [_cuted count];
		
		// Avoids invalid lines.
		if (_cutedCount <= 1)
		{
			return;
		}
		
		// Takes all lower case to avoid upper case conflicts, as files from the 3DS Max.
		_prefix = [[[_cuted objectAtIndex:0] lowercaseString] UTF8String];
	}
	
	// The process was ordered to optimize the work on the most frequently lines.
	//*************************
	//	f - Face
	//*************************
	if (strcmp(_prefix, "f") == 0)
	{
		unsigned int i;
		unsigned int length = (_cutedCount > 4) ? _cutedCount : 4;
		for (i = 1; i < length; i++)
		{
			// If the current face forms a polygon which has more than 3 vertices,
			// re-constructs the current face to turn it into multiple triangles.
			if (i >= 4)
			{
				[self processFace:[_cuted objectAtIndex:1]];
				[self processFace:[_cuted objectAtIndex:i - 1]];
			}
			
			// Processes current vertex. If the current face forms a line or a point,
			// this will makes a triangle returning to the first vertex of this face.
			[self processFace:[_cuted objectAtIndex:(_cutedCount > i) ? i : 1]];
		}
	}
	//*************************
	//	vt - Vertex Texture
	//*************************
	else if (strcmp(_prefix, "vt") == 0)
	{
		// Checks for number of values.
		if (_cutedCount <= 2)
		{
			_error.message = [NSString stringWithFormat:OBJ_ERROR_IMCOMPLETE_VALUES, _lines];
			return;
		}
		
		_texcoords = realloc(_texcoords, ++_tCount * NGL_SIZE_VEC2);
		float *texcoord = _texcoords + ((_tCount - 1) * 2);
		
		*texcoord++ = [[_cuted objectAtIndex:1] floatValue];
		*texcoord = [[_cuted objectAtIndex:2] floatValue];
	}
	//*************************
	//	v - Vertex
	//*************************
	else if (strcmp(_prefix, "v") == 0)
	{
		// Checks for number of values.
		if (_cutedCount <= 3)
		{
			_error.message = [NSString stringWithFormat:OBJ_ERROR_IMCOMPLETE_VALUES, _lines];
			return;
		}
		
		_vertices = realloc(_vertices, ++_vCount * NGL_SIZE_VEC4);
		float *vertices = _vertices + ((_vCount - 1) * 4);
		
		*vertices++ = [[_cuted objectAtIndex:1] floatValue];
		*vertices++ = [[_cuted objectAtIndex:2] floatValue];
		*vertices++ = [[_cuted objectAtIndex:3] floatValue];
		*vertices = 1.0f;
	}
	//*************************
	//	vn - Vertex Normal
	//*************************
	else if (strcmp(_prefix, "vn") == 0)
	{
		// Checks for number of values.
		if (_cutedCount <= 3)
		{
			_error.message = [NSString stringWithFormat:OBJ_ERROR_IMCOMPLETE_VALUES, _lines];
			return;
		}
		
		_normals = realloc(_normals, ++_nCount * NGL_SIZE_VEC3);
		float *normals = _normals + ((_nCount - 1) * 3);
		
		*normals++ = [[_cuted objectAtIndex:1] floatValue];
		*normals++ = [[_cuted objectAtIndex:2] floatValue];
		*normals = [[_cuted objectAtIndex:3] floatValue];
	}
	//*************************
	//	g - Group
	//*************************
	else if (strcmp(_prefix, "g") == 0)
	{
		// Creates a new group based on current structure.
		[self updateGroups];
	}
	//*************************
	//	usemtl - Use Material
	//*************************
	else if (strcmp(_prefix, "usemtl") == 0)
	{
		// Checks for multiple materials.
		if (_cutedCount > 2)
		{
			_error.message = [NSString stringWithFormat:OBJ_ERROR_MULTIPLE_MTL, _lines];
		}
		
		// Mark the material to be used in a specific place into array of indices.
		[_mtlParser useMaterialWithName:[_cuted objectAtIndex:1] starting:_facesCount];
	}
	//*************************
	//	mtllib - Material Lib
	//*************************
	else if (strcmp(_prefix, "mtllib") == 0)
	{
		NSMutableString *fullName = [[NSMutableString alloc] init];
		
		unsigned int i;
		unsigned int length = _cutedCount;
		for (i = 1; i < length; i++)
		{
			[fullName appendString:[_cuted objectAtIndex:i]];
			
			// Constructs the real name for file within spaces.
			// Multiple files could be passed at this way.
			if ([[_cuted objectAtIndex:i] rangeOfString:@"."].length == 0)
			{
				[fullName appendString:@" "];
				continue;
			}
			
			[_mtlParser loadFile:[_finalPath stringByAppendingString:fullName]];
			
			[fullName setString:@""];
		}
		
		nglRelease(fullName);
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************



#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) loadFile:(NSString *)named
{
	// Settings
	_lines = 0;
	_sCache = NO;
	_vCount = _tCount = _nCount = 0;
	_gCount = _facesCount = 0;
	_facesStride = 3;
	_finalPath = [nglGetPath(nglMakePath(named)) retain];
	
	// Sets the error header.
	_error.header = [NSString stringWithFormat:OBJ_ERROR_HEADER, named];
	
	// Loads the OBJ source.
	NSString *source = nglSourceFromFile(named);
	
	// Gets total data.
	_loadedData = 0;
	_totalData = [source length];
	double lineBreak = 0;
	lineBreak += [source rangeOfString:@"\n"].length;
	lineBreak += [source rangeOfString:@"\v"].length;
	lineBreak += [source rangeOfString:@"\f"].length;
	lineBreak += [source rangeOfString:@"\r"].length;
	
	// Processing the loop on every line.
	// iOS 4.0 or later support a faster and more direct enumeration method.
	[source enumerateLinesUsingBlock:^(NSString *line, BOOL *stop)
	{
		// Canceled status.
		*stop = _canceled;
		
		// Updates the loaded data, sums the line length and the line break character.
		_loadedData += [line length] + lineBreak;
		
		[self processLine:line];
	}];
	
	// Calculates the structure count and stride.
	[self defineStride];
	
	// Creates a default group if no group exist.
	if (_gCount == 0)
	{
		[self updateGroups];
	}
	
	//  Checks for faces count.
	if (_facesCount == 0)
	{
		_error.message = [NSString stringWithFormat:OBJ_ERROR_NO_FACES, _lines];
	}
	
	// Checks if the file exists.
	if (source == nil)
	{
		_error.message = [NSString stringWithFormat:OBJ_ERROR_NO_FILE, _lines];
	}
	
	// Defines the structure if no error was found, otherwise shows the error.
	if (!_error.hasError)
	{
		[self defineStructure];
	}
	else
	{
		[_error showError];
	}
	
	// Frees the memories
	nglRelease(_finalPath);
}

- (NGLMaterialMulti *) material
{
	return [_mtlParser materials];
}

- (NGLSurfaceMulti *) surface
{
	return [_mtlParser surfaces];
}

- (void) dealloc
{
	// Pointers to basic C datas.
	nglFree(_faces);
	nglFree(_vertices);
	nglFree(_texcoords);
	nglFree(_normals);
	nglFree(_groups);
	
	// Materials Library
	nglRelease(_mtlParser);
	
	[super dealloc];
}

@end