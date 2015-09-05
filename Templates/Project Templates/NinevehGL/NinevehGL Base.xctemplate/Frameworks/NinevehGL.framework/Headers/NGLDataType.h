/*
 *	NGLDataType.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 10/23/10.
 *  Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#pragma mark -
#pragma mark Enum Type Definitions
#pragma mark -
//**********************************************************************************************************
//
//	Enum Type Definitions
//
//**********************************************************************************************************

/*!
 *					Defines the format of the binary data.
 *	
 *	@var			NGLImageFileTypeJPG
 *					Represents the binary data formated as a JPG image file.
 *	
 *	@var			NGLImageFileTypePNG
 *					Represents the binary date formated as a PNG image file
 */
typedef enum
{
	NGLImageFileTypeNone		= 0x00,
	NGLImageFileTypeJPG			= 0x01,
	NGLImageFileTypePNG			= 0x02,
} NGLImageFileType;

/*!
 *					Instructs about which compression pixel format is/was used.
 *
 *	@var			NGLImageCompressionRGBA8888
 *					Represents unoptimized format, which use 4 bytes per pixel.
 *	
 *	@var			NGLImageCompressionRGB565
 *					Represents 2bpp formats which uses 5 bits to red channel, 6 to green and 5 to blue.
 *
 *	@var			NGLImageCompressionRGBA4444
 *					Represents 2bpp formats which uses 4 bits for each channel: red, green, blue and alpha.
 *
 *	@var			NGLImageCompressionPVRTC2
 *					Represents 2bpp formats from PVRTC.
 *
 *	@var			NGLImageCompressionPVRTC4
 *					Represents 4bpp formats from PVRTC.
 */
typedef enum
{
	NGLImageCompressionRGBA8888	= 0x00,
	NGLImageCompressionRGB565	= 0x01,
	NGLImageCompressionRGBA4444	= 0x02,
	NGLImageCompressionPVRTC2	= 0x03,
	NGLImageCompressionPVRTC4	= 0x04,
} NGLImageCompression;

/*!
 *					Defines the type of 3D file.
 *
 *					The NGLMesh class can load a couple of file types. These types are defined with this
 *					constant number.
 *	
 *	@var			NGL3DFileTypeOBJ
 *					Represents the WaveFront Object files (.obj).
 *	
 *	@var			NGL3DFileTypeDAE
 *					Represents the COLLADA files (.dae).
 *	
 *	@var			NGL3DFileTypeNGL
 *					Represents the NinevehGL Binary files (.ngl).
 */
typedef enum
{
	NGL3DFileTypeNone			= 0x00,
	NGL3DFileTypeOBJ			= 0x01,
	NGL3DFileTypeDAE			= 0x02,
	NGL3DFileTypeNGL			= 0x03,
} NGL3DFileType;

/*!
 *					The NinevehGL update status.
 *
 *					These values are for internal usage. They instruct the internal API about the updates
 *					on the superficial structure (Developer API).
 *	
 *	@var			NGLUpdateNone
 *					Represents no update(s).
 *
 *	@var			NGLUpdateSoft
 *					Represents update(s) with minor changes, taking small times and with light processing.
 *					Usually used to things that doesn't require recompilation.
 *
 *	@var			NGLUpdateMedium
 *					Represents update(s) with a medium cost, taking some time to complete and usually
 *					involves one piece of recompilation.
 *
 *	@var			NGLUpdateHard
 *					Represents update(s) for large things, taking a long time to complete and requiring
 *					full recompilation.
 */
typedef enum
{
	NGLUpdateNone				= 0x00,
	NGLUpdateSoft				= 0x01,
	NGLUpdateMedium				= 0x02,
	NGLUpdateHard				= 0x04,
} NGLUpdate;

#pragma mark -
#pragma mark Data Type Definitions
#pragma mark -
//**********************************************************************************************************
//
//	Data Type Definitions
//
//**********************************************************************************************************

/*!
 *					Basic definition of a vector of order 2 based on float data type.
 *	
 *	@var			NGLvec2::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLvec2::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 */
