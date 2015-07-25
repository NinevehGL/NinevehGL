/*
 *	NGLArray.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 9/1/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLError.h"
#import "NGLIterator.h"

/*!
 *					<strong>(Internal only)</strong> An object that holds the array values.
 *
 *					This structure is used as a fixed pointer to preserve the necessary information/memory
 *					to the array values.
 *	
 *	@var			NGLArrayValues::pointers
 *					The pointers array.
 *	
 *	@var			NGLArrayValues::count
 *					The count/length of the array.
 *	
 *	@var			NGLArrayValues::retainOption
 *					The retain option. This value can't be changed outside the initialization.
 *	
 *	@var			NGLArrayValues::iterator
 *					The iterator pointer.
 *	
 *	@var			NGLArrayValues::i
 *					The iterator index.
 */
typedef struct
{
	void			**pointers;
	unsigned int	count;
	unsigned int	capacity;
	BOOL			retainOption;
	void			**iterator;
	unsigned int	i;
} NGLArrayValues;

/*!
 *					Extremelly fast loop to work with NGLArray. This loop is slower than NSFastEnumeration,
 *					about 50% slower. However it accepts mutations during the loop and can work with
 *					any kind of data type (Objective-C or standard C).
 *
 *					The syntax is a little bit different than the traditional forin loop:
 *
 *					<pre>
 *
 *					id variable;
 *
 *					nglFor (variable, myNGLArray)
 *					{
 *					    // Do something...
 *					}
 *
 *					</pre>
 *
 *	@param			p
 *					A pointer that will receive the values.
 *
 *	@param			a
 *					The NGLArray instance to loop through.
 */
#define nglFor(p, a)\
for(NGLArrayValues *v = [(((a) != nil) ? (a) : [NGLArray array]) forLoop:(void **)&(p)];\
(*v).i < (*v).count;\
(*v).i++, (p) = *(*v).iterator++)

/*!
 *					Checks if a pointer is valid or not, that means, if a pointer is really pointing to
 *					a valid object (not released nor deallocated).
 *	
 *	@param			pointer
 *					A C pointer to check.
 *
 *	@result			A BOOL indicating if the pointer is valid or not.
 */
NGL_API BOOL nglPointerIsValid(void *pointer);

/*!
 *					Checks if a pointer is valid for a specific kind of class.
 *
 *					To check the validation against any kind of classes, use the #nglPointerIsValid#.
 *	
 *	@param			pointer
 *					A C pointer to check.
 *
 *	@param			aClass
 *					An Objective-C class.
 *
 *	@result			A BOOL indicating if the pointer is valid or not.
 */
NGL_API BOOL nglPointerIsValidToClass(void *pointer, Class aClass);

/*!
 *					Checks if a pointer is valid for a specific protocol.
 *
 *					This function will return NO if the pointer is released, deallocated, or just doesn't
 *					conform to the informed protocol.
 *	
 *	@param			pointer
 *					A C pointer to check.
 *
 *	@param			aProtocol
 *					An Objective-C class.
 *
 *	@result			A BOOL indicating if the pointer is valid or not.
 */
NGL_API BOOL nglPointerIsValidToProtocol(void *pointer, Protocol *aProtocol);

/*!
 *					Checks if a pointer is valid and responds to a selector.
 *
 *					This function will return NO if the pointer is released, deallocated, or just doesn't
 *					conform to the informed protocol.
 *	
 *	@param			pointer
 *					A C pointer to check.
 *
 *	@param			selector
 *					An Objective-C selector.
 *
 *	@result			A BOOL indicating if the pointer is valid or not.
 */
NGL_API BOOL nglPointerIsValidToSelector(void *pointer, SEL selector);

