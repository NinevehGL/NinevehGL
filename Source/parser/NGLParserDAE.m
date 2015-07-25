/*
 *	NGLParserDAE.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 3/18/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLParserDAE.h"

#import "NGLRegEx.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// COLLADA normals are very unoptimized and are defined for each single vertex (many times if necessary).
//#define kDAENormals

//*************************
//	NGLParserDAE Errors
//*************************

static NSString *const DAE_ERROR_HEADER = @"Error while processing NGLParserDAE in file \"%@\".";

static NSString *const DAE_ERROR_NO_FILE = @"The COLLADA file was not found in the specified path.\n\
The path to the DAE file should reflect its real location, \
if only the file's name was specified, the search will be executed in the global path.\n\
For more information check the nglGlobalFilePath() function.";

//static NSString *const DAE_ERROR_XML = @"Error with XML structure.\n%@";

static NSString *const DAE_ERROR_NULL_REF = @"Null reference to \"%@\".\n\
There is in DAE file a reference to an object which doesn't exist in the file context.";

static NSString *const DAE_ERROR_NO_VERTEX = @"No VERTEX input defined to \"%@\".\n\
Each geometry object in COLLADA XML should implement one VERTEX semantic on its primitive.";

static NSString *const DAE_ERROR_NO_FACES = @"No valid faces found in this file.\n\
To correctly parse a COLLADA file, this file should implements at least one valid face format.";

static NSString *const DAE_ERROR_NO_ID = @"Node without \"id\"\n\
By COLLADA specifications the id attribute is not required to the <%@> nodes,\n\
but without an \"id\", this object becomes a null reference.";

static NSString *const DAE_ERROR_NO_SS = @"Node without \"semantic\" or \"source\"\n\
By COLLADA specifications the semantic and source attributes are required\
to the input node of vertices.";

static NSString *const DAE_ERROR_NO_SSO = @"Node without \"semantic\", \"source\" or \"offset\"\n\
By COLLADA specifications the semantic, source and offset attributes are required\
to the input node of polygons.";

static NSString *const DAE_ERROR_NO_TEXTURE = @"Node without \"texture\"\n\
By COLLADA specifications the texture attribute is required to the texture node of effects.";

static NSString *const DAE_ERROR_NO_URL = @"Node without \"url\"\n\
By COLLADA specifications the url attribute is required to the effect node of materials.";

static NSString *const DAE_ERROR_NO_ST = @"Node without \"symbol\" or \"target\"\n\
By COLLADA specifications the symbol and target attributes are required\
to the instance_material node of nodes.";

//*************************
//	COLLADA XML Patterns
//*************************

// Shared
static NSString *const DAE_UP = @"up_axis";
static NSString *const DAE_UP_X = @"X_UP";
static NSString *const DAE_UP_Y = @"Y_UP";
static NSString *const DAE_UP_Z = @"Z_UP";
static NSString *const DAE_UNIT = @"unit";
static NSString *const DAE_INIT_FROM = @"init_from";
static NSString *const DAE_NEW_PARAM = @"newparam";
static NSString *const DAE_SOURCE = @"source";

// Libraries
static NSString *const DAE_LIB_ASS = @"asset";
static NSString *const DAE_LIB_IMG = @"library_images";
static NSString *const DAE_LIB_MAT = @"library_materials";
static NSString *const DAE_LIB_EFX = @"library_effects";
static NSString *const DAE_LIB_GEO = @"library_geometries";
static NSString *const DAE_LIB_VSC = @"library_visual_scenes";
static NSString *const DAE_LIB_NOD = @"library_nodes";

// Images
static NSString *const DAE_IMG = @"image";

// Materials
static NSString *const DAE_MAT = @"material";
static NSString *const DAE_MAT_EFX = @"instance_effect";

// Effects
static NSString *const DAE_EFX = @"effect";
static NSString *const DAE_EFX_AMBIENT = @"ambient";
static NSString *const DAE_EFX_EMISSION = @"emission";
static NSString *const DAE_EFX_DIFFUSE = @"diffuse";
static NSString *const DAE_EFX_SPECULAR = @"specular";
static NSString *const DAE_EFX_REFLECTIVE = @"reflective";
static NSString *const DAE_EFX_REFLECTIVITY = @"reflectivity";
static NSString *const DAE_EFX_SHININESS = @"shininess";
static NSString *const DAE_EFX_REFRACTION = @"index_of_refraction";
static NSString *const DAE_EFX_TRANSPARENT = @"transparent";
static NSString *const DAE_EFX_TRANSPARENCY = @"transparency";
static NSString *const DAE_EFX_COLOR = @"color";
static NSString *const DAE_EFX_TEXTURE = @"texture";
static NSString *const DAE_EFX_FLOAT = @"float";

// Geometries
static NSString *const DAE_GEO = @"geometry";
//static NSString *const DAE_GEO_MESH = @"mesh";
static NSString *const DAE_GEO_ARRAY = @"float_array";
static NSString *const DAE_GEO_ACCESSOR = @"accessor";
static NSString *const DAE_GEO_PARAM = @"param";
static NSString *const DAE_GEO_VERTICES = @"vertices";
static NSString *const DAE_GEO_INPUT = @"input";
static NSString *const DAE_GEO_INPUT_P = @"p";
static NSString *const DAE_GEO_VCOUNT = @"vcount";
static NSString *const DAE_GEO_LINES = @"lines";
static NSString *const DAE_GEO_POLY_LIST = @"polylist";
static NSString *const DAE_GEO_TRIANGLES = @"triangles";
static NSString *const DAE_GEO_POLYGONS = @"polygons";

// Visual Scenes and Nodes
static NSString *const DAE_NODE = @"node";
static NSString *const DAE_NODE_MATRIX = @"matrix";
static NSString *const DAE_NODE_ROTATE = @"rotate";
static NSString *const DAE_NODE_SCALE = @"scale";
static NSString *const DAE_NODE_TRANSLATE = @"translate";
static NSString *const DAE_NODE_NODE = @"instance_node";
static NSString *const DAE_NODE_GEOMETRY = @"instance_geometry";
static NSString *const DAE_NODE_MATERIAL = @"instance_material";

// Attributes
static NSString *const DAE_ATT_ID = @"id";
static NSString *const DAE_ATT_SID = @"sid";
static NSString *const DAE_ATT_NAME = @"name";
static NSString *const DAE_ATT_URL = @"url";
static NSString *const DAE_ATT_OFFSET = @"offset";
static NSString *const DAE_ATT_SEMANTIC = @"semantic";
static NSString *const DAE_ATT_SOURCE = @"source";
static NSString *const DAE_ATT_MATERIAL = @"material";
static NSString *const DAE_ATT_COUNT = @"count";
static NSString *const DAE_ATT_TEXTURE = @"texture";
static NSString *const DAE_ATT_SYMBOL = @"symbol";
static NSString *const DAE_ATT_TARGET = @"target";

// Conventions
static NSString *const DAE_X = @"X";
static NSString *const DAE_Y = @"Y";
static NSString *const DAE_Z = @"Z";
static NSString *const DAE_S = @"S";
static NSString *const DAE_T = @"T";
static NSString *const DAE_POSITION = @"POSITION";
static NSString *const DAE_VERTEX = @"VERTEX";
static NSString *const DAE_TEXCOORD = @"TEXCOORD";
//static NSString *const DAE_NORMAL = @"NORMAL";

//*************************
//	NGLParserDAE Patterns
//*************************

static NSString *const NGL_ARRAY = @"array";
static NSString *const NGL_ORDER = @"order";
static NSString *const NGL_STRIDE = @"stride";
static NSString *const NGL_OFFSET = @"offset";
static NSString *const NGL_MATERIAL = @"material";
static NSString *const NGL_LIMIT = @"limit";

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

//*************************
//	Library Images
//*************************

/*!
 *					<strong>(Internal only)</strong> Tiny class helps to hold and manage the necessary
 *					memory to a library.
 *
 *					Holds one url to one image.
 */
@interface DAEImage : NSObject

@property (nonatomic, retain) NSString *url;

@end

@implementation DAEImage

@synthesize url;

- (void) dealloc
{
	nglRelease(url);
	
	[super dealloc];
}

@end

//*************************
//	Library Materials
//*************************

/*!
 *					<strong>(Internal only)</strong> Tiny class helps to hold and manage the necessary
 *					memory to a library.
 *
 *					Holds one url to one effect.
 */
@interface DAEMaterial : NSObject

@property (nonatomic, retain) NSString *url;

@end

@implementation DAEMaterial

@synthesize url;

- (void) dealloc
{
	nglRelease(url);
	
	[super dealloc];
}

@end

//*************************
//	Library Effects
//*************************

