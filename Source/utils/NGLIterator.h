/*
 *	NGLIterator.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 1/2/12.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

/*!
 *					The NGLIterator protocol defines the basic methods to use the Iterator Pattern
 *					(Design Pattern).
 *
 *					Unlike NSFastEnumeration, this protocol works with any kind of data type, including
 *					the basic C data types. To use the iterator you can use it within a while loop.
 *
 *					The advantage of the iterator is that it can handle changes inside the collection
 *					during the loop without break the integrity.
 */
@protocol NGLIterator

@required

/*!
 *					Iterator loop throughout this library's instances.
 *
 *					This method returns a pointer to each object/instance inside this library. It uses
 *					the iterator pattern to create an ordered loop from the first element to the last one.
 *					To use this method call it inside a <code>while</code> loop:
 *
 *					<pre>
 *
 *					id variable;
 *
 *					while ((variable = [myClassWithIterator nextIterator]))
 *					{
 *					    // Do something...
 *					}
 *
 *					</pre>
 *
 *					The iterator will be automatically reseted every time it reaches the end of this
 *					library. But if you need to reset the iterator before it reaches the end of this
 *					library, use the <code>#resetIterator#</code> method.
 *
 *	@result			A pointer or NULL when reaches the end.
 *
 *	@see			resetIterator
 */
- (void *) nextIterator;

/*!
 *					Forces the iterator pattern return to 0.
 *
 *					Using the <code>#nextIterator#</code> method, the iterator pattern will be returned to
 *					0 automatically, but if you need to reset the iterator pattern before the last loop you
 *					can call this method.
 *
 *	@see			nextIterator
 */
- (void) resetIterator;

@end