/*!
 *					This class is a collection that works just like an array, however it's generic for
 *					any kind of data type, including basic C types. NGLArray does not retain
 *					the object.
 *
 *					This class is faster than the traditional NSArray. Depending on the tasks, NGLArray
 *					can be 50% faster than NSArray, the most expensive task of NGLArray is at least
 *					15% faster than NSArray, which is "removeAll". Actually, this class is more like a
 *					NSMutableArray, because you can change its collection at any time. This one also has
 *					a "hint" property called capacity, if you already know the maximum number of elements
 *					you can set this property to boost the performance a little bit more.
 *
 *					By default, every time you try to insert an item in this array and it's capacity is
 *					full, a new block of 10 items will be allocated into this array.
 *
 *					The reasons that cause this one to be faster than NSArray are:
 *
 *						- It basically work with pointers and dereference, instead of indices.
 *						- It has an internal iterator loop that manages the enumerations.
 *						- It doesn't have many too checks. NGLArray assumes you know what you're doing.
 *
 *					The achieve the best performance and still flexible, the NGLArray offers three kind
 *					of loops. Each one has its own cost and benefits:
 *
 *						- <b>NGLIterator</b>: <i>Loops through 100 millions in 1.5 seg</i>.<br />
 *							Uses NGLIterator protocol. This loop is good for small array in which you
 *							need to change it's content during the loop or even from another thread.
 *							This routine offers a way to reset the loop at any time by calling the 
 *							<code>resetIterator</code> method.
 *							The disadvantage of this routine is that it makes a Objective-C message call
 *							at each loop cycle, so it's a little expensive compared to the other ones.
 *							Its syntax is:
 *
 *							<pre>
 *
 *							id variable;
 *							while ((variable = [myNGLArray nextIterator]))
 *							{
 *								// Do something...
 *							}
 *
 *							</pre>
 *
 *						- <b>NGLFor</b>: <i>Loops through 100 millions in 0.45 seg</i>.<br />
 *							Very fast loop using the iterator properties. Can deal with changes during
 *							the loop or even from another thread.
 *							Its disadvantage is that it has a special syntax and just resets the iterator
 *							loop at the beginning. So if you're planning to use the <b>NGLIterator</b> after
 *							use this one, you must call <code>resetIterator</code> before start the
 *							<b>NGLIterator</b>. Its syntax is:
 *
 *							<pre>
 *
 *							id variable;
 *							nglFor (variable, myNGLArray)
 *							{
 *								// Do something...
 *							}
 *
 *							</pre>
 *
 *						- <b>ForEach</b>: <i>Loops through 100 millions in 0.3 seg</i>.<br />
 *							Uses NSFastEnumeration protocol (the Cocoa "for in" loop). This loop is the
 *							fastest one. However it's be used only in few situations.
 *							Its disadvantage is that it only work with Objective-C objects and the array
 *							can't be changed during the loop (changing the array during the loop will 
 *							result in runtime error).
 *							Its syntax is:
 *
 *							<pre>
 *
 *							id variable;
 *							for (variable in myNGLArray)
 *							{
 *								// Do something...
 *							}
 *
 *							</pre>
 *
 *					The NGLArray class also provides a pointer to the items and a pointer to the
 *					mutations property. You can use them to implement your own NSFastEnumeration.
 */
@interface NGLArray : NSObject <NGLIterator, NSFastEnumeration>
{
@private
	NGLArrayValues			_values;
}

/*!
 *					The capacity property is not the size/count of the array, it's just a "hint" to optimize
 *					the array manipulation spped. This "hint" is useful for large array (above 10 items).
 *					
 *					The NGLArray will allocate the memory in sets/packages using this "hint" property. 
 */
@property (nonatomic) unsigned int capacity;

/*!
 *					Indicates if this array will retain or not the objects in it. This property can't be
 *					changed to ensure the integrity of the items and must be set when initializing this
 *					array. Only Objective-C objects can receive retain messages.
 */
@property (nonatomic, readonly) BOOL retainOption;

/*!
 *					Returns the items pointer. This property is useful if you want to create your own
 *					implementation of NSFastEnumeration but keep using NGLArray as your collection.
 *
 *					Remember that NSFastEnumeration is exclusive for Objective-C objects.
 */
@property (nonatomic, readonly) NGL_ARC_ASSIGN id *itemsPointer;

/*!
 *					Returns the mutations pointer. This property is useful if you want to create your own
 *					implementation of NSFastEnumeration but keep using NGLArray as your collection.
 *
 *					Remember that NSFastEnumeration is exclusive for Objective-C objects.
 */
@property (nonatomic, readonly) unsigned long *mutationsPointer;

/*!
 *					<strong>(Internal only)</strong> Returns a pointer to the array values.
 *					You should not call this method directly.
 */
@property (nonatomic, readonly) NGLArrayValues *values;

/*!
 *					Initiates a NGLArray making it a safe collection, that means, it will retain every
 *					pointer that will be added to it. In this case, all pointer must be a subclass
 *					of NSObject.
 *
 *					The retained objects will receive a release message when they are removed or this
 *					instance of NGLArray is released.
 *
 *	@result			A NGLArray instance.
 */
- (id) initWithRetainOption;