/*!
 *					<strong>(Internal only)</strong> Tiny class helps to hold and manage the necessary
 *					memory to a library.
 *	
 *					Holds two dictionaries. One of these stores effect parameters.
 *					The other holds references to the redundant cross parameter, which
 *					just points to an image.
 *
 *					<strong>Material</strong>
 *					<pre>
 *					Keys:           Values:
 *
 *					ambient         Color (NSArray) | Image (NSString)
 *					diffuse         Color (NSArray) | Image (NSString)
 *					emission        Color (NSArray) | Image (NSString)
 *					specular        Color (NSArray) | Image (NSString)
 *					shininess       Float (NSArray) | Image (NSString)
 *					reflective      Color (NSArray) | Image (NSString)
 *					transparent     Color (NSArray) | Image (NSString)
 *					reflectivity    Float (NSArray)
 *					transparency    Float (NSArray)
 *					refraction      Float (NSArray)
 *					</pre>
 *
 *					<strong>CrossParam</strong>
 *					<pre>
 *					keys:           Values:
 *					&lt;id&gt;            &lt;id&gt;
 *					</pre>
 */
@interface DAEEffect : NSObject

@property (nonatomic, readonly) NSMutableDictionary *material;
@property (nonatomic, readonly) NSMutableDictionary *crossParam;

@end

@implementation DAEEffect

@synthesize material, crossParam;

