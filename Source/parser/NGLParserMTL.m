/*
 *	NGLParserMTL.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/1/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLParserMTL.h"

#import "NGLRegEx.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static NSString *const MTL_ERROR_HEADER1 = @"Error while processing NGLParserMTL with file \"%@\".";

static NSString *const MTL_ERROR_HEADER2 = @"Error while processing NGLParserMTL with name \"%@\".";

static NSString *const MTL_IMCOMPLETE_VALUES = @"At line %i.\n\
Incomplete value line.\n\
Each line of vector value, like Tf, Ka, Kd, Ks and others need to has at least 3 valid values.";

static NSString *const MTL_NOT_FOUND = @"At line %i.\n\
Material file not found in the main Bundle.\n\
The MTL files should stay in the same location as its holder, the OBJ file.";

static NSString *const LIB_NOT_FOUND = @"\
The material with the above name was not found in the material library.\n\
The material's name used in the OBJ file need to be correspondent to the names in MTL file.";

static NSString *const REG_FILE_PATH = @"\\W*?\\w+? (.*)";

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

// Global count to the materials created by this parse.
static unsigned int _mtlCount;

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLParserMTL()

// Defines a NGL color based on values from the MTL file.
- (NGLvec4) makeColorTo:(NSArray *)array;

// Defines a NGLTexture based on a file path from MTL file.
- (NGLTexture *) makeMapToFile:(NSString *)filePath;

// Processes each line in the MTL file.
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

@implementation NGLParserMTL

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic materials, surfaces;

- (NGLMaterialMulti *) materials
{
	return _materials;
}

- (NGLSurfaceMulti *) surfaces
{
	return _surfaces;
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
		_files = [[NSMutableArray alloc] init];
		_materials = [[NGLMaterialMulti alloc] init];
		_surfaces = [[NGLSurfaceMulti alloc] init];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (NGLvec4) makeColorTo:(NSArray *)array
{
	NGLvec4 color;
	
	// Checks for number of values.
	if ([array count] >= 3)
	{
		color.x = [[array objectAtIndex:1] floatValue];
		color.y = [[array objectAtIndex:2] floatValue];
		color.z = [[array objectAtIndex:3] floatValue];
		color.w = 1.0f;
	}
	else
	{
		_error.message = [NSString stringWithFormat:MTL_IMCOMPLETE_VALUES, _lines];
	}
	
	return color;
}

- (NGLTexture *) makeMapToFile:(NSString *)filePath
{
	filePath = nglRegExReplace(filePath, REG_FILE_PATH, @"$1", NGLRegExFlagGDM);
	
	// Isolates the file with its extension from the rest of path.
	filePath = [_finalPath stringByAppendingString:nglGetFile(filePath)];
	
	// Returns only the file name.
	return [NGLTexture texture2DWithFile:filePath];
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
	
	//*************************
	//	newmtl - Material
	//*************************
	if (strcmp(_prefix, "newmtl") == 0)
	{
		// Releases previously working material.
		nglRelease(_currentMaterial);
		
		// Creates a NGLMaterial and set its properties.
		// This material will be released in dealloc method.
		_currentMaterial = [[NGLMaterial alloc] init];
		_currentMaterial.name = [_cuted objectAtIndex:1];
		_currentMaterial.identifier = ++_mtlCount;
		
		// Adds to the Multi/Sub Material library.
		[_materials addMaterial:_currentMaterial];
	}
	//*************************
	//	d|Tr|Tf - Alpha
	//*************************
	else if (strcmp(_prefix, "d") == 0)
	{
		// The property "d" is the real alpha.
		_currentMaterial.alpha = [[_cuted objectAtIndex:1] floatValue];
	}
	else if (strcmp(_prefix, "tr") == 0)
	{
		// The property "tr" is the tranparency, the transparency amount is a range of 0% to 100%.
		_currentMaterial.alpha = 1 - [[_cuted objectAtIndex:1] floatValue];
	}
	else if (strcmp(_prefix, "tf") == 0)
	{
		// The property "tf" represents the transparent color, is necessary to calculate the alpha.
		_currentMaterial.alpha = 1;
		
		float alpha = 0.0f;
		unsigned int n = 0;
		
		unsigned int i;
		unsigned int length = _cutedCount;
		
		for (i = 1; i < length; i++)
		{
			if ([[_cuted objectAtIndex:i] length] > 0)
			{
				alpha += [[_cuted objectAtIndex:i] floatValue];
				++n;
			}
		}
		
		// Finds the average.
		_currentMaterial.alpha = alpha / n;
	}
	//*************************
	//	illum - Illumination
	//*************************
	/*
	0	 Color on						Ambient off 
	1	 Color on						Ambient on 
	2	 Highlight on 
	3	 Reflection on					Ray trace on 
	4	 Transparency: Glass on			Reflection: Ray trace on 
	5	 Reflection: Fresnel on			Ray trace on 
	6	 Transparency: Refraction on	Reflection: Fresnel off and Ray trace on 
	7	 Transparency: Refraction on	Reflection: Fresnel on and Ray trace on 
	8	 Reflection on					Ray trace off 
	9	 Transparency: Glass on			Reflection: Ray trace off 
	10	 Casts shadows onto invisible surfaces
	//*/
	//*************************
	//	Ka - Ambient Color
	//*************************
	if (strcmp(_prefix, "ka") == 0)
	{
		_currentMaterial.ambientColor = [self makeColorTo:_cuted];
	}
	//*************************
	//	Kd - Diffuse Color
	//*************************
	else if (strcmp(_prefix, "kd") == 0)
	{
		_currentMaterial.diffuseColor = [self makeColorTo:_cuted];
	}
	//*************************
	//	Ke - Emissive Color
	//*************************
	else if (strcmp(_prefix, "ke") == 0)
	{
		_currentMaterial.emissiveColor = [self makeColorTo:_cuted];
	}
	//*************************
	//	Ks - Specular Color
	//*************************
	else if (strcmp(_prefix, "ks") == 0)
	{
		_currentMaterial.specularColor = [self makeColorTo:_cuted];
	}
	//*************************
	//	Ns - Shininess
	//*************************
	else if (strcmp(_prefix, "ns") == 0)
	{
		_currentMaterial.shininess = [[_cuted objectAtIndex:1] floatValue];
	}
	//*************************
	//	Ni - Refraction
	//*************************
	else if (strcmp(_prefix, "ni") == 0)
	{
		_currentMaterial.refraction = [[_cuted objectAtIndex:1] floatValue];
	}
	//*************************
	//	map_d - Alpha Map
	//*************************
	else if (strcmp(_prefix, "map_d") == 0)
	{
		_currentMaterial.alphaMap = [self makeMapToFile:line];
	}
	//*************************
	//	map_Ka - Ambient Map
	//*************************
	else if (strcmp(_prefix, "map_ka") == 0)
	{
		_currentMaterial.ambientMap = [self makeMapToFile:line];
	}
	//*************************
	//	map_Kd - Diffuse Map
	//*************************
	else if (strcmp(_prefix, "map_kd") == 0)
	{
		_currentMaterial.diffuseMap = [self makeMapToFile:line];
	}
	//*************************
	//	map_Ke - Emissive Map
	//*************************
	else if (strcmp(_prefix, "map_ke") == 0)
	{
		_currentMaterial.emissiveMap = [self makeMapToFile:line];
	}
	//*************************
	//	map_Ns - Shininess Map
	//*************************
	else if (strcmp(_prefix, "map_ns") == 0)
	{
		_currentMaterial.shininessMap = [self makeMapToFile:line];
	}
	//*************************
	//	map_Ks - Specular Map
	//*************************
	else if (strcmp(_prefix, "map_ks") == 0)
	{
		_currentMaterial.specularMap = [self makeMapToFile:line];
	}
	//*************************
	//	map_Bump - Bump Map
	//*************************
	else if (strcmp(_prefix, "map_bump") == 0 || strcmp(_prefix, "bump") == 0)
	{
		_currentMaterial.bumpMap = [self makeMapToFile:line];
	}
	//*************************
	//	map_refl - Reflection
	//*************************
	else if (strcmp(_prefix, "map_refl") == 0 || strcmp(_prefix, "refl") == 0)
	{	
		_currentMaterial.reflectiveMap = [self makeMapToFile:line];
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) loadFile:(NSString *)named
{
	// Prior checking, checks if the same file path was already processed.
	if ([_files containsObject:named])
	{
		return;
	}
	else
	{
		[_files addObject:named];
	}
	
	// Settings
	_lines = 0;
	_finalPath = [nglGetPath(nglMakePath(named)) retain];
	
	// Initializes error class.
	_error = [[NGLError alloc] init];
	_error.header = [NSString stringWithFormat:MTL_ERROR_HEADER1, named];
	
	// Loads the OBJ source.
	NSString *source = nglSourceFromFile(named);
	
	// Processing the loop on every line.
	// iOS 4.0 or later support a faster and more direct enumeration method.
	[source enumerateLinesUsingBlock:^(NSString *line, BOOL *stop)
	 {
		 [self processLine:line];
	 }];
	
	// Checks if file exist.
	if (source == nil)
	{
		_error.message = [NSString stringWithFormat:MTL_NOT_FOUND, _lines];
	}
	
	// Prints error if exist.
	[_error showError];
	
	nglRelease(_error);
}

- (void) useMaterialWithName:(NSString *)name starting:(int)start
{
	NGLMaterial *material;
	
	// Checks if material lib exist in current file.
	if (!(material = [_materials materialWithName:name]))
	{
		[NGLError errorInstantlyWithHeader:[NSString stringWithFormat:MTL_ERROR_HEADER2, name]
								andMessage:LIB_NOT_FOUND];
	}
	
	// Creates a new surface.
	// This surface will be released later in dealloc method.
	// Sets the surface properties.
	nglRelease(_currentSurface);
	_currentSurface = [[NGLSurface alloc] initWithStart:start length:0 identifier:material.identifier];
	
	// Registers it into surface library.
	[_surfaces addSurface:_currentSurface];
	
	// Frees the memories
	nglRelease(_finalPath);
}

- (void) updateSurfaceLength
{
	++_currentSurface.lengthData;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nglRelease(_currentMaterial);
	nglRelease(_currentSurface);
	
	nglRelease(_files);
	nglRelease(_materials);
	nglRelease(_surfaces);
	
	[super dealloc];
}

@end