typedef union
{
	struct { float x, y; };
	struct { float r, g; };
	struct { float s, t; };
} NGLvec2;

/*!
 *					Basic definition of a vector of order 3 based on float data type.
 *	
 *	@var			NGLvec3::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLvec3::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 *
 *	@var			NGLvec3::z
 *					Represents the third component in a vector.
 *					You can use the letters "z", "b" or "p".
 */
typedef union
{
	struct { float x, y, z; };
	struct { float r, g, b; };
	struct { float s, t, p; };
} NGLvec3;

/*!
 *					Basic definition of a vector of order 4 based on float data type.
 *	
 *	@var			NGLvec4::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLvec4::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 *
 *	@var			NGLvec4::z
 *					Represents the third component in a vector.
 *					You can use the letters "z", "b" or "p".
 *
 *	@var			NGLvec4::w
 *					Represents the fourth component in a vector.
 *					You can use the letters "w", "a" or "q".
 */
typedef union
{
	struct { float x, y, z, w; };
	struct { float r, g, b, a; };
	struct { float s, t, p, q; };
} NGLvec4;

/*!
 *					Basic definition of a vector of order 2 based on boolean data type.
 *	
 *	@var			NGLbvec2::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLbvec2::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 */
typedef union
{
	struct { BOOL x, y; };
	struct { BOOL r, g; };
	struct { BOOL s, t; };
} NGLbvec2;

/*!
 *					Basic definition of a vector of order 3 based on boolean data type.
 *	
 *	@var			NGLbvec3::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLbvec3::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 *
 *	@var			NGLbvec3::z
 *					Represents the third component in a vector.
 *					You can use the letters "z", "b" or "p".
 */
typedef union
{
	struct { BOOL x, y, z; };
	struct { BOOL r, g, b; };
	struct { BOOL s, t, p; };
} NGLbvec3;

/*!
 *					Basic definition of a vector of order 4 based on boolean data type.
 *	
 *	@var			NGLbvec4::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLbvec4::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 *
 *	@var			NGLbvec4::z
 *					Represents the third component in a vector.
 *					You can use the letters "z", "b" or "p".
 *
 *	@var			NGLbvec4::w
 *					Represents the fourth component in a vector.
 *					You can use the letters "w", "a" or "q".
 */
typedef union
{
	struct { BOOL x, y, z, w; };
	struct { BOOL r, g, b, a; };
	struct { BOOL s, t, p, q; };
} NGLbvec4;

/*!
 *	@union			NGLivec2
 *	
 *					Basic definition of a vector of order 2 based on int data type.
 *	
 *	@var			NGLivec2::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLivec2::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 */
typedef union
{
	struct { int x, y; };
	struct { int r, g; };
	struct { int s, t; };
} NGLivec2;

/*!
 *	@union			NGLivec3
 *	
 *					Basic definition of a vector of order 3 based on int data type.
 *	
 *	@var			NGLivec3::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLivec3::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 *
 *	@var			NGLivec3::z
 *					Represents the third component in a vector.
 *					You can use the letters "z", "b" or "p".
 */
typedef union
{
	struct { int x, y, z; };
	struct { int r, g, b; };
	struct { int s, t, p; };
} NGLivec3;

/*!
 *					Basic definition of a vector of order 4 based on int data type.
 *	
 *	@var			NGLivec4::x
 *					Represents the first component in a vector.
 *					You can use the letters "x", "r" or "s".
 *	
 *	@var			NGLivec4::y
 *					Represents the second component in a vector.
 *					You can use the letters "y", "g" or "t".
 *
 *	@var			NGLivec4::z
 *					Represents the third component in a vector.
 *					You can use the letters "z", "b" or "p".
 *
 *	@var			NGLivec4::w
 *					Represents the fourth component in a vector.
 *					You can use the letters "w", "a" or "q".
 */
typedef union
{
	struct { int x, y, z, w; };
	struct { int r, g, b, a; };
	struct { int s, t, p, q; };
} NGLivec4;