- (id) init
{
	if ((self = [super init]))
	{
		material = [[NSMutableDictionary alloc] init];
		crossParam = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	nglRelease(material);
	nglRelease(crossParam);
	
	[super dealloc];
}

@end

//*************************
//	Library Geometries
//*************************

/*!
 *					<strong>(Internal only)</strong> Tiny class helps to hold and manage the necessary
 *					memory to a library.
 *
 *					Holds vertices id, vertices structures, sources structure and polygons structure.
 *
 *					<strong>Vertices</strong>
 *					<pre>
 *					Keys:           Values:
 *
 *					POSITION        Source URL (NSString)
 *					NORMAL          Source URL (NSString)
 *					TEXCOORD        Source URL (NSString)
 *					</pre>
 *
 *					<strong>Sources</strong>
 *					<pre>
 *					Keys:           Values:
 *					&lt;id&gt;            NSDictionary • array (NSArray)
 *					                             • stride (NSNumber)
 *					                             • order (NSNumber)
 *					                             • offset (NSNumber)
 *					</pre>
 *
 *					<strong>Polygons</strong>
 *					<pre>
 *					Elements:
 *					NSDictionary • array (NSArray)
 *					             • material (NSString)
 *					             • stride (NSNumber)
 *					             • limit (NSArray)
 *					             • VERTEX (NSDictionary) • offset (NSString)
 *					                                     • semantic (NSString)
 *					                                     • source (NSString)
 *					             • TEXCOORD (NSDictionary) • offset (NSString)
 *					                                       • semantic (NSString)
 *					                                       • source (NSString)
 *					             • NORMAL (NSDictionary) • offset (NSString)
 *					                                     • semantic (NSString)
 *					                                     • source (NSString)
 *					</pre>
 */
@interface DAEGeometry : NSObject

@property (nonatomic, retain) NSString *verticesId;
@property (nonatomic, readonly) NSMutableDictionary *vertices;
@property (nonatomic, readonly) NSMutableDictionary *sources;
@property (nonatomic, readonly) NSMutableArray *polygons;

@end

@implementation DAEGeometry

@synthesize verticesId, vertices, sources, polygons;

- (id) init
{
	if ((self = [super init]))
	{
		vertices = [[NSMutableDictionary alloc] init];
		sources = [[NSMutableDictionary alloc] init];
		polygons = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	nglRelease(verticesId);
	nglRelease(vertices);
	nglRelease(sources);
	nglRelease(polygons);
	
	[super dealloc];
}

@end

//*************************
//	Library Visual Scenes
//*************************

/*!
 *					<strong>(Internal only)</strong> Tiny class helps to hold and manage the necessary
 *					memory to a library.
 *
 *					Holds its own id, its parent node, sub nodes, an array of nodes instances, an array
 *					of transformations and geometries.
 *
 *					<strong>Instances</strong>
 *					<pre>
 *					Elements:
 *					Node URL (NSString)
 *					</pre>
 *
 *					<strong>Transforms</strong>
 *					<pre>
 *					Elements:
 *					NSDictionary • matrix (NSArray)
 *					             • rotate (NSArray)
 *					             • scale (NSArray)
 *					             • translate (NSArray)
 *					</pre>
 *
 *					<strong>Geometries</strong>
 *					<pre>
 *					Keys:           Values:
 *					&lt;id&gt;            Source URL (NSString)
 *					</pre>
 *
 *					<strong>Nodes</strong>
 *					<pre>
 *					Elements:
 *					DAEVisualNode
 *					</pre>
 */
@interface DAEVisualNode : NSObject

@property (nonatomic, retain) NSString *selfId;
@property (nonatomic, retain) NSString *parent;
@property (nonatomic, readonly) NSMutableArray *instances;
@property (nonatomic, readonly) NSMutableArray *transforms;
@property (nonatomic, readonly) NSMutableDictionary *geometries;
@property (nonatomic, readonly) NSMutableArray *nodes;

@end

@implementation DAEVisualNode

@synthesize selfId, parent, instances, transforms, geometries, nodes;

- (id) init
{
	if ((self = [super init]))
	{
		instances = [[NSMutableArray alloc] init];
		transforms = [[NSMutableArray alloc] init];
		geometries = [[NSMutableDictionary alloc] init];
		nodes = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	nglRelease(selfId);
	nglRelease(parent);
	nglRelease(instances);
	nglRelease(transforms);
	nglRelease(geometries);
	nglRelease(nodes);
	
	[super dealloc];
}

@end

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

#define kDefaultStrideV		3
#define kDefaultStrideVT	2
#define kDefaultStrideVN	3

#define kDefaultOrder		0x000102

// Binary order to identify the first, second and third elements.
typedef enum
{
	DaeOrder0		= 0x00,
	DaeOrder1		= 0x01,
	DaeOrder2		= 0x02,
} DaeOrder;

// COLLADA XML transformations.
typedef enum
{
	DaeTransformMatrix,
	DaeTransformRotate,
	DaeTransformScale,
	DaeTransformTranslate,
} DaeTransform;

// COLLADA XML most top nodes.
typedef enum
{
	DaePhaseNone,
	DaePhaseAssets,
	DaePhaseVisualScenes,
	DaePhaseNodes,
	DaePhaseMaterials,
	DaePhaseImages,
	DaePhaseEffects,
	DaePhaseGeometry,
} DaePhase;

DaePhase			_phase;

typedef enum
{
	DaeUpAxisY,
	DaeUpAxisZ,
	DaeUpAxisX,
} DaeUpAxis;

DaeUpAxis			_upAxis;

// Temporary variables to work with COLLADA XML Libraries.
DAEGeometry			*_actualGeometry;
DAEEffect			*_actualEffect;
DAEImage			*_actualImage;
DAEMaterial			*_actualMaterial;
DAEVisualNode		*_actualNode;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// Global count to the materials created by this parse.
static unsigned int _mtlCount;

// Extracts the "id" format from a COLLADA XML url or source.
static NSString *daeGetId(NSString *urlOrSource)
{
	return [urlOrSource stringByReplacingOccurrencesOfString:@"#" withString:@""];
}

// Retains a NSString into another one releasing the old. It does the same as @property (retain).
static void daeSetString(NSString **target, NSString *newString)
{
	if (*target != newString)
	{
		nglRelease(*target);
		*target = [newString retain];
	}
}

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

@interface NGLParserDAE()

- (void) updateGroups;

- (float) makeFloatTo:(NSArray *)array;
- (NGLvec4) makeColorTo:(NSArray *)array;
- (NGLTexture *) makeMapTo:(NSString *)filePath;

- (void) defineStride;
- (void) defineFaceTo:(int)index;

- (unsigned short) makeIdentifierTo:(NSString *)effectKey;
- (void) defineMatricesTo:(DAEVisualNode *)node final:(NGLmat4)matrix rotation:(NGLmat4)rotMatrix;

- (void) parseNode:(DAEVisualNode *)daeNode;
- (void) parseDAE;

- (void) parserXML;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLParserDAE

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
		// Initialization code here.
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) updateGroups
{
	_groups = realloc(_groups, NGL_SIZE_IVEC3 * (_gCount + 1));
	
	// Stores the index/stride for the current group elements.
	_groups[_gCount] = (NGLivec3){_vCount, _tCount, _nCount};
	
	// Sets the current group index, which will be used in the faces processing.
	_currentGrp = _gCount;
	
	++_gCount;
}

- (float) makeFloatTo:(NSArray *)array
{
	float value = 0.0f;
	
	// Check for number of values.
	if ([array count] >= 1)
	{
		value = [[array objectAtIndex:0] floatValue];
	}
	
	return value;
}

- (NGLvec4) makeColorTo:(NSArray *)array
{
	NGLvec4 color;
	
	// Check for number of values.
	if ([array count] >= 4)
	{
		color.x = [[array objectAtIndex:0] floatValue];
		color.y = [[array objectAtIndex:1] floatValue];
		color.z = [[array objectAtIndex:2] floatValue];
		color.w = [[array objectAtIndex:3] floatValue];
	}
	
	return color;
}

- (NGLTexture *) makeMapTo:(NSString *)filePath
{
	// Isolates the file with its extension from the rest of path.
	filePath = [_finalPath stringByAppendingString:nglGetFile(filePath)];
	
	// Return only the file name.
	return [NGLTexture texture2DWithFile:filePath];
}

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
#ifdef kDAENormals
	// Defines the normal element as a 3 floats, if needed.
	if (_nCount > 0)
	{
		[_meshElements addElement:(NGLElement){NGLComponentNormal, _stride, 3, 2}];
		_stride += 3;
	}
#endif
	_sCache = NO;
}

- (void) defineFaceTo:(int)index
{
	unsigned int *faces;
	NGLivec3 vGroup;
	
	_faces = realloc(_faces, NGL_SIZE_INT * (++_facesCount * _facesStride));
	faces = _faces + ((_facesCount - 1) * _facesStride);
	
	vGroup = _groups[_currentGrp];
	
	// Must devide because the entire NGLMesh must has the same structure.
	*faces++ = [[_polyFaces objectAtIndex:index + _vOffset] intValue] + vGroup.x;
	*faces++ = (_hasTexcoord) ? [[_polyFaces objectAtIndex:index + _vtOffset] intValue] + vGroup.y : 0;
#ifdef kDAENormals
	*faces = (_hasNormal) ? [[_polyFaces objectAtIndex:index + _vnOffset] intValue] + vGroup.z : 0;
#else
	*faces = 0;
#endif
	
	++_currentSurface.lengthData;
}

- (void) defineMatricesTo:(DAEVisualNode *)node final:(NGLmat4)matrix rotation:(NGLmat4)rotMatrix
{
	// Helpers.
	NSArray *transformations = node.transforms;
	NSDictionary *transform;
	NSNumber *transformType;
	NSArray *array;
	
	// Parent transformations.
	NSNumber *index;
	NGLmat4 *parentMatrix;
	
	// Transformations.
	NGLmat4 tempMatrix, workMatrix;
	NGLvec3 translate, axis, scale;
	NGLQuaternion *quat;
	
	// Initialize the values an parameters to the following transformation.
	quat = [[NGLQuaternion alloc] init];
	translate = (NGLvec3){0.0f,0.0f,0.0f};
	scale = (NGLvec3){1.0f,1.0f,1.0f};
	nglMatrixIdentity(matrix);
	nglMatrixIdentity(workMatrix);
	
	// Loop through each transformation and extract its values.
	for (transform in transformations)
	{
		// Gets the transformation key and its value.
		transformType = [[transform allKeys] objectAtIndex:0];
		array = [transform objectForKey:transformType];
		
		switch ([transformType intValue])
		{
			case DaeTransformMatrix:
				// Matrices are cumulatives.
				nglMatrixFromNSArray(array, tempMatrix);
				nglMatrixMultiply(workMatrix, tempMatrix, workMatrix);
				break;
			case DaeTransformRotate:
				// Rotations are locals.
				axis.x = [[array objectAtIndex:0] floatValue];
				axis.y = [[array objectAtIndex:1] floatValue];
				axis.z = [[array objectAtIndex:2] floatValue];
				[quat rotateByAxis:axis angle:[[array objectAtIndex:3] floatValue] mode:NGLAddModePrepend];
				break;
			case DaeTransformScale:
				// Scales are relatives.
				scale.x *= [[array objectAtIndex:0] floatValue];
				scale.y *= [[array objectAtIndex:1] floatValue];
				scale.z *= [[array objectAtIndex:2] floatValue];
				break;
			case DaeTransformTranslate:
				// Translates are cumulatives.
				translate.x += [[array objectAtIndex:0] floatValue];
				translate.y += [[array objectAtIndex:1] floatValue];
				translate.z += [[array objectAtIndex:2] floatValue];
				break;
		}
	}
	
	// Creates a matrix from the transformations which are not matrices.
	nglMatrixCopy(*quat.matrix, tempMatrix);
	
	// Fisrt Column
	tempMatrix[0] *= scale.x;
	tempMatrix[1] *= scale.x;
	tempMatrix[2] *= scale.x;
	tempMatrix[3] = 0;
	
	// Second Column
	tempMatrix[4] *= scale.y;
	tempMatrix[5] *= scale.y;
	tempMatrix[6] *= scale.y;
	tempMatrix[7] = 0;
	
	// Third Column
	tempMatrix[8] *= scale.z;
	tempMatrix[9] *= scale.z;
	tempMatrix[10] *= scale.z;
	tempMatrix[11] = 0;
	
	// Fourth Column
	tempMatrix[12] = translate.x;
	tempMatrix[13] = translate.y;
	tempMatrix[14] = translate.z;
	tempMatrix[15] = 1;
	
	// Transformations which are not matrices must be transposed to correctly becomes a matrix.
	nglMatrixTranspose(tempMatrix, tempMatrix);
	
	// Gets the final transformation matrix by multiplying all transformations.
	nglMatrixMultiply(workMatrix, tempMatrix, matrix);
	
	// Deals with the parent transformations.
	if (node.parent != nil)
	{
		index = [_transformations objectForKey:node.parent];
		nglMatrixMultiply(matrix, *_matrices[[index intValue]], matrix);
	}
	
	// Copies the current final matrix.
	parentMatrix = malloc(NGL_SIZE_MAT4);
	nglMatrixCopy(matrix, *parentMatrix);
	
	// Stores the current final matrix to be used later as a parent transformation, if necessary.
	index = [NSNumber numberWithInt:_mCount];
	_matrices = realloc(_matrices, sizeof(NGLmat4 *) * (_mCount + 1));
	_matrices[_mCount] = parentMatrix;
	[_transformations setObject:index forKey:node.selfId];
	++_mCount;
	
	// Correction to COLLADA Axis as following:
	// Value     Right Axis      Up Axis        In Axis
	// X-UP      Negative y     Positive x     Positive z  (not noticed yet)
	// Y_UP      Positive x     Positive y     Positive z  (majority of 3D softwares)
	// Z_UP      Positive x     Positive z     Negative y  (3DS Max, Blender, Google SketchUp)
	switch (_upAxis)
	{
		case DaeUpAxisY:
			// Doesn't change anything here.
			break;
		case DaeUpAxisZ:
			// Before any other transformation, corrects the COLLADA axis.
			[quat rotateByAxis:(NGLvec3){1.0f,0.0f,0.0f} angle:90.0f mode:NGLAddModeSet];
			nglMatrixMultiply(matrix, *quat.matrix, matrix);
			break;
		case DaeUpAxisX:
			// Before any other transformation, corrects the COLLADA axis.
			[quat rotateByAxis:(NGLvec3){0.0f,0.0f,1.0f} angle:-90.0f mode:NGLAddModeSet];
			nglMatrixMultiply(matrix, *quat.matrix, matrix);
			break;
	}
#ifdef kDAENormals
	// Isolates the rotation matrix. It will be used to correct the normals.
	nglMatrixIsolateRotation(matrix, rotMatrix);
#endif
	nglRelease(quat);
}

- (unsigned short) makeIdentifierTo:(NSString *)effectKey
{
	// Materials.
	NGLMaterial *material;
	int identifier;
	
	// Effects.
	NSObject *efxObj;
	NSString *efxParam;
	NSString *efxMap;
	NSArray *efxArray;
	DAEEffect *effect;
	
	// Images.
	NSString *imageFile;
	DAEImage *image;
	
	// Tries to find the material with the same key in the material library.
	// If the material was not found, starts the creation of a new one.
	if (!(material = [_material materialWithName:effectKey]))
	{
		// Initializes a new material instance.
		material = [[NGLMaterial alloc] init];
		material.name = effectKey;
		material.identifier = identifier = ++_mtlCount;
		
		// Gets the effect for the informed key in the effects storage.
		effect = [_daeEffects objectForKey:effectKey];
		
		// Loop through each effect element in the current effect.
		for (efxParam in effect.material)
		{
			// Gets the current effect element.
			efxObj = [effect.material objectForKey:efxParam];
			
			// If the current element is a NSString, it represents a texture map.
			if ([efxObj isKindOfClass:[NSString class]])
			{
				efxMap = (NSString *)efxObj;
				
				// Takes the imagem from the image storage.
				image = [_daeImages objectForKey:efxMap];
				
				// Extra step to old softwares and COLLADA formats which uses redundant references
				// to the images in the image storage.
				if (image == nil)
				{
					efxMap = [effect.crossParam objectForKey:efxMap];
					efxMap = [effect.crossParam objectForKey:efxMap];
					image = [_daeImages objectForKey:efxMap];
				}
				
				// Extracts the file name from the file path.
				imageFile = nglGetFile(image.url);
				
				// Checks the current effect element to right set the NGLMaterial element.
				// If no image file was found in the COLLADA XML context, generates an error.
				if (imageFile == nil)
				{
					_error.message = [NSString stringWithFormat:DAE_ERROR_NULL_REF,effectKey];
				}
				else if ([efxParam isEqualToString:DAE_EFX_AMBIENT])
				{
					material.ambientMap = [self makeMapTo:imageFile];
				}
				else if ([efxParam isEqualToString:DAE_EFX_DIFFUSE])
				{
					material.diffuseMap = [self makeMapTo:imageFile];
				}
				else if ([efxParam isEqualToString:DAE_EFX_EMISSION])
				{
					material.emissiveMap = [self makeMapTo:imageFile];
				}
				else if ([efxParam isEqualToString:DAE_EFX_SPECULAR])
				{
					material.specularMap = [self makeMapTo:imageFile];
				}
				else if ([efxParam isEqualToString:DAE_EFX_SHININESS])
				{
					material.shininessMap = [self makeMapTo:imageFile];
				}
				else if ([efxParam isEqualToString:DAE_EFX_TRANSPARENT])
				{
					material.alphaMap = [self makeMapTo:imageFile];
				}
				else if ([efxParam isEqualToString:DAE_EFX_REFLECTIVE])
				{
					material.reflectiveMap = [self makeMapTo:imageFile];
				}
			}
			// Otherwise, treats the current element as a scalar or vector value.
			else
			{
				efxArray = (NSArray *)efxObj;
				
				// Checks the current effect element to right set the NGLMaterial element.
				// If no scalar or vector value was found in the COLLADA XML context, generates an error.
				if (efxArray == nil)
				{
					_error.message = [NSString stringWithFormat:DAE_ERROR_NULL_REF,effectKey];
				}
				else if ([efxParam isEqualToString:DAE_EFX_AMBIENT])
				{
					material.ambientColor = [self makeColorTo:efxArray];
				}
				else if ([efxParam isEqualToString:DAE_EFX_DIFFUSE])
				{
					material.diffuseColor = [self makeColorTo:efxArray];
				}
				else if ([efxParam isEqualToString:DAE_EFX_EMISSION])
				{
					material.emissiveColor = [self makeColorTo:efxArray];
				}
				else if ([efxParam isEqualToString:DAE_EFX_SPECULAR])
				{
					material.specularColor = [self makeColorTo:efxArray];
				}
				else if ([efxParam isEqualToString:DAE_EFX_SHININESS])
				{
					material.shininess = [self makeFloatTo:efxArray];
				}
				else if ([efxParam isEqualToString:DAE_EFX_TRANSPARENT])
				{
					NGLvec4 color = [self makeColorTo:efxArray];
					material.alpha = ((1 - color.x) + (1 - color.y) + (1 - color.z)) / 3;
				}
				else if ([efxParam isEqualToString:DAE_EFX_TRANSPARENCY])
				{
					material.alpha = 1 - [self makeFloatTo:efxArray];
				}
				else if ([efxParam isEqualToString:DAE_EFX_REFLECTIVITY])
				{
					material.reflectiveLevel = [self makeFloatTo:efxArray];
				}
				else if ([efxParam isEqualToString:DAE_EFX_REFRACTION])
				{
					material.refraction = [self makeFloatTo:efxArray];
				}
			}
		}
		
		// Adds the brand new material to the materials library.
		[_material addMaterial:material];
		nglRelease(material);
	}
	else
	{
		identifier = material.identifier;
	}
	
	return identifier;
}

- (void) parseNode:(DAEVisualNode *)daeNode
{
	// Ignores null nodes. A null node could be caught if there is in COLLADA XML an invalid
	// reference to a node in the library.
	if (daeNode == nil)
	{
		return;
	}
	
	// Nodes.
	NSString *instanceNode;
	DAEVisualNode *subNode;
	
	// Geometries.
	NSString *geometryKey;
	NSDictionary *instanceGeometry;
	DAEGeometry *daeGeometry;
	
	// Materials.
	int identifier;
	NSString *materialKey;
	DAEMaterial *daeMaterial;
	
	// Polygons (primitives) and its structures.
	int sourceOrder, sourceStride, sourceOffset;
	NSDictionary *polygon;
	NSDictionary *source;
	NSString *sourceId;
	NSArray *array;
	
	// Transformations.
	NGLmat4 matrix, rotMatrix;
	
	// Vertices, Texcoords and Normals.
	NGLvec3 v;
	NGLvec2 vt;
#ifdef kDAENormals
	NGLvec3 vn;
#endif
	
	// Faces.
	int faceStride, faceLimit, faceLoop;
	int firstIndex;
	NSDictionary *input;
	NSEnumerator *limits;
	NSNumber *limit;
	
	// Loop elements.
	NSUInteger i, length;
	NSUInteger j, lengthJ;
	
	// Gets the transformation matrices for this node. If this node has a parent node, the final
	// matrix and rotation matrix will take into consideration the parent transformations.
	[self defineMatricesTo:daeNode final:matrix rotation:rotMatrix];
	
	// Loops through all geometries instances in the current node.
	for (geometryKey in daeNode.geometries)
	{
		// Takes the real geometry stored in the geometry library.
		instanceGeometry = [daeNode.geometries objectForKey:geometryKey];
		daeGeometry = [_daeGeometries objectForKey:geometryKey];
		
		// Ignores null geometries. A null geometry could be caught if its
		// geometric element is not supported by NGLParserDAE or if it has wrong "id".
		if(daeGeometry == nil)
		{
			continue;
		}
		
		// Updates the faces group based on current geometry.
		// AS to COLLADA XML, each geometry instance can has only one material bound.
		// Each geometry represents a surface onto a mesh to NinevehGL.
		[self updateGroups];
		
		// Loops through all polygons in the current geometry.
		for (polygon in daeGeometry.polygons)
		{
			//*************************
			//	Materials
			//*************************
			
			// Gets the correct material key to this polygon.
			// If no material was assigned to this polygon, creates a new one.
			materialKey = [polygon objectForKey:NGL_MATERIAL];
			if(materialKey != nil)
			{
				materialKey = [instanceGeometry objectForKey:materialKey];
				daeMaterial = [_daeMaterials objectForKey:materialKey];
				materialKey = daeMaterial.url;
			}
			else
			{
				materialKey = [NSString stringWithFormat:@"DAEMaterial-%i", _mtlCount];
			}
			
			// Retrieves the identifier to the referenced material.
			// If the material doesn't exist yet, creates it.
			identifier =  [self makeIdentifierTo:materialKey];
			
			//*************************
			//	Surfaces
			//*************************
			
			// Creates a new surface to deal with this polygon.
			nglRelease(_currentSurface);
			_currentSurface = [[NGLSurface alloc] initWithStart:_facesCount length:0 identifier:identifier];
			
			// Adds the created surface to the surfaces library.
			[_surface addSurface:_currentSurface];
			
			//*************************
			//	Vertices
			//*************************
			
			sourceId = daeGetId([[polygon objectForKey:DAE_VERTEX] objectForKey:DAE_ATT_SOURCE]);
			
			// The "VERTEX" semantic is mandatory to any kind of polygon.
			if (sourceId == nil)
			{
				_error.message = [NSString stringWithFormat:DAE_ERROR_NO_VERTEX, geometryKey];
			}
			
			// Checks if the "VERTEX" semantic reffers against the vertices node or source directly.
			if ([daeGeometry.verticesId isEqualToString:sourceId])
			{
				sourceId = [daeGeometry.vertices objectForKey:DAE_POSITION];
			}
			
			// Gets the correct source refferenced by the "VERTEX" semantic.
			source = [daeGeometry.sources objectForKey:sourceId];
			
			// Checks if the source exist in COLLADA XML context.
			if (source == nil)
			{
				_error.message = [NSString stringWithFormat:DAE_ERROR_NULL_REF, sourceId];
			}
			
			// Gets the array from the source.
			array = [source objectForKey:NGL_ARRAY];
			
			// Opitional parameters Order, Stride and Offset.
			sourceOrder = [[source objectForKey:NGL_ORDER] intValue];
			sourceStride = [[source objectForKey:NGL_STRIDE] intValue];
			sourceOffset = [[source objectForKey:NGL_OFFSET] intValue];
			sourceOrder = (sourceOrder == 0) ? kDefaultOrder : sourceOrder;
			sourceStride = (sourceStride == 0) ? kDefaultStrideV : sourceStride;
			
			length = [array count];
			for (i = sourceOffset; i < length; i += sourceStride)
			{
				v.x = [[array objectAtIndex:i + (sourceOrder >> 16 & 0xFF)] floatValue];
				v.y = [[array objectAtIndex:i + (sourceOrder >> 8 & 0xFF)] floatValue];
				v.z = [[array objectAtIndex:i + (sourceOrder >> 0 & 0xFF)] floatValue];
				
				// Applies all transformations to each vertex.
				v = nglVec3ByMatrixTransposed(v, matrix);
				
				_vertices = realloc(_vertices, ++_vCount * NGL_SIZE_VEC4);
				float *vertices = _vertices + ((_vCount - 1) * 4);
				
				*vertices++ = v.x;
				*vertices++ = v.y;
				*vertices++ = v.z;
				*vertices = 1.0f;
			}
			
			//*************************
			//	Texture Coordinates
			//*************************
			
			// Gets the correct TEXCOORD source.
			// It could lie directly in the polygons input or in the vertices inputs.
			sourceId = daeGetId([[polygon objectForKey:DAE_TEXCOORD] objectForKey:DAE_ATT_SOURCE]);
			sourceId = (sourceId == nil) ? [daeGeometry.vertices objectForKey:DAE_TEXCOORD] : sourceId;
			
			// Gets the correct source refferenced by the "TEXCOORD" semantic.
			source = [daeGeometry.sources objectForKey:sourceId];
			
			_hasTexcoord = (source != nil);
			
			if (_hasTexcoord)
			{
				// Gets the array from the source.
				array = [source objectForKey:NGL_ARRAY];
				
				// Opitional parameters Order, Stride and Offset.
				sourceOrder = [[source objectForKey:NGL_ORDER] intValue];
				sourceStride = [[source objectForKey:NGL_STRIDE] intValue];
				sourceOffset = [[source objectForKey:NGL_OFFSET] intValue];
				sourceOrder = (sourceOrder == 0) ? kDefaultOrder : sourceOrder;
				sourceStride = (sourceStride == 0) ? kDefaultStrideVT : sourceStride;
				
				length = [array count];
				for (i = sourceOffset; i < length; i += sourceStride)
				{
					vt.x = [[array objectAtIndex:i + (sourceOrder >> 16 & 0xFF)] floatValue];
					vt.y = [[array objectAtIndex:i + (sourceOrder >> 8 & 0xFF)] floatValue];
					
					_texcoords = realloc(_texcoords, ++_tCount * NGL_SIZE_VEC2);
					float *texcoord = _texcoords + ((_tCount - 1) * 2);
					
					*texcoord++ = vt.x;
					*texcoord = vt.y;
				}
			}
			
#ifdef kDAENormals
			//*************************
			//	Normals
			//*************************
			
			// Gets the correct NORMAL source.
			// It could lie directly in the polygons input or in the vertices inputs.
			sourceId = daeGetId([[polygon objectForKey:DAE_NORMAL] objectForKey:DAE_ATT_SOURCE]);
			sourceId = (sourceId == nil) ? [daeGeometry.vertices objectForKey:DAE_NORMAL] : sourceId;
			
			// Gets the correct source refferenced by the "NORMAL" semantic.
			source = [daeGeometry.sources objectForKey:sourceId];
			
			_hasNormal = (source != nil);
			
			if (_hasNormal)
			{
				// Gets the array from the source.
				array = [source objectForKey:NGL_ARRAY];
				
				// Opitional parameters Order, Stride and Offset.
				sourceOrder = [[source objectForKey:NGL_ORDER] intValue];
				sourceStride = [[source objectForKey:NGL_STRIDE] intValue];
				sourceOffset = [[source objectForKey:NGL_OFFSET] intValue];
				sourceOrder = (sourceOrder == 0) ? kDefaultOrder : sourceOrder;
				sourceStride = (sourceStride == 0) ? kDefaultStrideVN : sourceStride;
				
				length = [array count];
				for (i = sourceOffset; i < length; i += sourceStride)
				{
					vn.x = [[array objectAtIndex:i + (sourceOrder >> 16 & 0xFF)] floatValue];
					vn.y = [[array objectAtIndex:i + (sourceOrder >> 8 & 0xFF)] floatValue];
					vn.z = [[array objectAtIndex:i + (sourceOrder >> 0 & 0xFF)] floatValue];
					
					// Applies only the rotations transformations to each normal.
					// Normals are always given in local space and must be adjusted only with rotations.
					vn = nglVec3Normalize(nglVec3ByMatrixTransposed(vn, rotMatrix));
					
					_normals = realloc(_normals, ++_nCount * NGL_SIZE_VEC3);
					float *normals = _normals + ((_nCount - 1) * 3);
					
					*normals++ = vn.x;
					*normals++ = vn.y;
					*normals = vn.z;
				}
			}
#endif
			//*************************
			//	Faces
			//*************************
			
			// Gets array of faces to construct the polygon.
			array = [polygon objectForKey:NGL_ARRAY];
			
			// Gets the face stride and limit of each polygon.
			faceStride = [[polygon objectForKey:NGL_STRIDE] intValue];
			limits = [[polygon objectForKey:NGL_LIMIT] objectEnumerator];
			limit = [limits nextObject];
			faceLimit = [limit intValue];
			
			// Gets the offset to vertex element.
			input = [polygon objectForKey:DAE_VERTEX];
			_vOffset = [[input objectForKey:DAE_ATT_OFFSET] intValue];
			
			// Gets the texcoord offset from the normal element.
			// Assumes the vertex offset if there is no explict texcoord element.
			input = [polygon objectForKey:DAE_TEXCOORD];
			_vtOffset = (input != nil) ? [[input objectForKey:DAE_ATT_OFFSET] intValue] : _vOffset;
#ifdef kDAENormals
			// Gets the normal offset from the normal element.
			// Assumes the vertex offset if there is no explict normal element.
			input = [polygon objectForKey:DAE_NORMAL];
			_vnOffset = (input != nil) ? [[input objectForKey:DAE_ATT_OFFSET] intValue] : _vOffset;
#endif
			// Loops through each set of faces defined in COLLADA XML to the current polygon.
			length = [array count];
			for (i = 0; i < length; ++i)
			{
				// Transforms the face reference into a face array (NSArray).
				_polyFaces = [nglGetArray([array objectAtIndex:i]) retain];
				
				// Resets the face loop and first index.
				faceLoop = firstIndex = 0;
				
				// Loops through each value in the faces array respecting the stride.
				lengthJ = [_polyFaces count];
				for (j = 0; j < lengthJ; j += faceStride)
				{
					// If the current face forms a polygon which has more than 3 vertices,
					// re-constructs the current face to turn it into multiple triangles.
					if (faceLoop >= 3)
					{
						[self defineFaceTo:firstIndex];
						[self defineFaceTo:(int)j - faceStride];
					}
					
					// Processes the current face.
					[self defineFaceTo:(int)j];
					
					// Sums one more vertex to the current face.
					++faceLoop;
					
					// Checks if the current face is complete.
					if (faceLoop == faceLimit)
					{
						// Dealing with lines, lines will be transformed into triangles.
						if (faceLimit == 2)
						{
							[self defineFaceTo:firstIndex];
						}
						
						// Gets information to the next face.
						firstIndex = (int)j + 1;
						faceLoop = 0;
						faceLimit = (limit = [limits nextObject]) ? [limit intValue] : faceLimit;
					}
				}
				
				// Releases the last set of polygon faces.
				[_polyFaces release];
			}
		}
	}
	
	// Processes each subnode in the current node.
	for (subNode in daeNode.nodes)
	{
		[self parseNode:subNode];
	}
	
	// Processes each referenced node instance in the current node.
	for (instanceNode in daeNode.instances)
	{
		subNode = [_daeAllNodes objectForKey:instanceNode];
		subNode.parent = daeNode.selfId;
		
		[self parseNode:subNode];
	}
}

- (void) parseDAE
{
	// Settings.
	_vCount = _tCount = _nCount = 0;
	_gCount = _facesCount = 0;
	_facesStride = 3;
	
	// Allocates the temporary variables to parse the DAE.
	_transformations = [[NSMutableDictionary alloc] init];
	_matrices = malloc(1);
	
	// Prepares node enumerator.
	// Only the top parent node from the visual scenes library will be processed.
	DAEVisualNode *daeNode;
	
	// Loops through all most top nodes.
	for (daeNode in _daeSceneNodes)
	{
		// Canceled status.
		if (_canceled)
		{
			break;
		}
		
		[self parseNode:daeNode];
	}
	
	// Defines the final stride to the array of structures.
	[self defineStride];
	
	//  Check for faces count.
	if (_facesCount == 0)
	{
		_error.message = DAE_ERROR_NO_FACES;
	}
	
	// Frees the memories.
	int i;
	int length = _mCount;
	for (i = 0; i < length; ++i)
	{
		nglFree(_matrices[i]);
	}
	nglFree(_matrices);
	
	nglRelease(_transformations);
}

- (void) parserXML
{
	// Avoids processing of null elements.
	// This happens when NSXMLParser encounter a content without parent element.
	if (_element == nil)
	{
		return;
	}
	
	//TODO Is 100% security? even to "value\nvalue" (???)
	// Trims blank lines between the content.
	NSString *content = [_content stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	// Deals with each phase separately. The order was choosen by optimize the performance based
	// on the most frequent nodes in COLLADA XML.
	switch (_phase)
	{
		//*************************
		//	Library Geometries
		//*************************
		case DaePhaseGeometry:
			// Node <geometry> [1,N]
			if ([_element isEqualToString:DAE_GEO])
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_ID];
				
				// Releases any previous geometry to avoid incorrect storages.
				nglRelease(_actualGeometry);
				
				// The "id" is not mandatory, but a geometry without an "id" becomes a null reference.
				if (_idTemp == nil)
				{
					_error.message = [NSString stringWithFormat:DAE_ERROR_NO_ID, DAE_GEO];
					return;
				}
				
				// Allocates a new Geometry to work on it.
				_actualGeometry = [[DAEGeometry alloc] init];
				
				// Places the new geometry into the Geometry storage.
				[_daeGeometries setObject:_actualGeometry forKey:_idTemp];
			}
			// Node <source> [1,N]
			else if ([_element isEqualToString:DAE_SOURCE])
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_ID];
				
				// Releases any previous source to avoid incorrect storages.
				nglRelease(_tempSource);
				
				// The "id" attribute is mandatory.
				if (_idTemp == nil)
				{
					_error.message = [NSString stringWithFormat:DAE_ERROR_NO_ID, DAE_SOURCE];
					return;
				}
				
				// Prepares a temporary source to work on it.
				_tempSource = [[NSMutableDictionary alloc] init];
				
				// Places the temporary source into the actual geometry.
				[_actualGeometry.sources setObject:_tempSource forKey:_idTemp];
			}
			// Node <float_array> [0,1]
			else if ([_element isEqualToString:DAE_GEO_ARRAY])
			{
				[_tempSource setObject:nglGetArray(content) forKey:NGL_ARRAY];
			}
