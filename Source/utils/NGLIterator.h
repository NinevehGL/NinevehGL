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