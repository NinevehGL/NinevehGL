/*
 *	NGLMeshElements.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 4/22/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLIterator.h"

/*!
 *					Defines type of component.
 *
 *					There are few fixed components in 3D world. Each component is NinevehGL's implementation
 *					dependent. Each component is a per-vertex instruction to the OpenGL Shaders.
 *					One single mesh could have more than one channel of the same component,
 *					but this is NinevehGL's implementation dependent too.
 *
 *	@see			removeElementWithComponent:
 *	@see			elementWithComponent:
 *	
 *	@var			NGLComponentVertex
 *					Represents the vertex position.
 *	
 *	@var			NGLComponentTexcoord
 *					Represents the vertex texture coordinate.
 *	
 *	@var			NGLComponentNormal
 *					Represents the vertex normal.
 *	
 *	@var			NGLComponentTangent
 *					Represents the vertex tangent.
 *	
 *	@var			NGLComponentBitangent
 *					Represents the vertex bitangent.
 */
typedef enum
{
	NGLComponentVertex,
	NGLComponentTexcoord,
	NGLComponentNormal,
	NGLComponentTangent,
	NGLComponentBitangent,
} NGLComponent;

/*!
 *					<strong>(Internal only)</strong> An object that holds the element scalar values.
 *
 *					This structure is used as a fixed pointer to preserve the information (memory)
 *					necessary to the element's scalar values. An element holds the properties for a specific
 *					component. Only one element is always mandatory: the element for vertex element position
 *					(<code>NGLComponentVertex</code>).
 *
 *	@see			NGLComponent
 *	
 *	@var			NGLElement::component
 *					Represents the component, it can be one of the NGLComponent values.
 *	
 *	@var			NGLElement::start
 *					Represents the start index of the element in array of structures.
 *	
 *	@var			NGLElement::length
 *					Represents the length of the component in the array of structures.
 *	
 *	@var			NGLElement::offsetInFace
 *					<strong>(Internal only)</strong> Represents the position of the element
 *					in the array of faces.
 */
typedef struct
{
	NGLComponent			component;
	unsigned char			start;
	unsigned char			length;
	unsigned char			offsetInFace;
} NGLElement;

/*!
 *					A library that holds the elements for a mesh.
 *
 *					NGLMeshElements can hold and manage many elements (<code>NGLElement</code>). Each
 *					element is a tiny object holding the information necessaries to instruct the shaders
 *					about the element. There are few kind of elements:
 *
 *						- Vertex Position;
 *						- Vertex Texture Coordinate;
 *						- Vertex Normal;
 *						- Vertex Tangent;
 *						- Vertex Bitangent.
 *
 *					NinevehGL just works with per-vertex elements to produce smooth effects on shaders.
 *					As any NinevehGL library, this class makes use of the iterator pattern to fast retrieve
 *					its elements. You can use iterator with the <code>#nextIterator#</code> and 
 *					<code>#resetIterator#</code> methods.
 */
@interface NGLMeshElements : NSObject <NGLIterator>
{
@private
	NGLElement			*_elements;
	int					_pCount;
	
	int					_iterator;
}

/*!
 *					Adds once an element into this library. Existing elements will be overridden by
 *					the new ones.
 *
 *					The parameters/fields of the new instance don't need to be filled all. Only the valid
 *					values will be copied and a memory block will be reserved to all the other fields.
 *
 *	@param			element
 *					A NGLElement struct, not necessarily filled.
 *
 *	@see			NGLElement
 */
- (void) addElement:(NGLElement)element;

/*!
 *					Copies once all the elements from other library. Existing elements will be overridden
 *					by the new ones.
 *
 *					All the values will be copied and a new memory block will be allocated. The original 
 *					library and/or values can be deleted with no impact on these new copies.
 *
 *	@param			elements
 *					A NGLMeshElements instance to copy the instances from.
 *
 *	@see			NGLMeshElements
 */
- (void) addFromElements:(NGLMeshElements *)elements;

/*!
 *					Returns a pointer to a structure instance based on a component.
 *
 *					Performs a search inside all the variables inside this library looking for the informed
 *					variable's name. This method will return NULL if the index is out of bounds.
 *					All the changes made inside the returning pointer will affect directly the original
 *					instance inside this library.
 *
 *	@param			component
 *					The NGLComponent to searching for.
 *
 *	@result			A pointer to NGLElement struct. It can return NULL if no result is found.
 *
 *	@see			NGLComponent
 */
- (NGLElement *) elementWithComponent:(NGLComponent)component;

/*!
 *					Removes a structure instance based on a component.
 *
 *					Performs a search inside all the instances inside this library looking for the informed
 *					parameter. If the parameter is found, its instance will be removed from this library
 *					and its memory will be freed. Otherwise, nothing will happen.
 *
 *	@param			component
 *					The NGLComponent to searching for.
 *
 *	@see			NGLComponent
 */
- (void) removeElementWithComponent:(NGLComponent)component;

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
 *	@result			An int data type.
 */
- (int) count;

@end