//**************************************************
			//*
			// The "accessor" and "param" nodes are optinals.
			// Node <accessor> [0,1]
			else if ([_element isEqualToString:DAE_GEO_ACCESSOR])
			{
				// Take the offset, offset is not mandatory, so if it doesn't exist, it will be 0.
				int offset = [[_attributes objectForKey:DAE_ATT_OFFSET] intValue];
				
				[_tempSource setObject:[NSNumber numberWithInt:0] forKey:NGL_STRIDE];
				[_tempSource setObject:[NSNumber numberWithInt:offset] forKey:NGL_OFFSET];
			}
			// Node <param> [0,N]
			else if ([_element isEqualToString:DAE_GEO_PARAM])
			{
				// The name is mandatory in param.
				_idTemp = [_attributes objectForKey:DAE_ATT_NAME];
				
				// Retrieves the last order and stride.
				int order = [[_tempSource objectForKey:NGL_ORDER] intValue];
				int stride = [[_tempSource objectForKey:NGL_STRIDE] intValue];
				
				// Prepares the order to be X,Y,Z and S,T.
				// This steps include binary NinevehGL logic to deal with 3 elements.
				// Which an hexadecimal number could represent 0xXXYYZZ or 0xSSTTWW
				if ([_idTemp isEqualToString:DAE_X] || [_idTemp isEqualToString:DAE_S])
				{
					order = order | (DaeOrder0 << (16 - stride * 8));
				}
				else if ([_idTemp isEqualToString:DAE_Y] || [_idTemp isEqualToString:DAE_T])
				{
					order = order | (DaeOrder1 << (16 - stride * 8));
				}
				else if ([_idTemp isEqualToString:DAE_Z])
				{
					order = order | (DaeOrder2 << (16 - stride * 8));
				}
				
				// Adds one more stride to each new element.
				++stride;
				
				// Updates the current order and stride.
				[_tempSource setObject:[NSNumber numberWithInt:order] forKey:NGL_ORDER];
				[_tempSource setObject:[NSNumber numberWithInt:stride] forKey:NGL_STRIDE];
			}
			//*/
