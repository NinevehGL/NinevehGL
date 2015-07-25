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

#import "NGLRuntime.h"
#import "NGLDataType.h"
#import "NGLMatrix.h"
#import "NGLMath.h"

#pragma mark -
#pragma mark Color Functions
//**************************************************
//	Color Functions
//**************************************************

/*!
 *					This function generates a color based on RGBA parameters.
 *
 *					The colors in OpenGL should be clamped to (0.0, 1.0), so this function will clamp the
 *					values to that range automatically.
 *	
 *	@param			r
 *					The red channel/component of the color.
 *	
 *	@param			g
 *					The green channel/component of the color.
 *	
 *	@param			b
 *					The blue channel/component of the color.
 *	
 *	@param			a
 *					The alpha channel/component of the color.
 *
 *	@result			A NGLvec4 with the desired color.
 */
NGL_API NGLvec4 nglColorMake(float r, float g, float b, float a);

/*!
 *					This function generates a color based on RGBA values. Each value is in range [0, 255].
 *	
 *	@param			r
 *					The red channel/component of the color.
 *	
 *	@param			g
 *					The green channel/component of the color.
 *	
 *	@param			b
 *					The blue channel/component of the color.
 *	
 *	@param			a
 *					The alpha channel/component of the color.
 *
 *	@result			A NGLvec4 with the desired color.
 */
NGL_API NGLvec4 nglColorFromRGBA(unsigned short r, unsigned short g, unsigned short b, unsigned short a);

/*!
 *					This function generates a color based on an hexadecimal color. This color will be
 *					opaque, that means, its alpha component will be 1.0. The hexadecimal value must be in
 *					RGBA format (0xNNNNNNNN).
 *	
 *	@param			hex
 *					A color in hexadecimal notation (0xNNNNNNNN).
 *
 *	@result			A NGLvec4 with the desired color.
 */
NGL_API NGLvec4 nglColorFromHexadecimal(unsigned int hex);

/*!
 *					This function generates a color based on an CGColorRef, it must be in RGB color space.
 *	
 *	@param			cgColor
 *					A CGColorRef.
 *
 *	@result			A NGLvec4 with the desired color.
 */
NGL_API NGLvec4 nglColorFromCGColor(CGColorRef cgColor);

/*!
 *					This function generates a color based on an UIColor, it must be in RGB color space.
 *	
 *	@param			uiColor
 *					An UIColor instance.
 *
 *	@result			A NGLvec4 with the desired color.
 */
NGL_API NGLvec4 nglColorFromUIColor(UIColor *uiColor);

/*!
 *					This function generates an UIColor based on an NinevehGL color.
 *	
 *	@param			color
 *					A NGLvec4 with the RGBA information.
 *
 *	@result			An UIColor autorelease instance.
 */
NGL_API UIColor *nglColorToUIColor(NGLvec4 color);

/*!
 *					This function generates an hexadecimal color based on a NinevehGL color.
 *	
 *	@param			color
 *					A NGLvec4 with the color to convert.
 *
 *	@result			A color in hexadecimal notation for RGBA (0xNNNNNNNN).
 */
NGL_API unsigned int nglColorToHexadecimal(NGLvec4 color);

/*!
 *					Checks if the color is not a black one.
 *
 *					This check ignores the alpha channel/component, checking only the true colors.
 *	
 *	@param			color
 *					A NGLvec4 with the color to check.
 *
 *	@result			A BOOL data type indicating if the color is not black. Returns 0 if it's black.
 */
NGL_API BOOL nglColorIsNotBlack(NGLvec4 color);

#pragma mark -
#pragma mark Telemetry Functions
//**************************************************
//	Telemetry Functions
//**************************************************

/*!
 *					Converts a telemetry ID into a color representation.
 *
 *					The telemetry is a NinevehGL technique that encapsulates IDs using colors.
 *					The Telemetry can hold up to 3 different numerical components, as following:
 *						- ID: To ID is reserved 65.535 slots (16 bits);
 *						- Surface: To Surface is reserved 255 slots (8 bits);
 *						- Status: To Status is reserved 255 slots (8 bits).
 *
 *					The telemetry ID is encapsulated in the first two color channels (RG - Reg and Green).
 *	
 *	@param			telemetryID
 *					A NGLvec4 with the color to check.
 *
 *	@result			A NGLvec4 representing the color for this telemetry ID.
 */
NGL_API NGLvec4 nglTelemetryIDToColor(unsigned int telemetryID);

