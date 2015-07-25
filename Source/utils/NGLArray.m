/*
 *	Copyright (c) 2011-2015 NinevehGL. More information at: http://nineveh.gl
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

#import "NGLArray.h"

#import <objc/message.h>
#import <objc/runtime.h>

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNGL_STRIDE_HINT			10

static NSString *const PTR_ERROR_HEADER = @"Error while processing NGLPointer.";

static NSString *const PTR_ERROR_BOUNDS = @"The informed index is out of bounds in this list.";

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

// Number of Obj-C classes actually running.
static int numClasses = 0;

// The array of classes actually running.
static Class *classesList = NULL;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static void nglArrayResize(NGLArrayValues *array)
{
	/*
	 unsigned int *capacity = &(*array).capacity;
	 void ***pointers = &(*array).pointers;
	 void ***iterator = &(*array).iterator;
	 unsigned int *i = &(*array).i;
	 
	 *capacity += kNGL_STRIDE_HINT;
	 *pointers = realloc(*pointers, NGL_SIZE_POINTER * *capacity);
	 *iterator = *pointers + *i;
	 /*/
	(*array).capacity += kNGL_STRIDE_HINT;
	(*array).pointers = realloc((*array).pointers, NGL_SIZE_POINTER * (*array).capacity);
	(*array).iterator = (*array).pointers + (*array).i;
	//*/
}

static void nglArrayAddPointer(NGLArrayValues *array, void *pointer)
{
	if (pointer != NULL)
	{
		/*
		 unsigned int *capacity = &(*array).capacity;
		 unsigned int *count = &(*array).count;
		 void ***pointers = &(*array).pointers;
		 BOOL *retain = &(*array).retainOption;
		 
		 if (*count >= *capacity)
		 {
		 nglArrayResize(array);
		 }
		 
		 if (*retain)
		 {
		 [(id)pointer retain];
		 }
		 
		 (*pointers)[*count] = pointer;
		 ++*count;
		 /*/
		if ((*array).count >= (*array).capacity)
		{
			nglArrayResize(array);
		}
		
		if ((*array).retainOption)
		{
			[(id)pointer retain];
		}
		
		(*array).pointers[(*array).count] = pointer;
		++(*array).count;
		//*/
	}
}

static unsigned int nglArrayIndexOfPointer(NGLArrayValues *array, void *pointer)
{
	/*
	 unsigned int *count = &(*array).count;
	 void **itemPtr = (*array).pointers;
	 
	 unsigned int i;
	 for (i = 0; i < *count; ++i)
	 {
	 if (pointer == *itemPtr++)
	 {
	 return i;
	 }
	 }
	 /*/
	void **itemPtr = (*array).pointers;
	
	unsigned int i;
	for (i = 0; i < (*array).count; ++i)
	{
		if (pointer == *itemPtr++)
		{
			return i;
		}
	}
	//*/
	return NGL_NOT_FOUND;
}

static void nglArrayRemovePointer(NGLArrayValues *array, void *pointer)
{
	/*
	 unsigned int *count = &(*array).count;
	 BOOL *retain = &(*array).retainOption;
	 void ***pointers = &(*array).pointers;
	 void ***iterator = &(*array).iterator;
	 unsigned int *i = &(*array).i;
	 
	 void **originalPtr = (*array).pointers;
	 void **itemPtr = (*array).pointers;
	 void *item;
	 
	 unsigned int n;
	 unsigned int length = *count;
	 for (n = 0; n < length; ++n)
	 {
	 item = *originalPtr++;
	 
	 if (item == pointer)
	 {
	 --*count;
	 
	 // Iterator safe. Avoids errors when remove inside an iterator loop.
	 if (*iterator != *pointers)
	 {
	 --*i;
	 --*iterator;
	 }
	 
	 // Releasing the pointer, if necessary.
	 if (*retain)
	 {
	 [(id)item release];
	 }
	 
	 continue;
	 }
	 
	 // Pulls the array to preserve the integrity.
	 *itemPtr++ = item;
	 }
	 /*/
	void **originalPtr = (*array).pointers;
	void **itemPtr = (*array).pointers;
	void *item;
	
	unsigned int n;
	unsigned int length = (*array).count;
	for (n = 0; n < length; ++n)
	{
		item = *originalPtr++;
		
		if (item == pointer)
		{
			--(*array).count;
			
			// Iterator safe. Decreases the iterator properties if a loop is in progress.
			if ((*array).iterator != (*array).pointers)
			{
				--(*array).i;
				--(*array).iterator;
			}
			
			// Releasing the pointer, if necessary.
			if ((*array).retainOption)
			{
				[(id)item release];
			}
			
			continue;
		}
		
		// Pulls the array to preserve the integrity.
		*itemPtr++ = item;
	}
	//*/
}