//**************************************************
			// Node <vertices> [1]
			else if ([_element isEqualToString:DAE_GEO_VERTICES])
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_ID];
				
				// The "id" attribute is mandatory.
				if (_idTemp == nil)
				{
					_error.message = [NSString stringWithFormat:DAE_ERROR_NO_ID, DAE_GEO_VERTICES];
				}
				
				// Retains the parent elements to make distinction between inputs from vertices
				// and inputs from primitives elements.
				daeSetString(&_parent, _element);
				
				// Stores the vertices id, it's unique.
				_actualGeometry.verticesId = _idTemp;
			}
			// Node <input> [1,N]
			else if ([_element isEqualToString:DAE_GEO_INPUT] && [_parent isEqualToString:DAE_GEO_VERTICES])
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_SEMANTIC];
				_sidTemp = [_attributes objectForKey:DAE_ATT_SOURCE];
				
				// The "semantic" and "source" attributes are mandatory.
				if (_idTemp == nil || _sidTemp == nil)
				{
					_error.message = DAE_ERROR_NO_SS;
				}
				
				// Stores the entire input data.
				[_actualGeometry.vertices setObject:daeGetId(_sidTemp) forKey:_idTemp];
			}
			// Node <lines>, <polygons>, <polylist>, <triangles> [0,N]
			else if ([_element isEqualToString:DAE_GEO_POLYGONS] ||
					 [_element isEqualToString:DAE_GEO_POLY_LIST] ||
					 [_element isEqualToString:DAE_GEO_TRIANGLES] ||
					 [_element isEqualToString:DAE_GEO_LINES]) //
			{
				NSArray *polygonLimit = nil;
				
				_idTemp = [_attributes objectForKey:DAE_ATT_MATERIAL];
				_sidTemp = [_attributes objectForKey:DAE_ATT_COUNT];
				
				// Releases any previous polygons and arrays to avoid incorrect storages.
				nglRelease(_tempPolygon);
				nglRelease(_tempArray);
				
				// Discards polygons with no data inside.
				if ([_sidTemp intValue] == 0)
				{
					return;
				}
				
				// Sets the number of faces that defines a polygon. Where -1 means undefined.
				if ([_element isEqualToString:DAE_GEO_POLYGONS] ||
					[_element isEqualToString:DAE_GEO_POLY_LIST])
				{
					polygonLimit = [NSArray arrayWithObject:[NSNumber numberWithInt:-1]];
				}
				else if ([_element isEqualToString:DAE_GEO_TRIANGLES])
				{
					polygonLimit = [NSArray arrayWithObject:[NSNumber numberWithInt:3]];
				}
				else if ([_element isEqualToString:DAE_GEO_LINES])
				{
					polygonLimit = [NSArray arrayWithObject:[NSNumber numberWithInt:2]];
				}
				
				// Retains the parent elements to make distinction between inputs from vertices
				// and inputs from primitives elements.
				daeSetString(&_parent, _element);
				
				// Prepares the temporary polygon and array of faces.
				_tempPolygon = [[NSMutableDictionary alloc] init];
				_tempArray = [[NSMutableArray alloc] init];
				
				// Defines the material to current polygons only if the material exist.
				if (_idTemp != nil)
				{
					[_tempPolygon setObject:_idTemp forKey:NGL_MATERIAL];
				}
				
				// Stores the array and polygon limit into the current polygon.
				[_tempPolygon setObject:_tempArray forKey:NGL_ARRAY];
				[_tempPolygon setObject:polygonLimit forKey:NGL_LIMIT];
				
				// Stores the current polygon into the current Geometry.
				[_actualGeometry.polygons addObject:_tempPolygon];
			}
			// Node <vcount> [0,1]
			else if ([_element isEqualToString:DAE_GEO_VCOUNT]) // - 1
			{
				// Updates the polygon limit. This is specific to the Polygon List primitive.
				NSArray *trianglesCount = nglGetArray(content);
				[_tempPolygon setObject:trianglesCount forKey:NGL_LIMIT];
			}
			// If the parent element is not supported by NGLParserDAE, skips this step.
			else if (_parent == nil)
			{
				return;
			}
			// Node <input> [0,N]
			else if ([_element isEqualToString:DAE_GEO_INPUT]) //
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_SEMANTIC];
				_sidTemp = [_attributes objectForKey:DAE_ATT_OFFSET];
				_urlTemp = daeGetId([_attributes objectForKey:DAE_ATT_SOURCE]);
				
				if (_idTemp == nil || _sidTemp == nil || _urlTemp == nil)
				{
					_error.message = DAE_ERROR_NO_SSO;
				}
				
				int stride = [[_tempPolygon objectForKey:NGL_STRIDE] intValue];
				int offset = [_sidTemp intValue];
				
				stride = (offset >= stride) ? offset + 1 : stride;
				
				// Just the last channel for each input.
				[_tempPolygon setObject:[NSNumber numberWithInt:stride] forKey:NGL_STRIDE];
				[_tempPolygon setObject:_attributes forKey:_idTemp];
			}
			// Node <p> [0,N]
			else if ([_element isEqualToString:DAE_GEO_INPUT_P]) //
			{
				[_tempArray addObject:content];
			}
			// Everything else.
			else
			{
				daeSetString(&_parent, nil);
			}
			break;
		//*************************
		//	Library Effects
		//*************************
		case DaePhaseEffects:
			// Node <effect> [1,N]
			if ([_element isEqualToString:DAE_EFX])
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_ID];
				
				// The "id" attribute is mandatory.
				if (_idTemp == nil)
				{
					_error.message = [NSString stringWithFormat:DAE_ERROR_NO_ID, DAE_EFX];
				}
				
				// Allocates a new Effect to work on it.
				nglRelease(_actualEffect);
				_actualEffect = [[DAEEffect alloc] init];
				
				// Places the new Effect into the geometry storage.
				[_daeEffects setObject:_actualEffect forKey:_idTemp];
			}
			// Node <color> [1]
			else if ([_element isEqualToString:DAE_EFX_COLOR])
			{
				// Stores the color reference into the current material with its parent parameter.
				[_actualEffect.material setObject:nglGetArray(content) forKey:_parent];
			}
			// Node <texture> [1]
			else if ([_element isEqualToString:DAE_EFX_TEXTURE])
			{
				_urlTemp = [_attributes objectForKey:DAE_ATT_TEXTURE];
				
				// The "texture" attribute is mandatory.
				if (_urlTemp == nil)
				{
					_error.message = DAE_ERROR_NO_TEXTURE;
				}
				
				// Stores the material reference into the current material with its parent parameter.
				[_actualEffect.material setObject:_urlTemp forKey:_parent];
			}
			// Node <float> [1]
			else if ([_element isEqualToString:DAE_EFX_FLOAT])
			{
				// Stores the scalar reference into the current material with its parent parameter.
				[_actualEffect.material setObject:nglGetArray(content) forKey:_parent];
			}
			// Node <newparam> [0,N]
			else if ([_element isEqualToString:DAE_NEW_PARAM])
			{
				// Deals with cross reference to the images.
				daeSetString(&_crossParam, [_attributes objectForKey:DAE_ATT_SID]);
			}
			// Node <init_from>, <source> [1]
			else if ([_element isEqualToString:DAE_SOURCE] || [_element isEqualToString:DAE_INIT_FROM])
			{
				// Deals with two steps of cross reference to the images.
				[_actualEffect.crossParam setObject:content forKey:_crossParam];
			}
			// Everything else.
			else
			{
				// Store the parent element to identify the desired effect.
				// Like ambient, diffuse, emission, specular, etc.
				daeSetString(&_parent, _element);
			}
			break;
		//*************************
		//	Library Materials
		//*************************
		case DaePhaseMaterials:
			// Node <material> [1,N]
			if ([_element isEqualToString:DAE_MAT])
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_ID];
				
				// Releases any previous material to avoid incorrect storages.
				nglRelease(_actualMaterial);
				
				// The "id" attribute is not mandatory, but without it, the new instance
				// will be a null reference in the COLLADA XML context.
				if (_idTemp == nil)
				{
					_error.message = [NSString stringWithFormat:DAE_ERROR_NO_ID, DAE_MAT];
				}
				
				// Prepares the temporary material to work on it.
				_actualMaterial = [[DAEMaterial alloc] init];
				
				// Places the current material into the material storage.
				[_daeMaterials setObject:_actualMaterial forKey:_idTemp];
			}
			// Node <instance_effect> [1]
			else if ([_element isEqualToString:DAE_MAT_EFX])
			{
				_urlTemp = daeGetId([_attributes objectForKey:DAE_ATT_URL]);
				
				// The "url" attribute is mandatory.
				if (_urlTemp == nil)
				{
					_error.message = DAE_ERROR_NO_URL;
				}
				
				// Stores an url to an effect into the current material.
				_actualMaterial.url = _urlTemp;
			}
			break;
		//*************************
		//	Library Images
		//*************************
		case DaePhaseImages:
			// Node <image> [1,N]
			if ([_element isEqualToString:DAE_IMG])
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_ID];
				
				// Releases any previous material to avoid incorrect storages.
				nglRelease(_actualImage);
				
				// The "id" attribute is not mandatory, but without it, the new instance
				// will be a null reference in the COLLADA XML context.
				if (_idTemp == nil)
				{
					_error.message = [NSString stringWithFormat:DAE_ERROR_NO_ID, DAE_IMG];
				}
				
				// Prepares the temporary image to work on it.
				_actualImage = [[DAEImage alloc] init];
				
				// Places the current image into the image storage.
				[_daeImages setObject:_actualImage forKey:_idTemp];
			}
			// Node <init_from> [0,1]
			else if ([_element isEqualToString:DAE_INIT_FROM])
			{
				// Stores an url to an image file into the current image.
				_actualImage.url = content;
			}
			break;
		//*************************
		//	Scenes and Nodes
		//*************************
		case DaePhaseVisualScenes:
		case DaePhaseNodes:
			// Node <node> [1,N]
			if ([_element isEqualToString:DAE_NODE])
			{
				_idTemp = [_attributes objectForKey:DAE_ATT_ID];
				
				// The "id" attribute is not mandatory, to avoid null references to NGLParserDAE,
				// assigns a default "id" to the new instance.
				if (_idTemp == nil)
				{
					_idTemp = [NSString stringWithFormat:@"DaeNode-%lu",(unsigned long)[_daeSceneNodes count]];
				}
				
				// Creates a new node object.
				nglRelease(_actualNode);
				_actualNode = [[DAEVisualNode alloc] init];
				_actualNode.selfId = _idTemp;
				_actualNode.parent = [_daeParentNodes lastObject];
				
				// Places the new node as a parent node to use in the next child node.
				[_daeParentNodes addObject:_idTemp];
				
				// If the current node is a child node, set its correct parent.
				if ([_daeParentNodes count] > 1)
				{
					DAEVisualNode *node = [_daeAllNodes objectForKey:_actualNode.parent];
					[node.nodes addObject:_actualNode];
				}
				// If the current node is a top node and lies in the visual scenes library, stores it
				// into the visual node storage.
				else if (_phase == DaePhaseVisualScenes)
				{
					[_daeSceneNodes addObject:_actualNode];
				}
				
				// Stores any node in the global node storage with its id.
				[_daeAllNodes setObject:_actualNode forKey:_idTemp];
			}
			// Node <matrix> [0,N]
			else if ([_element isEqualToString:DAE_NODE_MATRIX])
			{
				// Adds this transformation to the current node, saving its type.
				NSNumber *num = [NSNumber numberWithChar:DaeTransformMatrix];
				NSDictionary *dict = [NSDictionary dictionaryWithObject:nglGetArray(content) forKey:num];
				[_actualNode.transforms addObject:dict];
			}
			// Node <rotate> [0,N]
			else if ([_element isEqualToString:DAE_NODE_ROTATE])
			{
				// Adds this transformation to the current node, saving its type.
				NSNumber *num = [NSNumber numberWithChar:DaeTransformRotate];
				NSDictionary *dict = [NSDictionary dictionaryWithObject:nglGetArray(content) forKey:num];
				[_actualNode.transforms addObject:dict];
			}
			// Node <scale> [0,N]
			else if ([_element isEqualToString:DAE_NODE_SCALE])
			{
				// Adds this transformation to the current node, saving its type.
				NSNumber *num = [NSNumber numberWithChar:DaeTransformScale];
				NSDictionary *dict = [NSDictionary dictionaryWithObject:nglGetArray(content) forKey:num];
				[_actualNode.transforms addObject:dict];
			}
			// Node <translate> [0,N]
			else if ([_element isEqualToString:DAE_NODE_TRANSLATE])
			{
				// Adds this transformation to the current node, saving its type.
				NSNumber *num = [NSNumber numberWithChar:DaeTransformTranslate];
				NSDictionary *dict = [NSDictionary dictionaryWithObject:nglGetArray(content) forKey:num];
				[_actualNode.transforms addObject:dict];
			}
			// Node <instance_geometry> [0,N]
			else if ([_element isEqualToString:DAE_NODE_GEOMETRY])
			{
				_urlTemp = daeGetId([_attributes objectForKey:DAE_ATT_URL]);
				
				// Prepares a temporary source to work on it.
				nglRelease(_tempSource);
				_tempSource = [[NSMutableDictionary alloc] init];
				
				// Places this geometry reference into the current node.
				[_actualNode.geometries setObject:_tempSource forKey:_urlTemp];
			}
			// Node <instance_material> [1,N]
			else if ([_element isEqualToString:DAE_NODE_MATERIAL])
			{
				NSString *symbol = [_attributes objectForKey:DAE_ATT_SYMBOL];
				NSString *target = [_attributes objectForKey:DAE_ATT_TARGET];
				
				// The "symbol" and "target" attribute are mandatory.
				if (symbol == nil || target == nil)
				{
					_error.message = DAE_ERROR_NO_ST;
				}
				
				// Places the references to this material into the current source.
				[_tempSource setObject:daeGetId(target) forKey:symbol];
			}
			// Node <instance_node> [0,N]
			else if ([_element isEqualToString:DAE_NODE_NODE])
			{
				// Places this node reference into the current node.
				[_actualNode.instances addObject:daeGetId([_attributes objectForKey:DAE_ATT_URL])];
			}
			break;
		//*************************
		//	Library Assets
		//*************************
		case DaePhaseAssets:
			// Node <unit> [0,1]
			if ([_element isEqualToString:DAE_UNIT])
			{
				
			}
			// Node <up_axis> [0,1]
			else if ([_element isEqualToString:DAE_UP])
			{
				if ([content isEqualToString:DAE_UP_Y])
				{
					_upAxis = DaeUpAxisY;
				}
				else if ([content isEqualToString:DAE_UP_Z])
				{
					_upAxis = DaeUpAxisZ;
				}
				else if ([content isEqualToString:DAE_UP_X])
				{
					_upAxis = DaeUpAxisX;
				}
			}
			break;
		default:
			break;
	}
	
	// Releases the retained element and attributes.
	nglRelease(_element);
	nglRelease(_attributes);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)element
   namespaceURI:(NSString *)namespace
  qualifiedName:(NSString *)name
	 attributes:(NSDictionary *)attributes
{
	// Parses the last XML node.
	[self parserXML];
	
	// Divides the XML parse in phases to optimize the performance.
	switch (_phase)
	{
		case DaePhaseNone:
			if ([element isEqualToString:DAE_LIB_GEO])
			{
				_phase = DaePhaseGeometry;
			}
			else if ([element isEqualToString:DAE_LIB_EFX])
			{
				_phase = DaePhaseEffects;
			}
			else if ([element isEqualToString:DAE_LIB_IMG])
			{
				_phase = DaePhaseImages;
			}
			else if ([element isEqualToString:DAE_LIB_MAT])
			{
				_phase = DaePhaseMaterials;
			}
			else if ([element isEqualToString:DAE_LIB_VSC])
			{
				_phase = DaePhaseVisualScenes;
			}
			else if ([element isEqualToString:DAE_LIB_NOD])
			{
				_phase = DaePhaseNodes;
			}
			else if ([element isEqualToString:DAE_LIB_ASS])
			{
				_phase = DaePhaseAssets;
			}
			break;
		default:
			break;
	}
	
	// Stores the current XML element and attributes.
	nglRelease(_element);
	nglRelease(_attributes);
	_element = [element retain];
	_attributes = [attributes retain];
	
	// Clears the current content.
	[_content setString:@""];
}

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)element
   namespaceURI:(NSString *)namespace
  qualifiedName:(NSString *)name
{
	// Canceled status.
	if (_canceled)
	{
		[parser abortParsing];
	}
	
	// Updates the loaded data.
	_loadedData = [parser lineNumber];
	
	// Parses the last XML node.
	[self parserXML];
	
	// Clears the phases when a parent top node is finished.
	switch (_phase)
	{
		case DaePhaseGeometry:
			if ([element isEqualToString:DAE_LIB_GEO])
			{
				_phase = DaePhaseNone;
			}
			break;
		case DaePhaseEffects:
			if ([element isEqualToString:DAE_LIB_EFX])
			{
				_phase = DaePhaseNone;
			}
			break;
		case DaePhaseImages:
			if ([element isEqualToString:DAE_LIB_IMG])
			{
				_phase = DaePhaseNone;
			}
			break;
		case DaePhaseMaterials:
			if ([element isEqualToString:DAE_LIB_MAT])
			{
				_phase = DaePhaseNone;
			}
			break;
		case DaePhaseVisualScenes:
		case DaePhaseNodes:
			if ([element isEqualToString:DAE_LIB_VSC])
			{
				_phase = DaePhaseNone;
			}
			else if ([element isEqualToString:DAE_LIB_NOD])
			{
				_phase = DaePhaseNone;
			}
			else if ([element isEqualToString:DAE_NODE])
			{
				[_daeParentNodes removeLastObject];
			}
			break;
		case DaePhaseAssets:
			if ([element isEqualToString:DAE_LIB_ASS])
			{
				_phase = DaePhaseNone;
			}
			break;
		default:
			break;
	}
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)content
{
	[_content appendString:content];
}
/*
- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	_error.message = [NSString stringWithFormat:DAE_ERROR_XML,parseError];
}
*/
#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) loadFile:(NSString *)named
{
	// Sets the file path.
	_finalPath = [nglGetPath(nglMakePath(named)) retain];
	
	// Initialize DAE storages.
	_daeGeometries = [[NSMutableDictionary alloc] init];
	_daeEffects = [[NSMutableDictionary alloc] init];
	_daeImages = [[NSMutableDictionary alloc] init];
	_daeMaterials = [[NSMutableDictionary alloc] init];
	_daeAllNodes = [[NSMutableDictionary alloc] init];
	_daeSceneNodes = [[NSMutableArray alloc] init];
	_daeParentNodes = [[NSMutableArray alloc] init];
	_content = [[NSMutableString alloc] init];
	
	// Sets the error header.
	_error.header = [NSString stringWithFormat:DAE_ERROR_HEADER, named];
	
	// Clears Nineveh materials and surfaces.
	[_material removeAll];
	[_surface removeAll];
	
	// Loads the file from the desired path.
	NSData *data = nglDataFromFile(named);
	
	// Gets total data.
	_loadedData = 0;
	_totalData = 0;
	NSString *source = nglSourceFromFile(named);
	NSRange range = NSMakeRange(0, 0);
	NSUInteger index, length = [source length];
	for (index = 0; index < length; ++_totalData)
	{
		range.location = index;
		index += [source lineRangeForRange:range].length;
	}
	
	// Parse the COLLADA XML file.
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setDelegate:self];
	[parser parse];
	
	// Parse the DAE structure extracted from XML.
	[self parseDAE];
	
	// Checks if the file exists.
	if (data == nil)
	{
		_error.message = DAE_ERROR_NO_FILE;
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
	
	// Releases the file path.
	nglRelease(_finalPath);
	
	// Releases DAE storages.
	nglRelease(_daeGeometries);
	nglRelease(_daeEffects);
	nglRelease(_daeImages);
	nglRelease(_daeMaterials);
	nglRelease(_daeSceneNodes);
	nglRelease(_daeAllNodes);
	nglRelease(_daeParentNodes);
	nglRelease(_content);
	
	// Releases actual storages.
	nglRelease(_actualGeometry);
	nglRelease(_actualEffect);
	nglRelease(_actualImage);
	nglRelease(_actualMaterial);
	nglRelease(_actualNode);
	
	// Releases the temporary storages.
	nglRelease(_tempSource);
	nglRelease(_tempPolygon);
	nglRelease(_tempArray);
}

- (void) dealloc
{
	// Frees the memories.
	nglFree(_faces);
	nglFree(_vertices);
	nglFree(_texcoords);
	nglFree(_normals);
	nglFree(_groups);
	
	[super dealloc];
}

@end