/*
 *	NGLGroup3D.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 11/21/11.
 *	Copyright (c) 2010 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLArray.h"
#import "NGLObject3D.h"
#import "NGLIterator.h"

/*!
 *
 *					Compared to Cocoa Framework, the relation between NGLObject3D and NGLGroup3D is similar
 *					to UIView and UIWindow, respectively. The NGLGroup3D is a subclass of NGLObject3D, so
 *					it have all the properties and behavior of an NGLObject3D.
 *
 *					As the UIView, each NGLObject3D can have only one group at a time, but a NGLGroup3D can
 *					hold many NGLObject3D, just as an UIWindow. If you try to attach an object to a group
 *					and that object is already attached to another group, it will be automatically
 *					detached from the old one and will be attached to the new group.
 */
@interface NGLGroup3D : NGLObject3D <NGLIterator, NSFastEnumeration>
{
@private
	NGLArray				*_collection;
}

/*!
 *					Initializes a 3d group instance with some objects attached into it. The #NGLGroup3D#
 *					will retain the objects internally.
 *
 *					This method requires nil termination.
 *
 *	@param			firstObject
 *					The first 3D objects (NGLObject3D) to be added, followed by a comma.
 *
 *	@param			...
 *					A list of 3D objects, all followed by commas. This method requires a nil termination.
 *
 *	@result			A new initialized instance.
 */
- (id) initWithObjects:(NGLObject3D *)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 *					Adds a new object to this group. The group will retain the objectes internally.
 *
 *					If an object is already attached to this group, new attempts to put it in the same
 *					group will be ignored. Each object can be attached to only one group. If an object
 *					already has a group, it will be detached from the old one and attached to this one.
 *
 *	@param			object
 *					A NGLObject3D to be attached to this group.
 */
- (void) addObject:(NGLObject3D *)object;

/*!
 *					Checks if a specific object is already attached to this group.
 *
 *					Return a BOOL indicating if the object is or not attached to this group.
 *
 *	@param			object
 *					A NGLObject3D to search for.
 *
 *	@result			A BOOL data type indicating if the object is attached to this group.
 */
- (BOOL) hasObject:(NGLObject3D *)object;

/*!
 *					Checks if there is at least one occurence of an object with the specified name.
 *
 *					Return a BOOL indicating if the object is or not attached to this group.
 *
 *	@param			tag
 *					An int to search for.
 *
 *	@result			A BOOL data type indicating if the object is attached to this group.
 */
- (BOOL) hasObjectWithTag:(int)tag;

/*!
 *					Checks if there is at least one occurence of an object with the specified name.
 *
 *					Return a BOOL indicating if the object is or not attached to this group.
 *
 *	@param			name
 *					A NSString containing the name to search for.
 *
 *	@result			A BOOL data type indicating if the object is attached to this group.
 */
- (BOOL) hasObjectWithName:(NSString *)name;

/*!
 *					Removes a specific object attached to this group. The objects will receive a release
 *					message when removed from group.
 *
 *					If the object is not found in this group, this method does nothing.
 *
 *	@param			object
 *					A NGLObject3D to remove.
 */
- (void) removeObject:(NGLObject3D *)object;

/*!
 *					Removes all occurences of an object with a tag. The objects will receive a release
 *					message when removed from the group.
 *
 *					If the object is not found in this group, this method does nothing.
 *
 *	@param			tag
 *					An int to search for.
 */
- (void) removeObjectWithTag:(int)tag;

/*!
 *					Removes all occurences of an object with a name. The objects will receive a release
 *					message when removed from the group.
 *
 *					If the object is not found in this group, this method does nothing.
 *
 *	@param			name
 *					A NSString containing the name to search for.
 */
- (void) removeObjectWithName:(NSString *)name;

/*!
 *					Removes all objects attached to this group. All the objects will receive a
 *					release message.
 *
 *					If no object was found in this group, this method does nothing.
 */
- (void) removeAll;

/*!
 *					Retrieves a reference of a NSObject3D in this group based on its tag. Only the first
 *					occurence of the name will be returned.
 *
 *	@param			tag
 *					An int to search for.
 *
 *	@result			A NGLObject3D reference.
 */
- (NGLObject3D *) objectWithTag:(int)tag;

/*!
 *					Retrieves a reference of a NSObject3D in this group based on its name. Only the first
 *					occurence of the name will be returned.
 *
 *	@param			name
 *					A NSString containing the name to search for.
 *
 *	@result			A NGLObject3D reference.
 */
- (NGLObject3D *) objectWithName:(NSString *)name;

/*!
 *					Returns the number of object currently attached to this group.
 *
 *	@result			An int data type.
 */
- (unsigned int) count;

@end