static void nglArrayRemovePointerAtIndex(NGLArrayValues *array, unsigned int index)
{
	/*
	 unsigned int *count = &(*array).count;
	 BOOL *retain = &(*array).retainOption;
	 void ***pointers = &(*array).pointers;
	 void ***iterator = &(*array).iterator;
	 unsigned int *i = &(*array).i;
	 
	 if (index < *count)
	 {
	 --*count;
	 
	 // Iterator safe. Avoids errors when remove inside an iterator loop.
	 if (*iterator != *pointers)
	 {
	 --*i;
	 --*iterator;
	 }
	 
	 // Releasing the pointer, if necessary.
	 if (*retain)
	 {
	 [(id)pointers[index] release];
	 }
	 
	 // Reallocates the memory.
	 memmove(*pointers + index, *pointers + index + 1, NGL_SIZE_POINTER * (*count - index));
	 }
	 /*/
	if (index < (*array).count)
	{
		--(*array).count;
		
		// Iterator safe. Decreases the iterator properties if a loop is in progress.
		if ((*array).iterator != (*array).pointers)
		{
			--(*array).i;
			--(*array).iterator;
		}
		
		// Releasing the pointer, if necessary.
		if ((*array).retainOption)
		{
			[(id)(*array).pointers[index] release];
		}
		
		// Moves the memory to ensure the integrity.
		unsigned int endCount = (*array).count - index;
		memmove((*array).pointers + index, (*array).pointers + index + 1, NGL_SIZE_POINTER * endCount);
	}
	//*/
}

static void nglArrayRemoveAll(NGLArrayValues *array)
{
	/*
	 unsigned int *count = &(*array).count;
	 BOOL *retain = &(*array).retainOption;
	 void ***pointers = &(*array).pointers;
	 void ***iterator = &(*array).iterator;
	 unsigned int *i = &(*array).i;
	 
	 if (*retain)
	 {
	 void **itemPtr = (*array).pointers;
	 
	 unsigned int n;
	 for (n = 0; n < *count; ++n)
	 {
	 [(id)*itemPtr release];
	 ++itemPtr;
	 }
	 }
	 
	 *iterator = *pointers;
	 *count = 0;
	 *i = 0;
	 /*/
	if ((*array).retainOption)
	{
		void **itemPtr = (*array).pointers;
		
		unsigned int i;
		for (i = 0; i < (*array).count; ++i)
		{
			[(id)*itemPtr release];
			++itemPtr;
		}
	}
	
	(*array).iterator = (*array).pointers;
	(*array).count = 0;
	(*array).i = 0;
	//*/
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLArray()

// Initializes a new instance.
- (void) initialize;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

BOOL nglPointerIsValid(void *pointer)
{
	if (pointer == NULL)
	{
		return NO;
	}
	
	int i;
	Class testClass = *((Class *)pointer);
	
	if (numClasses == 0 && classesList == NULL)
	{
		numClasses = objc_getClassList(NULL, 0);
		classesList = malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classesList, numClasses);
	}
	
	for (i = 0; i < numClasses; i++)
	{
		if (classesList[i] == testClass)
		{
			return YES;
		}
	}
	
	return NO;
}

BOOL nglPointerIsValidToClass(void *pointer, Class aClass)
{
	return (aClass == *((Class *)pointer));
}

BOOL nglPointerIsValidToProtocol(void *pointer, Protocol *aProtocol)
{
	return class_conformsToProtocol(*((Class *)pointer), aProtocol);
}

BOOL nglPointerIsValidToSelector(void *pointer, SEL selector)
{
	return class_respondsToSelector(*((Class *)pointer), selector);
}