/*!
 *					Converts a RGBA color into telemetry ID.
 *
 *					The RGBA color must be in the range [0, 255].
 *	
 *	@param			rgba
 *					A NGLivec4 with the RGBA color.
 *
 *	@result			An unsigned int with the extracted telemetry ID.
 */
NGL_API unsigned int nglTelemetryIDFromRGBA(NGLivec4 rgba);

/*!
 *					Converts a color (NGLvec4) into telemetry ID.
 *
 *					The color must be in the range [0.0, 1.0].
 *	
 *	@param			color
 *					A NGLvec4 with the color.
 *
 *	@result			An unsigned int with the extracted telemetry ID.
 */
NGL_API unsigned int nglTelemetryIDFromColor(NGLvec4 color);

#pragma mark -
#pragma mark Vec2 Functions
//**************************************************
//	Vec2 Functions
//**************************************************

/*!
 *					Creates a new NGLvec2 structure based on float values.
 *	
 *	@param			x
 *					The value of X component.
 *	
 *	@param			y
 *					The value of Y component.
 *
 *	@result			A new NGLvec2 structure.
 */
NGL_API NGLvec2 nglVec2Make(float x, float y);

/*!
 *					Creates a new NGLvec2 structure based on CGPoint.
 *	
 *	@param			point
 *					A CGPoint structure.
 *
 *	@result			A new NGLvec2 structure.
 */
NGL_API NGLvec2 nglVec2FromCGPoint(CGPoint point);

/*!
 *					Creates a new CGPoint structure base on NGLvec2.
 *	
 *	@param			vec
 *					The NGLvec2 structure.
 *
 *	@result			A new CGPoint structure.
 */
NGL_API CGPoint nglVec2ToCGPoint(NGLvec2 vec);

/*!
 *					Checks if informed vector is null.
 *
 *					A vector is considered null if all its values are equal to 0.0.
 *	
 *	@param			vec
 *					A NGLvec2 to check.
 *
 *	@result			A BOOL data type indicating if the vector is null. Returns 1 if it's null.
 */
NGL_API BOOL nglVec2IsZero(NGLvec2 vec);

/*!
 *					Checks if informed vector A is equal to the vector B.
 *
 *					Two vectors are considered equals if all its values are equals.
 *	
 *	@param			vecA
 *					The vector A.
 *	
 *	@param			vecB
 *					The vector B.
 *
 *	@result			A BOOL data type indicating if the vectors are equals. Returns 1 if they are equals.
 */
NGL_API BOOL nglVec2IsEqual(NGLvec2 vecA, NGLvec2 vecB);

/*!
 *					Calculates the length of a vector.
 *
 *					The length of a vector, also known as magnitude, is calculated using the
 *					Pythagorean Theorem and represents the size of a vector.
 *
 *					<pre>
 *					           __    ___
 *					          /        /|
 *					         /        / |
 *					 Length /        / 
 *					       /        /  Vector
 *					      /__      /
 *					             {0.0, 0.0, 0.0}
 *
 *					</pre>
 *
 *					It's said "unit vector" that which has it's length equal to 1.0.
 *
 *	@param			vec
 *					The vector to extract its length.
 *
 *	@result			A float data type with its length.
 */
NGL_API float nglVec2Length(NGLvec2 vec);

/*!
 *					Normalizes the values inside a vector to make it an "unit vector".
 *
 *					It's said "unit vector" that which has it's length equal to 1.0.
 *
 *	@param			vec
 *					The vector to be normalized.
 *
 *	@result			The returning vector normalized.
 */
NGL_API NGLvec2 nglVec2Normalize(NGLvec2 vec);

/*!
 *					Indentifies NaN values and set them to 0 (zero).
 *
 *	@param			vec
 *					The vector.
 *
 *	@result			The returning cleared vector.
 */
NGL_API NGLvec2 nglVec2Cleared(NGLvec2 vec);

/*!
 *					Adds two vectors.
 *
 *					The sum of two vectors produces a new vector which has direction and magnitude in
 *					the middle of the originals.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning added vector.
 */
NGL_API NGLvec2 nglVec2Add(NGLvec2 vecA, NGLvec2 vecB);

/*!
 *					Subtracts vector B from the vector A.
 *
 *					The of parameters is important here. The subtraction is also known as distance.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning subtracted vector.
 */
NGL_API NGLvec2 nglVec2Subtract(NGLvec2 vecA, NGLvec2 vecB);

