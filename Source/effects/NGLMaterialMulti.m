/*
 *	NGLMaterialMulti.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/16/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLMaterialMulti.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLMaterialMulti()

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

@implementation NGLMaterialMulti

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
		[self initialize];
	}
	
	return self;
}

- (id) initWithMaterials:(NGLMaterial *)first, ...
{
	if ((self = [super init]))
	{
		[self initialize];
		
		va_list list;
		NGLMaterial * material;
		
		// Executes all elements of the list until get nil.
		va_start(list, first);
		for (material = first; material != nil; material = va_arg(list, NGLMaterial *))
		{
			[self addMaterial:material];
		}
		va_end(list);
	}
	
	return self;
}

- (id) initWithMaterialKind:(id <NGLMaterial>)material
{
	if ((self = [super init]))
	{
		[self initialize];
		
		if ([material isKindOfClass:[self class]])
		{
			[self addNGLMaterialMulti:(NGLMaterialMulti *)material copyItems:NO];
		}
		else
		{
			[self addMaterial:(NGLMaterial *)material];
		}
	}
	
	return self;
}

+ (id) materialMultiWithMaterial:(NGLMaterial *)first
{
	NGLMaterialMulti *materialMulti = [[NGLMaterialMulti alloc] initWithMaterials:first, nil];
	
	return [materialMulti autorelease];
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initialize
{
	// Settings.
	_collection = [[NGLArray alloc] initWithRetainOption];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (id) copyInstance
{
	id copy = [[[self class] allocWithZone:nil] init];
	
	// Copying properties.
	[self defineCopyTo:copy shared:YES];
	
	return copy;
}

- (id) copyWithZone:(NSZone *)zone
{
	id copy = [[[self class] allocWithZone:zone] init];
	
	// Copying properties.
	[self defineCopyTo:copy shared:NO];
	
	return copy;
}

- (void) defineCopyTo:(id)aCopy shared:(BOOL)isShared
{
	NGLMaterialMulti *copy = aCopy;
	
	// Copying properties.
	if (isShared)
	{
		[copy addNGLMaterialMulti:self copyItems:NO];
	}
	else
	{
		[copy addNGLMaterialMulti:self copyItems:YES];
	}
}

- (void) addMaterial:(NGLMaterial *)item
{
	// Adds the target once.
	if (![_collection hasPointer:item])
	{
		[_collection addPointer:item];
		
		// Sets the identifier automatically, if no one was specified.
		if (item.identifier == 0)
		{
			item.identifier = [_collection count];
		}
	}
}

- (void) addNGLMaterialMulti:(NGLMaterialMulti *)multi copyItems:(BOOL)flag
{
	NGLMaterial *item, *copy;
	
	for (item in multi)
	{
		if (flag)
		{
			copy = [item copy];
			[self addMaterial:copy];
			nglRelease(copy);
		}
		else
		{
			[self addMaterial:item];
		}
	}
}

- (BOOL) hasMaterial:(NGLMaterial *)item
{
	return [_collection hasPointer:item];
}

- (void) removeAll
{
	[_collection removeAll];
}

- (NGLMaterial *) materialWithName:(NSString *)name
{
	NGLMaterial *item = nil;
	
	for (item in _collection)
	{
		if ([item.name isEqualToString:name])
		{
			break;
		}
	}
	
	return item;
}

- (NGLMaterial *) materialWithIdentifier:(unsigned int)identifier
{
	NGLMaterial *item = nil;
	
	for (item in _collection)
	{
		if (item.identifier == identifier)
		{
			break;
		}
	}
	
	return item;
}

- (NGLMaterial *) materialAtIndex:(unsigned int)index
{
	return [_collection pointerAtIndex:index];
}

- (unsigned int) count
{
	return [_collection count];
}

- (void *) nextIterator
{
	return [_collection nextIterator];
}

- (void) resetIterator
{
	[_collection resetIterator];
}

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state
								   objects:(NGL_ARC_ASSIGN id *)stackbuf
									 count:(NSUInteger)len
{
	unsigned int count = [_collection count];
	
    if ((*state).state >= count)
    {
        return 0;
    }
	
	// Runs once. Points mutationPtr to self to avoid error when array changes while looping.
	(*state).itemsPtr = _collection.itemsPointer;
	(*state).state = count;
	(*state).mutationsPtr = _collection.mutationsPointer;
	
    return count;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	NSMutableString *string = [[NSMutableString alloc] initWithString:[super description]];
	NGLMaterial *material;
	
	// Describes each element in this library.
	for (material in _collection)
	{
		[string appendString:[material description]];
	}
	
	return [string autorelease];
}

- (void) dealloc
{
	nglRelease(_collection);
	
	[super dealloc];
}

@end