/*!
 *					The basic representation of a ray. In fact it's a line formed by a origin vertex and
 *					a direction vector.
 *
 *	@see			NGLvec3
 *	
 *	@var			NGLray::origin
 *					Represents vertex at the origin of the ray/line.
 *
 *	@var			NGLray::direction
 *					Represents direction of the ray/line.
 */
typedef struct
{
	NGLvec3	origin;
	NGLvec3	direction;
} NGLray;

/*!
 *					The delimiter of a 3D box. This structure does not represent the box it self, just 
 *					indicates its limits, assuming there is no rotations in the box.
 *
 *	@see			NGLvec3
 *	
 *	@var			NGLbounds::min
 *					Represents minimum values of the delimiter in axis X, Y and Z.
 *
 *	@var			NGLbounds::max
 *					Represents maximum values of the delimiter in axis X, Y and Z.
 */
typedef struct
{
	NGLvec3	min;
	NGLvec3	max;
} NGLbounds;

/*!
 *					The basic 3D box structure. This is the box it self and it's composed by 8 vertices.
 *
 *					This basic structure doesn't make distinction between triangles nor polygons, it just
 *					hold the vertices' positions. It's useful for abstract 3D calculations, like
 *					bounding boxes. The vertices' indices should be defined as following:
 *
 *					<pre>
 *					               1 +------------+ 2
 *					                /|           /|
 *					               / |          / |               +y
 *					              /  |         /  |               |  -z
 *					             /   |        /   |               |  /
 *					          5 +------------+ 6  |               | /
 *					            |    |       |    |        -x ____|/_____ +x
 *					            |  0 +-------|----+ 3             |
 *					            |   /        |   /               /|
 *					            |  /         |  /               / |
 *					            | /          | /               /  |
 *					          4 +/-----------+/ 7             +z  -y
 *
 *					</pre>
 */
typedef NGLvec3 NGLbox[8];

/*!
 *					The bounding box structure. In NinevehGL the bounding box has 2 information, each one
 *					works as a cache to avoid redundant calculus.
 *
 *					The information are:
 *
 *						- Volume: Represents the size of the bounding box. Its values is always in relation
 *							to the origin of the world (0.0, 0.0, 0.0) and doesn't suffer the effects of
 *							the transformations (scale, rotation, translation);
 *						- Aligned: Axis-Aligned Bounding Box (also known as AABB), represents the bounding
 *							box that circunscribe the OBB (Oriented Bounding Box). The OBB represents the
 *							bounding box suffering the effects of the transformations.
 *
 *	@see			NGLbounds
 *	@see			NGLbox
 *	
 *	@var			NGLBoundingBox::volume
 *					Represents mesh volume without transformations.
 *
 *	@var			NGLBoundingBox::aligned
 *					Represents AABB (Axis-Aligned Bounding Box), the box that circunscribe the OBB.
 */
typedef struct
{
	NGLbox volume;
	NGLbounds aligned;
} NGLBoundingBox;

#pragma mark -
#pragma mark Constants Definitions
#pragma mark -
//**********************************************************************************************************
//
//	Constants Definitions
//
//**********************************************************************************************************


#pragma mark -
#pragma mark Vectors
//**************************************************
//	Vectors
//**************************************************

/*!
 *					The NGLvec2 with all values equal to 0.0.
 */
static const NGLvec2 kNGLvec2Zero = { 0.0f, 0.0f };

/*!
 *					The NGLvec3 with all values equal to 0.0.
 */
static const NGLvec3 kNGLvec3Zero = { 0.0f, 0.0f, 0.0f };

/*!
 *					The NGLvec4 with all values equal to 0.0.
 */
static const NGLvec4 kNGLvec4Zero = { 0.0f, 0.0f, 0.0f, 0.0f };

/*!
 *					The NGLivec2 with all values equal to 0.
 */
static const NGLivec2 kNGLivec2Zero = { 0, 0 };

/*!
 *					The NGLivec3 with all values equal to 0.
 */
static const NGLivec3 kNGLivec3Zero = { 0, 0, 0 };

/*!
 *					The NGLivec4 with all values equal to 0.
 */