/*!
 *					Multiplies two vectors.
 *
 *					This is not the Cross product neither the Dot product. This function just multiply
 *					their scalar values.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning multiplied vector.
 */
NGL_API NGLvec2 nglVec2Multiply(NGLvec2 vecA, NGLvec2 vecB);

/*!
 *					Multiplies vector by a scalar value.
 *
 *					The scalar value is multiplied by each element of the vector.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			value
 *					The floating number.
 *
 *	@result			The returning multiplied vector.
 */
NGL_API NGLvec2 nglVec2Multiplyf(NGLvec2 vecA, float value);

/*!
 *					Finds the dot product of two vectors.
 *
 *					The dot product returns the cosine of the angle formed by two vectors.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			A float data type with the dot product.
 */
NGL_API float nglVec2Dot(NGLvec2 vecA, NGLvec2 vecB);

/*!
 *					Multiplies a vector by a matrix.
 *
 *					The matrix is always given as a 4x4 matrix, but the returning vector depends on the
 *					input vector type.
 *
 *	@param			vec
 *					The vector that will be multiplied by the matrix.
 *
 *	@param			matrix
 *					The matrix 4x4.
 *
 *	@result			A vector altered by the matrix.
 */
NGL_API NGLvec2 nglVec2ByMatrix(NGLvec2 vec, NGLmat4 matrix);

/*!
 *					Multiplies a vector by the transposed of a matrix, if the matrix is orthogonal, the
 *					transposed matrix is equal the its inverse.
 *
 *					The matrix is always given as a 4x4 matrix, but the returning vector depends on the
 *					input vector type.
 *
 *	@param			vec
 *					The vector that will be multiplied by the matrix.
 *
 *	@param			matrix
 *					The matrix 4x4.
 *
 *	@result			A vector altered by the matrix.
 */
NGL_API NGLvec2 nglVec2ByMatrixTransposed(NGLvec2 vec, NGLmat4 matrix);

#pragma mark -
#pragma mark Vec3 Functions
//**************************************************
//	Vec3 Functions
//**************************************************

/*!
 *					Creates a new NGLvec3 structure based on float values.
 *	
 *	@param			x
 *					The value of X component.
 *	
 *	@param			y
 *					The value of Y component.
 *	
 *	@param			z
 *					The value of Z component.
 *
 *	@result			A new NGLvec3 structure.
 */
NGL_API NGLvec3 nglVec3Make(float x, float y, float z);

/*!
 *					Checks if informed vector is null.
 *
 *					A vector is considered null if all its values are equal to 0.0.
 *	
 *	@param			vec
 *					A NGLvec2 to check.
 *
 *	@result			A BOOL data type indicating if the vector is null. Returns 1 if it's null.
 */
NGL_API BOOL nglVec3IsZero(NGLvec3 vec);

/*!
 *					Checks if informed vector A is equal to the vector B.
 *
 *					Two vectors are considered equals if all its values are equals.
 *	
 *	@param			vecA
 *					The vector A.
 *	
 *	@param			vecB
 *					The vector B.
 *
 *	@result			A BOOL data type indicating if the vectors are equals. Returns 1 if they are equals.
 */
NGL_API BOOL nglVec3IsEqual(NGLvec3 vecA, NGLvec3 vecB);

/*!
 *					Calculates the length of a vector.
 *
 *					The length of a vector, also known as magnitude, is calculated using the
 *					Pythagorean Theorem and represents the size of a vector.
 *
 *					<pre>
 *					           __    ___  X, Y, Z
 *					          /        /|
 *					         /        / |
 *					 Length /        / 
 *					       /        /  Vector
 *					      /__      /
 *					               0, 0, 0
 *
 *					</pre>
 *
 *					It's said "unit vector" that which has it's length equal to 1.0.
 *
 *	@param			vec
 *					The vector to extract its length.
 *
 *	@result			A float data type with its length.
 */
NGL_API float nglVec3Length(NGLvec3 vec);

/*!
 *					Normalizes the values inside a vector to make it an "unit vector".
 *
 *					It's said "unit vector" that which has it's length equal to 1.0.
 *
 *	@param			vec
 *					The vector to be normalized.
 *
 *	@result			The returning vector normalized.
 */
NGL_API NGLvec3 nglVec3Normalize(NGLvec3 vec);

/*!
 *					Indentifies NaN values and set them to 0 (zero).
 *
 *	@param			vec
 *					The vector.
 *
 *	@result			The returning cleared vector.
 */
NGL_API NGLvec3 nglVec3Cleared(NGLvec3 vec);