/*
 static sigjmp_buf sigjmp_env;
 
 static void pointerHandler(int signum)
 {
 siglongjmp(sigjmp_env, 1);
 }
 
 BOOL nglPointerIsValid(const void *pointer)
 {
 // Set up SIGSEGV and SIGBUS handlers
 struct sigaction new_segv_action, old_segv_action;
 struct sigaction new_bus_action, old_bus_action;
 new_segv_action.sa_handler = pointerHandler;
 new_bus_action.sa_handler = pointerHandler;
 sigemptyset(&new_segv_action.sa_mask);
 sigemptyset(&new_bus_action.sa_mask);
 new_segv_action.sa_flags = 0;
 new_bus_action.sa_flags = 0;
 sigaction (SIGSEGV, &new_segv_action, &old_segv_action);
 sigaction (SIGBUS, &new_bus_action, &old_bus_action);
 
 // The signal handler will return us to here if a signal is raised
 if (sigsetjmp(sigjmp_env, 1))
 {
 sigaction (SIGSEGV, &old_segv_action, NULL);
 sigaction (SIGBUS, &old_bus_action, NULL);
 return NO;
 }
 
 Class testPointerClass = *((Class *)pointer);
 
 // Get the list of classes and look for testPointerClass
 BOOL isClass = NO;
 NSInteger numClasses = objc_getClassList(NULL, 0);
 Class *classesList = malloc(sizeof(Class) * numClasses);
 numClasses = objc_getClassList(classesList, numClasses);
 for (int i = 0; i < numClasses; i++)
 {
 if (classesList[i] == testPointerClass)
 {
 isClass = YES;
 break;
 }
 }
 free(classesList);
 
 // We're done with the signal handlers (install the previous ones)
 sigaction(SIGSEGV, &old_segv_action, NULL);
 sigaction(SIGBUS, &old_bus_action, NULL);
 
 // Pointer does not point to a valid isa pointer
 if (!isClass)
 {
 return NO;
 }
 
 // Check the allocation size
 
 return YES;
 }
 //*/

@implementation NGLArray

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize retainOption = _retainOption;

@dynamic itemsPointer, mutationsPointer, capacity, values;

- (id *) itemsPointer { return (id *)_values.pointers; }

- (unsigned long *) mutationsPointer { return (unsigned long *)&_values.count; }

- (unsigned int) capacity { return _values.capacity; }
- (void) setCapacity:(unsigned int)value
{
	_values.capacity = (value < _values.count) ? _values.count : value;
}

- (NGLArrayValues *) values { return &_values; }

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		[self initialize];
	}
	
	return self;
}

- (id) initWithRetainOption
{
	if ((self = [super init]))
	{
		[self initialize];
		
		_values.retainOption = YES;
	}
	
	return self;
}

- (id) initWithNGLArray:(NGLArray *)pointers
{
	if ((self = [super init]))
	{
		[self initialize];
		
		[self addPointersFromNGLArray:pointers];
	}
	
	return self;
}

- (id) initWithPointers:(void *)first, ...
{
	if ((self = [super init]))
	{
		[self initialize];
		
		void *pointer;
		va_list list;
		
		// Executes the list to work with all elements until get nil.
		va_start(list, first);
		for (pointer = first; pointer != nil; pointer = va_arg(list, void *))
		{
			[self addPointer:pointer];
		}
		va_end(list);
	}
	
	return self;
}

+ (id) array
{
	return [[[NGLArray alloc] init] autorelease];
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	_values.count = 0;
	_values.i = 0;
	_values.capacity = 0;
	_values.retainOption = NO;
	nglArrayResize(&_values);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) addPointer:(void *)pointer
{
	nglArrayAddPointer(&_values, pointer);
}

- (void) addPointerOnce:(void *)pointer
{

	if (nglArrayIndexOfPointer(&_values, pointer) == NGL_NOT_FOUND)
	{
		nglArrayAddPointer(&_values, pointer);
	}
}

- (void) addPointersFromNGLArray:(NGLArray *)pointers
{
	void *item;
	nglFor (item, pointers)
	{
		nglArrayAddPointer(&_values, item);
	}
}

