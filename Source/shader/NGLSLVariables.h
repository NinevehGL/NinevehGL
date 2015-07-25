/*
 *	NGLSLVariables.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 3/4/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLIterator.h"
#import "NGLArray.h"

/*!
 *					The NinevehGL object to deal with shader variables.
 *
 *					This structure is used as a fixed pointer to preserve the necessary information
 *					(memory) to the shader's variables.
 *	
 *	@var			NGLSLVariable::isDynamic
 *					Represents if the shader variable is dynamic (attribute) or static (uniform).
 *	
 *	@var			NGLSLVariable::name
 *					Represents the variable's name inside the shader program. This field will be
 *					automatically set after the shader compilation.
 *
 *	@var			NGLSLVariable::location
 *					Represents the variable's location inside the shader program. This field will be
 *					automatically set after the shader compilation.
 *
 *	@var			NGLSLVariable::count
 *					Represents the variable's count/lenght.
 *					As dynamic variables doesn't support arrays, to a dynamic variable it is the
 *					number of the floating values in the data. To a static variable it is the number of
 *					elements in the array, if the static variable is a single data, this field should be 1.
 *
 *	@var			NGLSLVariable::dataType
 *					Represents the variable's data type. It must be one of the NinevehGL correlateds:
 *
 *						- NGL_FLOAT;
 *						- NGL_INT;
 *						- NGL_BOOL;
 *						- NGL_VEC2;
 *						- NGL_VEC3;
 *						- NGL_VEC4;
 *						- NGL_IVEC2;
 *						- NGL_IVEC3;
 *						- NGL_IVEC4;
 *						- NGL_BVEC2;
 *						- NGL_BVEC3;
 *						- NGL_BVEC4;
 *						- NGL_MAT2;
 *						- NGL_MAT3;
 *						- NGL_MAT4;
 *						- NGL_SAMPLER_2D;
 *						- NGL_SAMPLER_CUBE.
 *
 *	@var			NGLSLVariable::stride
 *					Represents the stride for dynamic values. As dynamic variables are usually stored as an
 *					array of structures, this field is the stride in bytes of the current variable.
 *					To static variables this field has no effect.
 *
 *	@var			NGLSLVariable::data
 *					A pointer to the data of the variable.
 *
 *	@var			NGLSLVariable::glFunction
 *					The pointer to the function necessary to update the variable's value inside the shader.
 */
typedef struct
{
	BOOL isDynamic;
	NGL_ARC_ASSIGN NSString *name;
	unsigned int location;
	unsigned char count; // 128 max Uniform in VSH
	unsigned char dataType; // 3 data types: float, bool and int
	unsigned int stride;
	void *data;
	void *glFunction;
} NGLSLVariable;

/*!
 *					Encapsulates and hold all the variables to a specific shader program.
 *
 *					NGLVariables is a library to all the variables (attributes and uniforms) of a specific
 *					shader program.
 *
 *					As any NinevehGL library of structures, this class makes use of the iterator pattern
 *					to fast retrieve its elements. You can use iterator with the
 *					<code>#nextIterator#</code> and <code>resetIterator</code> methods.
 */
@interface NGLSLVariables : NSObject <NGLIterator>
{
@private
	NGLArray				*_collection;
	
	// Variables
	NGLSLVariable			*_variables;
	int						_vCount;
	
	// Iterator
	int						_iterator;
}

/*!
 *					Adds a new instance into this library.
 *
 *					The parameters/fields of the new instance don't need to be filled all. Only the valid
 *					values will be copied and a memory block will be reserved to all the other fields.
 *
 *					The name of the variable will be internally retained as a key.
 *
 *	@param			variable
 *					A NGLSLVariable struct, not necessarily filled.
 *
 *	@see			NGLSLVariable
 */
- (void) addVariable:(NGLSLVariable)variable;

/*!
 *					Copies all the structure instances from other library of structures.
 *
 *					All the values will be copied and a new memory block will be allocated. The original 
 *					library and/or values can be deleted with no impact on these new copies.
 *
 *					The name of the variables will be internally retained as keys.
 *
 *	@param			variables
 *					A NGLSLVariables instance to copy the instances from.
 *
 *	@see			NGLSLVariable
 */
- (void) addFromVariables:(NGLSLVariables *)variables;

/*!
 *					Returns a pointer to a NGLSLVariable struct based on its index.
 *
 *					This method will search for an instance in the informed index inside this library.
 *					This method will return NULL if the index is out of bounds. All the changes made inside
 *					the returning pointer will affect directly the original NGLSLVariable inside
 *					this library.
 *
 *	@param			index
 *					The index of the desired variable inside this library.
 *
 *	@result			A pointer to NGLSLVariable struct. It can return NULL.
 *
 *	@see			NGLSLVariable
 */
- (NGLSLVariable *) variableAtIndex:(int)index;

/*!
 *					Returns a pointer to a NGLSLVariable struct based on a variable's name.
 *
 *					Performs a search inside all the variables inside this library looking for the informed
 *					variable's name. This method will return NULL if the index is out of bounds.
 *					All the changes made inside the returning pointer will affect directly the original
 *					NGLSLVariable inside this library.
 *
 *	@param			name
 *					A NSString containing the Variable's name. It's the same used inside the shaders.
 *
 *	@result			A pointer to NGLSLVariable struct. It can return NULL if no result is found.
 *
 *	@see			NGLSLVariable
 */
- (NGLSLVariable *) variableWithName:(NSString *)name;

/*!
 *					Removes a structure instance based on a Variable's name.
 *
 *					Performs a search inside all the instances inside this library looking for the informed
 *					parameter. If the parameter is found, its instance will be removed from this library
 *					and its memory will be freed. Otherwise, nothing will happen.
 *
 *	@param			name
 *					A NSString containing the Variable's name. It's the same used inside the shaders.
 */
- (void) removeVariableWithName:(NSString *)name;

/*!
 *					Removes all the instances inside this library.
 *
 *					This method makes a clean up inside this library, freeing all allocated
 *					memories to the instances in it.
 */
- (void) removeAll;


/*!
 *					Returns the number of instances in this library at the moment.
 *
 *	@result			An unsigned int data type.
 */
- (unsigned int) count;

@end