/*!
 *					Adds two vectors.
 *
 *					The sum of two vectors produces a new vector which has direction and magnitude in
 *					the middle of the originals.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning added vector.
 */
NGL_API NGLvec3 nglVec3Add(NGLvec3 vecA, NGLvec3 vecB);

/*!
 *					Subtracts vector B from the vector A.
 *
 *					The of parameters is important here. The subtraction is also known as distance.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning subtracted vector.
 */
NGL_API NGLvec3 nglVec3Subtract(NGLvec3 vecA, NGLvec3 vecB);

/*!
 *					Multiplies two vectors.
 *
 *					This is not the Cross product neither the Dot product. This function just multiply
 *					their scalar values.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning multiplied vector.
 */
NGL_API NGLvec3 nglVec3Multiply(NGLvec3 vecA, NGLvec3 vecB);

/*!
 *					Multiplies vector by a scalar value.
 *
 *					The scalar value is multiplied by each element of the vector.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			value
 *					The floating number.
 *
 *	@result			The returning multiplied vector.
 */
NGL_API NGLvec3 nglVec3Multiplyf(NGLvec3 vecA, float value);

/*!
 *					Finds the dot product of two vectors.
 *
 *					The dot product returns the cosine of the angle formed by two vectors.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			A float data type with the dot product.
 */
NGL_API float nglVec3Dot(NGLvec3 vecA, NGLvec3 vecB);

/*!
 *					Finds the cross product of two vectors.
 *
 *					The cross product returns a new vector that is orthogonal with the other two,
 *					that means, the new vector is mutually perpendicular to the other two.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			A vector which is perpendicular to two inputs.
 */
NGL_API NGLvec3 nglVec3Cross(NGLvec3 vecA, NGLvec3 vecB);

/*!
 *					Multiplies a vector by a matrix.
 *
 *					The matrix is always given as a 4x4 matrix, but the returning vector depends on the
 *					input vector type.
 *
 *	@param			vec
 *					The vector that will be multiplied by the matrix.
 *
 *	@param			matrix
 *					The matrix 4x4.
 *
 *	@result			A vector altered by the matrix.
 */
NGL_API NGLvec3 nglVec3ByMatrix(NGLvec3 vec, NGLmat4 matrix);

/*!
 *					Multiplies a vector by the transposed of a matrix, if the matrix is orthogonal, the
 *					transposed matrix is equal the its inverse.
 *
 *					The matrix is always given as a 4x4 matrix, but the returning vector depends on the
 *					input vector type.
 *
 *	@param			vec
 *					The vector that will be multiplied by the matrix.
 *
 *	@param			matrix
 *					The matrix 4x4.
 *
 *	@result			A vector altered by the matrix.
 */
NGL_API NGLvec3 nglVec3ByMatrixTransposed(NGLvec3 vec, NGLmat4 matrix);

/*!
 *					Extract the euler angles from a rotation matrix.
 *
 *					The matrix needs to be orthogonal, rotation isolated and column-major format.
 *					The returning values are given in degrees and represents the rotation in relation to
 *					the first and second quadrants of the circle, that means, the returning values stay
 *					in the range [-180.0, 180.0].
 *
 *					This is the column-major format:
 *
 *					<pre>
 *
 *					| 0  4  8  12 |
 *					|             |
 *					| 1  5  9  13 |
 *					|             |
 *					| 2  6  10 14 |
 *					|             |
 *					| 3  7  11 15 |
 *
 *					</pre>
 *
 *	@param			matrix
 *					The matrix 4x4.
 *
 *	@result			A vector extracted from a rotation matrix.
 */
NGL_API NGLvec3 nglVec3FromMatrix(NGLmat4 matrix);

#pragma mark -
#pragma mark Vec4 Functions
//**************************************************
//	Vec4 Functions
//**************************************************

/*!
 *					Creates a new NGLvec4 structure based on float values.
 *	
 *	@param			x
 *					The value of X component.
 *	
 *	@param			y
 *					The value of Y component.
 *	
 *	@param			z
 *					The value of Z component.
 *	
 *	@param			w
 *					The value of W component.
 *
 *	@result			A new NGLvec4 structure.
 */
NGL_API NGLvec4 nglVec4Make(float x, float y, float z, float w);

/*!
 *					Checks if informed vector is null.
 *
 *					A vector is considered null if all its values are equal to 0.0.
 *	
 *	@param			vec
 *					A NGLvec4 to check.
 *
 *	@result			A BOOL data type indicating if the vector is null. Returns 1 if it's null.
 */