static const NGLivec4 kNGLivec4Zero = { 0, 0, 0, 0 };

#pragma mark -
#pragma mark Colors
//**************************************************
//	Colors
//**************************************************

/*!
 *					Solid Full black.
 *					R = 0, G = 0, B = 0 and A = 255
 */
static const NGLvec4 kNGLColorBlack = { 0.0f, 0.0f, 0.0f, 1.0f };

/*!
 *					Solid Dark Gray.
 *					R = 85, G = 85, B = 85 and A = 255;
 */
static const NGLvec4 kNGLColorDarkGray = { 0.33f, 0.33f, 0.33f, 1.0f };

/*!
 *					Solid Light Gray.
 *					R = 170, G = 170, B = 170 and A = 255;
 */
static const NGLvec4 kNGLColorLightGray = { 0.66f, 0.66f, 0.66f, 1.0f };

/*!
 *					Solid White.
 *					R = 255, G = 255, B = 255 and A = 255;
 */
static const NGLvec4 kNGLColorWhite = { 1.0f, 1.0f, 1.0f, 1.0f };

/*!
 *					Solid Gray.
 *					R = 128, G = 128, B = 128 and A = 255;
 */
static const NGLvec4 kNGLColorGray = { 0.5f, 0.5f, 0.5f, 1.0f };

/*!
 *					Solid Red.
 *					R = 255, G = 0, B = 0 and A = 255;
 */
static const NGLvec4 kNGLColorRed = { 1.0f, 0.0f, 0.0f, 1.0f };

/*!
 *					Solid Green.
 *					R = 0, G = 255, B = 0 and A = 255;
 */
static const NGLvec4 kNGLColorGreen = { 0.0f, 1.0f, 0.0f, 1.0f };

/*!
 *					Solid Blue.
 *					R = 0, G = 0, B = 255 and A = 255;
 */
static const NGLvec4 kNGLColorBlue = { 0.0f, 0.0f, 1.0f, 1.0f };

/*!
 *					Solid Cyan.
 *					R = 0, G = 255, B = 255 and A = 255;
 */
static const NGLvec4 kNGLColorCyan = { 0.0f, 1.0f, 1.0f, 1.0f };

/*!
 *					Solid Yellow.
 *					R = 255, G = 255, B = 0 and A = 255;
 */
static const NGLvec4 kNGLColorYellow = { 1.0f, 1.0f, 0.0f, 1.0f };

/*!
 *					Solid Magenta.
 *					R = 255, G = 0, B = 255 and A = 255;
 */
static const NGLvec4 kNGLColorMagenta = { 1.0f, 0.0f, 1.0f, 1.0f };

/*!
 *					Solid Orange.
 *					R = 255, G = 128, B = 0 and A = 255;
 */
static const NGLvec4 kNGLColorOrange = { 1.0f, 0.5f, 0.0f, 1.0f };

/*!
 *					Solid Purple.
 *					R = 128, G = 0, B = 128 and A = 255;
 */
static const NGLvec4 kNGLColorPurple = { 0.5f, 0.0f, 0.5f, 1.0f };

/*!
 *					Solid Brown.
 *					R = 153, G = 102, B = 51 and A = 255;
 */
static const NGLvec4 kNGLColorBrown = { 0.6f, 0.4f, 0.2f, 1.0f };

/*!
 *					Transparent Black.
 *					R = 0, G = 0, B = 0 and A = 0;
 */
static const NGLvec4 kNGLColorClear = { 0.0f, 0.0f, 0.0f, 1.0f };

#pragma mark -
#pragma mark Others
//**************************************************
//	Others
//**************************************************

/*!
 *					The NGLray with all values equal to 0.0.
 */
static const NGLray kNGLrayZero = { { 0.0f, 0.0f, 0.0f }, { 0.0f, 0.0f, 0.0f } };

/*!
 *					The NGLbounds with all values equal to 0.0.
 */
static const NGLbounds kNGLboundsZero = { { 0.0f, 0.0f, 0.0f }, { 0.0f, 0.0f, 0.0f } };