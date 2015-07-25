/*
 *	NGLVector.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 4/9/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLVector.h"

#pragma mark -
#pragma mark Fixed Functions
#pragma mark -
//**********************************************************************************************************
//
//  Fixed Functions
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Color Functions
//**************************************************
//	Color Functions
//**************************************************

NGLvec4 nglColorMake(float r, float g, float b, float a)
{
	r = nglClamp(r, 0.0f, 1.0f);
	g = nglClamp(g, 0.0f, 1.0f);
	b = nglClamp(b, 0.0f, 1.0f);
	a = nglClamp(a, 0.0f, 1.0f);
	
	NGLvec4 color = (NGLvec4){ r,g,b,a };
	
	return color;
}

NGLvec4 nglColorFromRGBA(unsigned short r, unsigned short g, unsigned short b, unsigned short a)
{
	return nglColorMake((float)r / 255.0f, (float)g / 255.0f, (float)b / 255.0f, (float)a / 255.0f);
}

NGLvec4 nglColorFromHexadecimal(unsigned int hex)
{
	return nglColorFromRGBA((hex >> 24) & 0xFF, (hex >> 16) & 0xFF, (hex >> 8) & 0xFF, (hex >> 0) & 0xFF);
}

NGLvec4 nglColorFromCGColor(CGColorRef cgColor)
{
	NGLvec4 color = kNGLvec4Zero;
	
	size_t numComponents = CGColorGetNumberOfComponents(cgColor);
	const CGFloat *components = CGColorGetComponents(cgColor);
	
	switch (numComponents)
	{
		case 2:
			color.r = color.g = color.b = components[0];
			color.a = components[1];
			break;
		case 4:
			color.r = components[0];
			color.g = components[1];
			color.b = components[2];
			color.a = components[3];
			break;
		default:
			break;
	}
	
	return color;
}

NGLvec4 nglColorFromUIColor(UIColor *uiColor)
{
	return nglColorFromCGColor(uiColor.CGColor);
}

UIColor *nglColorToUIColor(NGLvec4 color)
{
	return [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
}

unsigned int nglColorToHexadecimal(NGLvec4 color)
{
	NGLivec4 rgba = (NGLivec4){ color.r * 255.0f, color.g * 255.0f, color.b * 255.0f, color.a * 255.0f };
	
	return (rgba.r << 24) + (rgba.g << 16) + (rgba.b << 8) + (rgba.a);
}

BOOL nglColorIsNotBlack(NGLvec4 color)
{
	return (color.x != 0.0f || color.y != 0.0f || color.z != 0.0f);
}

#pragma mark -
#pragma mark Telemetry Functions
//**************************************************
//	Telemetry Functions
//**************************************************

NGLvec4 nglTelemetryIDToColor(unsigned int telemetryID)
{
	return (NGLvec4){ (telemetryID >> 8 & 0xFF) / 255.0f, (telemetryID & 0xFF) / 255.0f, 0.0f, 1.0f };
}

unsigned int nglTelemetryIDFromRGBA(NGLivec4 rgba)
{
	return (rgba.r << 8) + rgba.g;
}

unsigned int nglTelemetryIDFromColor(NGLvec4 color)
{
	return nglTelemetryIDFromRGBA((NGLivec4){ color.r * 255.0f, color.g * 255.0f, color.b, color.a });
}

#pragma mark -
#pragma mark Vec2 Functions
//**************************************************
//	Vec2 Functions
//**************************************************

NGLvec2 nglVec2Make(float x, float y)
{
	return (NGLvec2){ x, y };
}

NGLvec2 nglVec2FromCGPoint(CGPoint point)
{
	return (NGLvec2){ point.x, point.y };
}

CGPoint nglVec2ToCGPoint(NGLvec2 vec)
{
	return (CGPoint){ vec.x, vec.y };
}

BOOL nglVec2IsZero(NGLvec2 vec)
{
	return (vec.x == 0.0f && vec.y == 0.0f);
}

BOOL nglVec2IsEqual(NGLvec2 vecA, NGLvec2 vecB)
{
	return (vecA.x == vecB.x && vecA.y == vecB.y);
}

float nglVec2Length(NGLvec2 vec)
{
	return sqrtf(vec.x * vec.x + vec.y * vec.y);
}

NGLvec2 nglVec2Normalize(NGLvec2 vec)
{
	// Find the magnitude/length. This variable is called inverse magnitude (iMag)
	// because instead divide each element by this magnitude, let's do multiplication, is faster.
	float iMag = nglVec2Length(vec);
	
	// Avoid divisions by 0.
	if (iMag != 0.0f)
	{
		iMag = 1.0f / iMag;
		
		vec.x *= iMag;
		vec.y *= iMag;
	}
	
	return vec;
}

NGLvec2 nglVec2Cleared(NGLvec2 vec)
{
	NGLvec2 cleared;
	cleared.x = nglIsNaN(vec.x) ? 0.0f : vec.x;
	cleared.y = nglIsNaN(vec.y) ? 0.0f : vec.y;
	
	return cleared;
}

NGLvec2 nglVec2Add(NGLvec2 vecA, NGLvec2 vecB)
{
	return (NGLvec2){vecA.x + vecB.x, vecA.y + vecB.y};
}

NGLvec2 nglVec2Subtract(NGLvec2 vecA, NGLvec2 vecB)
{
	return (NGLvec2){vecA.x - vecB.x, vecA.y - vecB.y};
}

NGLvec2 nglVec2Multiply(NGLvec2 vecA, NGLvec2 vecB)
{
	return (NGLvec2){vecA.x * vecB.x, vecA.y * vecB.y};
}

NGLvec2 nglVec2Multiplyf(NGLvec2 vecA, float value)
{
	return (NGLvec2){vecA.x * value, vecA.y * value};
}

float nglVec2Dot(NGLvec2 vecA, NGLvec2 vecB)
{
	return vecA.x * vecB.x + vecA.y * vecB.y;
}

NGLvec2 nglVec2ByMatrix(NGLvec2 vec, NGLmat4 matrix)
{
	NGLvec2 result;
	
	result.x = vec.x * matrix[0] + vec.y * matrix[4] + matrix[12];
	result.y = vec.x * matrix[1] + vec.y * matrix[5] + matrix[13];
	
	return result;
}

NGLvec2 nglVec2ByMatrixTransposed(NGLvec2 vec, NGLmat4 matrix)
{
	NGLvec2 result;
	
	result.x = vec.x * matrix[0] + vec.y * matrix[1] + matrix[3];
	result.y = vec.x * matrix[4] + vec.y * matrix[5] + matrix[7];
	
	return result;
}

#pragma mark -
#pragma mark Vec3 Functions
//**************************************************
//	Vec3 Functions
//**************************************************

NGLvec3 nglVec3Make(float x, float y, float z)
{
	return (NGLvec3){ x, y, z };
}

BOOL nglVec3IsZero(NGLvec3 vec)
{
	return (vec.x == 0.0f && vec.y == 0.0f && vec.z == 0.0f);
}

BOOL nglVec3IsEqual(NGLvec3 vecA, NGLvec3 vecB)
{
	return (vecA.x == vecB.x && vecA.y == vecB.y && vecA.z == vecB.z);
}

float nglVec3Length(NGLvec3 vec)
{
	return sqrtf(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z);
}

NGLvec3 nglVec3Normalize(NGLvec3 vec)
{
	// Find the magnitude/length. This variable is called inverse magnitude (iMag)
	// because instead divide each element by this magnitude, let's do multiplication, is faster.
	float iMag = nglVec3Length(vec);
	
	// Avoid divisions by 0.
	if (iMag != 0.0f)
	{
		iMag = 1.0f / iMag;
		
		vec.x *= iMag;
		vec.y *= iMag;
		vec.z *= iMag;
	}
	
	return vec;
}

NGLvec3 nglVec3Cleared(NGLvec3 vec)
{
	NGLvec3 cleared;
	cleared.x = nglIsNaN(vec.x) ? 0.0f : vec.x;
	cleared.y = nglIsNaN(vec.y) ? 0.0f : vec.y;
	cleared.z = nglIsNaN(vec.z) ? 0.0f : vec.z;
	
	return cleared;
}

NGLvec3 nglVec3Add(NGLvec3 vecA, NGLvec3 vecB)
{
	return (NGLvec3){vecA.x + vecB.x, vecA.y + vecB.y, vecA.z + vecB.z};
}

NGLvec3 nglVec3Subtract(NGLvec3 vecA, NGLvec3 vecB)
{
	return (NGLvec3){vecA.x - vecB.x, vecA.y - vecB.y, vecA.z - vecB.z};
}

NGLvec3 nglVec3Multiply(NGLvec3 vecA, NGLvec3 vecB)
{
	return (NGLvec3){vecA.x * vecB.x, vecA.y * vecB.y, vecA.z * vecB.z};
}

NGLvec3 nglVec3Multiplyf(NGLvec3 vecA, float value)
{
	return (NGLvec3){vecA.x * value, vecA.y * value, vecA.z * value};
}

float nglVec3Dot(NGLvec3 vecA, NGLvec3 vecB)
{
	return vecA.x * vecB.x + vecA.y * vecB.y + vecA.z * vecB.z;
}

NGLvec3 nglVec3Cross(NGLvec3 vecA, NGLvec3 vecB)
{
	NGLvec3 vec;
	
	vec.x = vecA.y * vecB.z - vecA.z * vecB.y;
	vec.y = vecA.z * vecB.x - vecA.x * vecB.z;
	vec.z = vecA.x * vecB.y - vecA.y * vecB.x;
	
	return vec;
}

NGLvec3 nglVec3ByMatrix(NGLvec3 vec, NGLmat4 matrix)
{
	NGLvec3 result;
	
	result.x = vec.x * matrix[0] + vec.y * matrix[4] + vec.z * matrix[8] + matrix[12];
	result.y = vec.x * matrix[1] + vec.y * matrix[5] + vec.z * matrix[9] + matrix[13];
	result.z = vec.x * matrix[2] + vec.y * matrix[6] + vec.z * matrix[10] + matrix[14];
	
	return result;
}

NGLvec3 nglVec3ByMatrixTransposed(NGLvec3 vec, NGLmat4 matrix)
{
	NGLvec3 result;
	
	result.x = vec.x * matrix[0] + vec.y * matrix[1] + vec.z * matrix[2] + matrix[3];
	result.y = vec.x * matrix[4] + vec.y * matrix[5] + vec.z * matrix[6] + matrix[7];
	result.z = vec.x * matrix[8] + vec.y * matrix[9] + vec.z * matrix[10] + matrix[11];
	
	return result;
}

NGLvec3 nglVec3FromMatrix(NGLmat4 matrix)
{
	NGLvec3 euler;
	
	// North pole.
	if (matrix[1] > 0.98f)
	{
		euler.y = atan2f(matrix[8], matrix[10]);
		euler.z = kNGL_PI2;
		euler.x = 0.0f;
	}
	// South pole
	else if (matrix[1] < -0.98f)
	{
		euler.y = atan2f(matrix[8], matrix[10]);
		euler.z = -kNGL_PI2;
		euler.x = 0.0f;
	}
	// Outside the poles.
	else
	{
		euler.y = atan2f(-matrix[2], matrix[0]);
		euler.z = asinf(matrix[1]);
		euler.x = atan2f(-matrix[9], matrix[5]);
	}
	
	// Converts values into degrees, they are in radians.
	euler.y = nglRadiansToDegrees(euler.y);
	euler.z = nglRadiansToDegrees(euler.z);
	euler.x = nglRadiansToDegrees(euler.x);
	
	return euler;
}

#pragma mark -
#pragma mark Vec4 Functions
//**************************************************
//	Vec4 Functions
//**************************************************

NGLvec4 nglVec4Make(float x, float y, float z, float w)
{
	return (NGLvec4){ x, y, z, w };
}

BOOL nglVec4IsZero(NGLvec4 vec)
{
	return (vec.x == 0.0f && vec.y == 0.0f && vec.z == 0.0f && vec.w == 0.0f);
}

BOOL nglVec4IsEqual(NGLvec4 vecA, NGLvec4 vecB)
{
	return (vecA.x == vecB.x && vecA.y == vecB.y && vecA.z == vecB.z && vecA.w == vecB.w);
}

float nglVec4Length(NGLvec4 vec)
{
	return sqrtf(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z + vec.w * vec.w);
}

NGLvec4 nglVec4Normalize(NGLvec4 vec)
{
	// Find the magnitude/length. This variable is called inverse magnitude (iMag)
	// because instead divide each element by this magnitude, let's do multiplication, is faster.
	float iMag = nglVec4Length(vec);
	
	// Avoid divisions by 0.
	if (iMag != 0.0f)
	{
		iMag = 1.0f / iMag;
		
		vec.x *= iMag;
		vec.y *= iMag;
		vec.z *= iMag;
		vec.w *= iMag;
	}
	
	return vec;
}

NGLvec4 nglVec4Cleared(NGLvec4 vec)
{
	NGLvec4 cleared;
	cleared.x = nglIsNaN(vec.x) ? 0.0f : vec.x;
	cleared.y = nglIsNaN(vec.y) ? 0.0f : vec.y;
	cleared.z = nglIsNaN(vec.z) ? 0.0f : vec.z;
	cleared.w = nglIsNaN(vec.w) ? 0.0f : vec.w;
	
	return cleared;
}

NGLvec4 nglVec4Add(NGLvec4 vecA, NGLvec4 vecB)
{
	return (NGLvec4){vecA.x + vecB.x, vecA.y + vecB.y, vecA.z + vecB.z, vecA.w + vecB.w};
}

NGLvec4 nglVec4Subtract(NGLvec4 vecA, NGLvec4 vecB)
{
	return (NGLvec4){vecA.x - vecB.x, vecA.y - vecB.y, vecA.z - vecB.z, vecA.w - vecB.w};
}

NGLvec4 nglVec4Multiply(NGLvec4 vecA, NGLvec4 vecB)
{
	return (NGLvec4){vecA.x * vecB.x, vecA.y * vecB.y, vecA.z * vecB.z, vecA.w * vecB.w};
}

NGLvec4 nglVec4Multiplyf(NGLvec4 vecA, float value)
{
	return (NGLvec4){vecA.x * value, vecA.y * value, vecA.z * value, vecA.w * value};
}

float nglVec4Dot(NGLvec4 vecA, NGLvec4 vecB)
{
	return vecA.x * vecB.x + vecA.y * vecB.y + vecA.z * vecB.z + vecA.w * vecB.w;
}

NGLvec4 nglVec4ByMatrix(NGLvec4 vec, NGLmat4 matrix)
{
	NGLvec4 result;
	
	result.x = vec.x * matrix[0] + vec.y * matrix[4] + vec.z * matrix[8] + vec.w * matrix[12];
	result.y = vec.x * matrix[1] + vec.y * matrix[5] + vec.z * matrix[9] + vec.w * matrix[13];
	result.z = vec.x * matrix[2] + vec.y * matrix[6] + vec.z * matrix[10] + vec.w * matrix[14];
	result.w = vec.x * matrix[3] + vec.y * matrix[7] + vec.z * matrix[11] + vec.w * matrix[15];
	
	return result;
}

NGLvec4 nglVec4ByMatrixTransposed(NGLvec4 vec, NGLmat4 matrix)
{
	NGLvec4 result;
	
	result.x = vec.x * matrix[0] + vec.y * matrix[1] + vec.z * matrix[2] + vec.w * matrix[3];
	result.y = vec.x * matrix[4] + vec.y * matrix[5] + vec.z * matrix[6] + vec.w * matrix[7];
	result.z = vec.x * matrix[8] + vec.y * matrix[9] + vec.z * matrix[10] + vec.w * matrix[11];
	result.w = vec.x * matrix[12] + vec.y * matrix[13] + vec.z * matrix[14] + vec.w * matrix[15];
	
	return result;
}