NGL_API BOOL nglVec4IsZero(NGLvec4 vec);

/*!
 *					Checks if informed vector A is equal to the vector B.
 *
 *					Two vectors are considered equals if all its values are equals.
 *	
 *	@param			vecA
 *					The vector A.
 *	
 *	@param			vecB
 *					The vector B.
 *
 *	@result			A BOOL data type indicating if the vectors are equals. Returns 1 if they are equals.
 */
NGL_API BOOL nglVec4IsEqual(NGLvec4 vecA, NGLvec4 vecB);

/*!
 *					Calculates the length of a vector.
 *
 *					The length of a vector, also known as magnitude, is calculated using the
 *					Pythagorean Theorem and represents the size of a vector.
 *
 *					<pre>
 *					           __  ___
 *					          /      /|
 *					         /      / |
 *					 Length /      / 
 *					       /      /  Vector
 *					      /__    /
 *					             0, 0, 0
 *
 *					</pre>
 *
 *					It's said "unit vector" that which has it's length equal to 1.0.
 *
 *	@param			vec
 *					The vector to extract its length.
 *
 *	@result			A float data type with its length.
 */
NGL_API float nglVec4Length(NGLvec4 vec);

/*!
 *					Normalizes the values inside a vector to make it an "unit vector".
 *
 *					It's said "unit vector" that which has it's length equal to 1.0.
 *
 *	@param			vec
 *					The vector to be normalized.
 *
 *	@result			The returning vector normalized.
 */
NGL_API NGLvec4 nglVec4Normalize(NGLvec4 vec);

/*!
 *					Indentifies NaN values and set them to 0 (zero).
 *
 *	@param			vec
 *					The vector.
 *
 *	@result			The returning cleared vector.
 */
NGL_API NGLvec4 nglVec4Cleared(NGLvec4 vec);

/*!
 *					Adds two vectors.
 *
 *					The sum of two vectors produces a new vector which has direction and magnitude in
 *					the middle of the originals.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning added vector.
 */
NGL_API NGLvec4 nglVec4Add(NGLvec4 vecA, NGLvec4 vecB);

/*!
 *					Subtracts vector B from the vector A.
 *
 *					The of parameters is important here. The subtraction is also known as distance.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning subtracted vector.
 */
NGL_API NGLvec4 nglVec4Subtract(NGLvec4 vecA, NGLvec4 vecB);

/*!
 *					Multiplies two vectors.
 *
 *					This is not the Cross product neither the Dot product. This function just multiply
 *					their scalar values.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			The returning multiplied vector.
 */
NGL_API NGLvec4 nglVec4Multiply(NGLvec4 vecA, NGLvec4 vecB);

/*!
 *					Multiplies vector by a scalar value.
 *
 *					The scalar value is multiplied by each element of the vector.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			value
 *					The floating number.
 *
 *	@result			The returning multiplied vector.
 */
NGL_API NGLvec4 nglVec4Multiplyf(NGLvec4 vecA, float value);

/*!
 *					Finds the dot product of two vectors.
 *
 *					The dot product returns the cosine of the angle formed by two vectors.
 *
 *	@param			vecA
 *					The vector A.
 *
 *	@param			vecB
 *					The vector B.
 *
 *	@result			A float data type with the dot product.
 */
NGL_API float nglVec4Dot(NGLvec4 vecA, NGLvec4 vecB);

/*!
 *					Multiplies a vector by a matrix.
 *
 *					The matrix is always given as a 4x4 matrix, but the returning vector depends on the
 *					input vector type.
 *
 *	@param			vec
 *					The vector that will be multiplied by the matrix.
 *
 *	@param			matrix
 *					The matrix 4x4.
 *
 *	@result			A vector altered by the matrix.
 */
NGL_API NGLvec4 nglVec4ByMatrix(NGLvec4 vec, NGLmat4 matrix);

/*!
 *					Multiplies a vector by the transposed of a matrix, if the matrix is orthogonal, the
 *					transposed matrix is equal the its inverse.
 *
 *					The matrix is always given as a 4x4 matrix, but the returning vector depends on the
 *					input vector type.
 *
 *	@param			vec
 *					The vector that will be multiplied by the matrix.
 *
 *	@param			matrix
 *					The matrix 4x4.
 *
 *	@result			A vector altered by the matrix.
 */
NGL_API NGLvec4 nglVec4ByMatrixTransposed(NGLvec4 vec, NGLmat4 matrix);