- (BOOL) hasPointer:(void *)pointer
{
	return (nglArrayIndexOfPointer(&_values, pointer) != NGL_NOT_FOUND);
}

- (unsigned int) indexOfPointer:(void *)pointer
{
	return nglArrayIndexOfPointer(&_values, pointer);
}

- (void) removePointer:(void *)pointer
{
	nglArrayRemovePointer(&_values, pointer);
}

- (void) removePointerAtIndex:(unsigned int)index
{
	nglArrayRemovePointerAtIndex(&_values, index);
}

- (void) removeFirst
{
	nglArrayRemovePointerAtIndex(&_values, 0);
}

- (void) removeLast
{
	nglArrayRemovePointerAtIndex(&_values, _values.count - 1);
}

- (void) removeAll
{
	nglArrayRemoveAll(&_values);
}

- (void *) pointerAtIndex:(unsigned int)index;
{
	if (index >= _values.count)
	{
		[NGLError errorInstantlyWithHeader:PTR_ERROR_HEADER andMessage:PTR_ERROR_BOUNDS];
		return NULL;
	}
	
	return _values.pointers[index];
}

- (unsigned int) count
{
	return _values.count;
}

- (NGLArrayValues *) forLoop:(void **)target
{
	// Resets the iterator saving another Obj-C call.
	_values.i = 0;
	_values.iterator = _values.pointers;
	
	// Sets the first pointer. Avoids BAD_ACCESS to an unknown pointers.
	*target = (_values.count > 0) ? *_values.iterator++ : NULL;
	
	// Return the values to the loop.
	return &_values;
}

- (void *) nextIterator
{
	// Loops iterator until it reach the variables count.
	if (_values.i++ < _values.count)
	{
		return *_values.iterator++;
	}
	// When iterator reach the variables count, resets iterator.
	else
	{
		[self resetIterator];
	}
	
	return NULL;
}

- (void) resetIterator
{
	_values.i = 0;
	_values.iterator = _values.pointers;
}

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state
								   objects:(NGL_ARC_ASSIGN id *)stackbuf
									 count:(NSUInteger)len
{
	//*
    if ((*state).state >= _values.count)
    {
        return 0;
    }
	
	// Runs once. Points mutationPtr to self to avoid error when array changes while looping.
	(*state).itemsPtr = (id *)_values.pointers;
	(*state).state = _values.count;
	(*state).mutationsPtr = (unsigned long *)&_values.count;//self;
	
    return _values.count;
	/*/
	// First loop.
	if ((*state).state == 0)		
	{
		[self resetIterator];
	}
	// Last loop.
	else if ((*state).state >= _values.count)
	{
		[self resetIterator];
		return 0;
	}
	
	// Runs once.
	(*state).itemsPtr = (id *)_values.iterator++;
	(*state).state = ++_values.i;
	(*state).mutationsPtr = (unsigned long *)self;
	
	return 1;
	//*/
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	NSMutableString *string = [[NSMutableString alloc] initWithString:[super description]];
	[string appendString:@"\n"];
	
	// Describes each element in this library.
	void **itemPtr = _values.pointers;
	unsigned int i;
	for (i = 0; i < _values.count; ++i)
	{
		[string appendFormat:@"%p ",*itemPtr++];
	}
	
	[string appendFormat:@"\nCount: %u",_values.count];
	[string appendFormat:@"\nCapacity: %u",_values.capacity];
	[string appendFormat:@"\nRetain: %@",(_values.retainOption ? @"YES" : @"NO")];
	[string appendFormat:@"\nIterator: %u",_values.i];
	
	return [string autorelease];
}

- (void) dealloc
{
	[self removeAll];
	nglFree(_values.pointers);
	
	[super dealloc];
}

@end

#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NGLArray(NGLArrayExtended)

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************


#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (NSArray *) allPointers
{
	return [NSArray arrayWithObjects:(id *)_values.pointers count:_values.count];
}

- (void) makeAllPointersPerformSelector:(SEL)selector
{
	id item;
	nglFor (item, self)
	{
		// Starting at Xcode 4.4, the compiler still showing warnings when using "performSelector"
		// with ARC without declaring its relationship with its holder.
		nglMsg(item, selector);
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end