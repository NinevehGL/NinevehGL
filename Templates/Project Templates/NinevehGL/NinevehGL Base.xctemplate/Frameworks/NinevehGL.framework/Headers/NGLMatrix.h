/*
 *	NGLMatrix.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 2/2/11.
 *  Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLDataType.h"

/*!
 *					A matrix of order 4 (4 columns by 4 rows) represented by a linear array of 16 elements
 *					of float data type. OpenGL uses the matrix 4x4 to deal with complex operations in the
 *					3D world, like rotations, translates and scales.
 *					A 4 x 4 matrix could be represented as following:
 *
 *					<pre>
 *
 *					| 1  0  0  0 |
 *					|            |
 *					| 0  1  0  0 |
 *					|            |
 *					| 0  0  1  0 |
 *					|            |
 *					| 0  0  0  1 |
 *
 *					</pre>
 *
 *					IMPORTANT:
 * 
 *					OpenGL represents its matrices with the rows and columns swapped from the tradicional
 *					mathematical matrices (this swapped format is also known as column-major format).
 *					So, in all the following code you'll see the SWAPPED MATRICES operations.
 *
 *					The OpenGL uses one dimensional array ({0,1,2,3,4...}) to work with matricies, 
 *					the indices of the array can be represented as following:
 *	
 *					<pre>
 *
 *					  Tradicional                   OpenGL
 *
 *					| 0  1  2  3  |             | 0  4  8  12 |
 *					|             |             |             |
 *					| 4  5  6  7  |             | 1  5  9  13 |
 *					|             |             |             |
 *					| 8  9  10 11 |             | 2  6  10 14 |
 *					|             |             |             |
 *					| 12 13 14 15 |             | 3  7  11 15 |
 *
 *					</pre>
 */
typedef float NGLmat4[16];

/*!
 *					Loads the identity matrix into a NGLmat4.
 *
 *					A base matrix with neutral values. Works like a multiplication by 1 in a linear algebra,
 *					that means, doesn't change the multiplied object. Every matrix which multiply or
 *					be multiplied by the identity matrix will result in the same matrix. This is the
 *					identity matrix representation:
 *
 *					<pre>
 *
 *					| 1  0  0  0 |
 *					|            |
 *					| 0  1  0  0 |
 *					|            |
 *					| 0  0  1  0 |
 *					|            |
 *					| 0  0  0  1 |
 *
 *					</pre>
 *	
 *	@param			result
 *					The matrix which will have the identity matrix's values.
 */
NGL_API void nglMatrixIdentity(NGLmat4 result);

/*!
 *					Creates a NGLmat4 based on an NSArray.
 *
 *					The NSArray must has at least 16 values on it, only the first 16 values will be used.
 *	
 *	@param			array
 *					The NSArray with at least 16 elements.
 *	
 *	@param			result
 *					The matrix which will receive the result.
 */
NGL_API void nglMatrixFromNSArray(NSArray *array, NGLmat4 result);

/*!
 *					Copies the values from one matrix to another.
 *
 *					This method copies the memory, so newer changes to the original matrix will not affect
 *					the resulting matrix.
 *	
 *	@param			original
 *					The matrix to be copied.
 *	
 *	@param			result
 *					The matrix which will receive the result.
 */
NGL_API void nglMatrixCopy(NGLmat4 original, NGLmat4 result);

/*!
 *					Multiply two matrices.
 *
 *					Before start the multiplication process, the values are cached. That means the result
 *					instance can be the same as multiplication product. For example:
 *
 *					<pre>
 *
 *					NGLmat4 matA = &lt;Some initial value&gt;;
 *					NGLmat4 matB = &lt;Some initial value&gt;;
 *
 *					nglMatrixMultiply(matA, matB, matA);
 *
 *					</pre>
 *
 *					The multiplication process will occurs multiplying each line value of the first
 *					matrix by the columns of the second matrix, each line for each columns, and so on:
 *	
 *					<pre>
 *
 *					      m1                           m2
 *					 ------> Lines
 *
 *					| 0  4  8  12 |         C    | 0  4  8  12 |
 *					|             |         o |  |             |
 *					| 1  5  9  13 |         l |  | 1  5  9  13 |
 *					|             |    X    u |  |             |
 *					| 2  6  10 14 |         m |  | 2  6  10 14 |
 *					|             |         n V  |             |
 *					| 3  7  11 15 |         s    | 3  7  11 15 |
 *
 *					</pre>
 *
 *					IMPORTANT:
 *					Matrix multiplication IS NOT commutative. So A x B is not the same as B x A.
 *	
 *	@param			m1
 *					The first product matrix.
 *
 *	@param			m2
 *					The second product matrix.
 *	
 *	@param			result
 *					The matrix which will receive the result.
 */
NGL_API void nglMatrixMultiply(NGLmat4 m1, NGLmat4 m2, NGLmat4 result);

/*!
 *					Finds the determinant.
 *
 *					The determinant is a scale value which represents the matrix diagonals.
 *	
 *	@param			original
 *					The matrix to be inverted.
 *
 *	@result			The determinant scalar value.
 */
NGL_API float nglMatrixDeterminant(NGLmat4 original);

/*!
 *					Transposes a matrix.
 *
 *					This method invert the lines with the columns:
 *
 *					<pre>
 *
 *					| 0  4  8  12 |         | 0  1  2  3  |
 *					|             |         |             |
 *					| 1  5  9  13 |         | 4  5  6  7  |
 *					|             |    =    |             |
 *					| 2  6  10 14 |         | 8  9  10 11 |
 *					|             |         |             |
 *					| 3  7  11 15 |         | 12 13 14 15 |
 *
 *					</pre>
 *
 *	
 *	@param			original
 *					The matrix to be transposed.
 *
 *	@param			result
 *					The matrix which will receive the result.
 */
NGL_API void nglMatrixTranspose(NGLmat4 original, NGLmat4 result);

/*!
 *					Inverts a matrix.
 *
 *					The inverse of a matrix (M¡) is one that confirm the sentence:
 *
 *					<pre>
 *
 *					| M  x M¡ = Identity
 *					| M¡ x M  = Identity
 *
 *					</pre>
 *	
 *	@param			original
 *					The matrix to be inverted.
 *
 *	@param			result
 *					The matrix which will receive the result.
 */
NGL_API void nglMatrixInverse(NGLmat4 original, NGLmat4 result);

/*!
 *					Normalize a matrix.
 *
 *					The matrix normalization involves all the 
 *	
 *	@param			original
 *					The matrix to be normalized.
 *
 *	@param			result
 *					The matrix which will receive the result.
 */
NGL_API void nglMatrixNormalize(NGLmat4 original, NGLmat4 result);

/*!
 *					Isolates the rotation matrix, discarding scale and translation components.
 *
 *					If the original matrix contains scale information, those information will
 *					be ignored.
 *	
 *	@param			original
 *					The matrix to extract rotation from.
 *
 *	@param			result
 *					The matrix which will receive the result.
 */
NGL_API void nglMatrixIsolateRotation(NGLmat4 original, NGLmat4 result);

/*!
 *					Describes a matrix.
 *
 *					A user friendly representation will be shown on console panel. The representation
 *					will use traditional mathematic notation (row-major format), like this:
 *
 *					<pre>
 *
 *					| 0  1  2  3  |
 *					|             |
 *					| 4  5  6  7  |
 *					|             |
 *					| 8  9  10 11 |
 *					|             |
 *					| 12 13 14 15 |
 *
 *					</pre>
 *	
 *	@param			original
 *					The matrix to be described.
 */
NGL_API void nglMatrixDescribe(NGLmat4 original);