/*!
 *					Initiates a NGLArray instance based on another NGLArray.
 *
 *					This method copies all objects/instances inside the informed NGLArray.
 *
 *	@param			pointers
 *					A NGLArray to serve as base to the new NGLArray.
 *
 *	@result			A NGLArray instance.
 */
- (id) initWithNGLArray:(NGLArray *)pointers;

/*!
 *					Initiates a NGLArray instance based on many object/instances.
 *
 *					This method doesn't make use of addPointerOnce, that means if a target is informed
 *					more than one time, it will remain duplicated inside this collection.
 *
 *	@param			first
 *					The first object/instance to be added.
 *
 *	@param			...
 *					A sequence of objects/instances separated by commas. This method must end with
 *					a <code>nil</code> element.
 *
 *	@result			A NGLArray instance.
 */
- (id) initWithPointers:(void *)first, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 *					Adds a new object/instance to this collection. If the target already exist in this
 *					collection, it will be added again, resulting in a duplication.
 *
 *	@param			pointer
 *					The target it self.
 */
- (void) addPointer:(void *)pointer;

/*!
 *					Adds a new object/instance to this collection only if the target is not already inside
 *					this collection. If the target already exist, nothing will happen.
 *
 *	@param			pointer
 *					The target it self.
 */
- (void) addPointerOnce:(void *)pointer;

/*!
 *					Adds all object/instance to this collection from another NGLArray.
 *					This method copies all objects/instances inside the informed NGLArray.
 *
 *	@param			pointers
 *					The NGLArray instance to copy pointers from.
 */
- (void) addPointersFromNGLArray:(NGLArray *)pointers;

/*!
 *					Returns the index of a target inside this collection.
 *
 *	@param			pointer
 *					The target it self.
 *
 *	@result			Returns the index of the target or NGL_NOT_FOUND if the target was not found.
 */
- (unsigned int) indexOfPointer:(void *)pointer;

/*!
 *					Checks if a target is inside this collection.
 *
 *	@param			pointer
 *					The target it self.
 *
 *	@result			Returns YES (1) if the target is found, otherwise NO (0) will be returned.
 */
- (BOOL) hasPointer:(void *)pointer;

/*!
 *					Removes an object/instance inside this collection.
 *
 *	@param			pointer
 *					The target it self.
 */
- (void) removePointer:(void *)pointer;

/*!
 *					Removes an object/instance in a specific position inside this collection.
 *
 *	@param			index
 *					The index of the target. If the index is out of bounds, nothing will happen.
 */
- (void) removePointerAtIndex:(unsigned int)index;

/*!
 *					Removes the very first object/instance in this collection.
 */
- (void) removeFirst;

/*!
 *					Removes the very last object/instance in this collection.
 */
- (void) removeLast;

/*!
 *					Removes all the instances inside this library.
 *
 *					This method makes a clean up inside this library, freeing all allocated
 *					memories to the instances in it.
 */
- (void) removeAll;

/*!
 *					Returns an object/instance in a specific position inside this collection.
 *
 *	@param			index
 *					The index of the target. If the index is out of bounds, NULL will be returned.
 *
 *	@result			A pointer or NULL if no result was found.
 */
- (void *) pointerAtIndex:(unsigned int)index;

/*!
 *					Returns the number of instances in this library at the moment.
 *
 *	@result			An int data type.
 */
- (unsigned int) count;

/*!
 *					<strong>(Internal only)</strong> Prepares this array to work with "nglFor" loop.
 *					You should not call this method directly.
 *
 *	@param			target
 *					A pointer to the target that will receive the items of this array. Inside this
 *					method the target will receive the first item.
 *
 *	@result			A pointer to the values of this array.
 */
- (NGLArrayValues *) forLoop:(void **)target;

/*!
 *					Returns an autoreleased instance of NGLArray.
 *
 *	@result			A NGLArray autoreleased instance.
 */
+ (id) array;

@end

/*!
 *					A category that extends the default behavior to perform some convenience method which
 *					could help when other classes makes use of this one.
 */
@interface NGLArray(NGLArrayExtended)

- (NSArray *) allPointers;

/*!
 *					A convenience method that loops through all objects making them perform a selector.
 *
 *					IMPORTANT: This method assumes you're sure about this task and no additional check
 *					will be made to identify if the objects can receive such message. So, make sure all
 *					the objects are Objective-C instances and can receive the informed message.
 *
 *	@param			selector
 *					The selector which will be performed on all objects.
 */
- (void) makeAllPointersPerformSelector:(SEL)selector;

@end