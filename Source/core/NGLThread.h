/*
 *	NGLThread.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *  Created by Diney Bomfim on 10/5/11.
 *  Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLGlobal.h"
#import "NGLArray.h"

@class NGLThread;

/*!
 *					This key represents the "helper" thread. Often, it's used as a helper that performs
 *					change on OpenGL structure, create buffers, upload textures, etc.
 *					
 *					NinevehGL spawns only one "helper" thread.
 */
NGL_API NSString *const kNGLThreadHelper;

/*!
 *					This key represents the "parser" thread. NinevehGL can spawn few "parser" threads,
 *					up to a limit defined by the global property.
 */
NGL_API NSString *const kNGLThreadParser;

/*!
 *					This key represents the "render" thread. NinevehGL can spawn only one "render" threads.
 */
NGL_API NSString *const kNGLThreadRender;

/*!
 *					Returns a NGLThread with a specific name. This method will spawn a new threads if the
 *					name doesn't exit yet.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 *
 *	@result			A NGLThread instance.
 */
NGL_API NGLThread *nglThreadGet(NSString *name);

/*!
 *					Adds an item into the queue of a NGLThread. It will be executed asynchronously.
 *
 *					This function will automatically create a short-lived thread if the specified name
 *					doesn't exist yet.
 *
 *					The items in the queue are retained to avoid bad accesses.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 *	
 *	@param			selector
 *					A SEL object.
 *
 *	@param			target
 *					The target object that will receive the method.
 */
NGL_API void nglThreadPerformAsync(NSString *name, SEL selector, id target);

/*!
 *					Executes a task synchronously on a NGLThread.
 *
 *					This function will automatically create a short-lived thread if the specified name
 *					doesn't exist yet.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 *	
 *	@param			selector
 *					A SEL object.
 *
 *	@param			target
 *					The target object that will receive the method.
 */
NGL_API void nglThreadPerformSync(NSString *name, SEL selector, id target);

/*!
 *					Sets the paused state for a NGLThread with a specific name.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 *	
 *	@param			paused
 *					A BOOL data type indicating the paused state to set.
 */
NGL_API void nglThreadSetPaused(NSString *name, BOOL paused);

/*!
 *					Gets the paused state for a NGLThread with a specific name.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 */
NGL_API BOOL nglThreadIsPaused(NSString *name);

/*!
 *					Marks a NGLThread with a specific name to auto-exit.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 *
 *	@param			autoExit
 *					A BOOL data type indicating the autoExit property to set.
 */
NGL_API void nglThreadSetAutoExit(NSString *name, BOOL autoExit);

/*!
 *					Gets the autoExit state for a NGLThread with a specific name.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 */
NGL_API BOOL nglThreadIsAutoExit(NSString *name);

/*!
 *					Immediately marks a NGLThread with a specific name to exit.
 *	
 *	@param			name
 *					A NSString containing the name of the thread.
 */
NGL_API void nglThreadExit(NSString *name);

/*!
 *					Immediately exits all running threads in NinevehGL.
 *
 *					If this function is called from the main thread it will wait for all threads end,
 *					working synchronously, if it's called from another thread it will work asynchronously.
 */
NGL_API void nglThreadExitAll(void);

/*!
 *					The NinevehGL thread class.
 *
 *					This class is responsible for managing the NinevehGL threads. By default, NGLThread
 *					will create short-lived threads, the only exception is to the Render Thread, which
 *					is internally marked as a long-lived one.
 *
 *					The concept of short and long lived threads are a little bit different in NinevehGL:
 *						- Short-Lived: This thread will exit automatically after process at least one task.
 *						- Long-Lived: This thread will not exit until an explicit call make it does.
 *
 *					If a thread is marked as short-lived and during its first task other tasks are placed
 *					into its queue, those new tasks will be processed as well and then it will exit.
 *
 *					The thread routine of NGLThread includes a Run Loop and an Autorelease pool, which
 *					means that obj-c messages can be queued. The Run Loop has the same interval as the
 *					maximum NinevehGL FPS. However, changing the current FPS has no effects over the
 *					Run Loops. This class always exits the thread using the best approach, letting it
 *					finish itself.
 *
 *					The NinevehGL thread pipeline works as following:
 *
 *					<pre>
 *					 ______________________         ______________________         ______________________
 *					|                      |       |                      |       |                      |
 *					|     User Thread*     |       |    Render Thread     |       |    Parser Thread     |
 *					|                      |       |                      |       |                      |
 *					| Usually is the app's |       | All the NinevehGL    |       | NinevehGL can use up |
 *					| main thread, but can |       | render commands are  |       | to X threads like    |
 *					| be any other thread. |       | made in this thread. |       | this one.            |
 *					|                      |       |                      |       |                      |
 *					| You will create and  |       | Also the OpenGL      |       | The loading/parsing  |
 *					| manage your objects  |       | calls are made from  |       | job is done inside   |
 *					| from this thread.    |       | this one.            |       | this thread.         |
 *					|______________________|       |______________________|       |______________________|
 *
 *					        NGLView -------------------> NGLCoreEngine
 *					                                       NGLTimer
 *					
 *					        NGLMesh ----------------------------------------------------> NGLParser**
 *					                                      NGLCoreMesh <------------------------|
 *
 *					       NGLTween ---------------------> NGLTimer
 *
 *					       NGLDebug ---------------------> NGLTimer
 *
 *					</pre>
 *
 */
@interface NGLThread : NSObject
{
@private
	NSString				*_name;
	NSThread				*_thread;
	BOOL					_alive, _paused, _autoExit;
	
	BOOL					_changed;
	//NSMutableArray			*_queue;
	NGLArray				*_queue;
}

/*!
 *					The thread's name.
 */
@property (nonatomic, readonly) NSString *name;

/*!
 *					The NSThread instance.
 */
@property (nonatomic, readonly) NSThread *thread;

/*!
 *					Indicates if this thread is running. It'll return NO if the thread is not started yet
 *					or if it is finishing.
 */
@property (nonatomic, readonly, getter = isAlive) BOOL alive;

/*!
 *					Pauses or resumes this thread.
 */
@property (nonatomic, getter = isPaused) BOOL paused;

/*!
 *					Mark or unmark this thread to auto deletion.
 *
 *					When this thread is marked for deletion, it'll exit after processing the next queue.
 *					If there is no queue, the thread will still alive but marked for deletion.
 */
@property (nonatomic, getter = isAutoExit) BOOL autoExit;

/*!
 *					Initializes a NGLThread instance with a name.
 *
 *					This method will be called to initialize NGLThread anyway. If the single
 *					<code>init</code> method is called, it will call this method with a blank name.
 *
 *	@param			name
 *					The name for this thread.
 *
 *	@result			A new initialized instance.
 */
- (id) initWithName:(NSString *)name;

/*!
 *					Inserts a new item in the queue of this thread.
 *
 *					The items in the queue follow the First-in First-out rule, that means, when a new item
 *					enters in the queue, it assumes the last position and will be processed after all the
 *					current items.
 *
 *					The items in the queue are retained to avoid bad accesses.
 *
 *	@param			selector
 *					A SEL object.
 *
 *	@param			target
 *					The target object that will receive the method.
 */
- (void) performAsync:(SEL)selector target:(id)target;

/*!
 *					Inserts a new item in the queue of this thread and wait until it is performed.
 *
 *					The items in the queue are retained to avoid bad accesses.
 *
 *	@param			selector
 *					A SEL object.
 *
 *	@param			target
 *					The target object that will receive the method.
 */
- (void) performSync:(SEL)selector target:(id)target;

/*!
 *					Cancels all the pending requests to this thread.
 */
- (void) cancelAllPendingRequests;

/*!
 *					Cancels all the pending requests for a specific target.
 *
 *	@param			target
 *					The target object that was informed early in the #performAsync:target:# method.
 */
- (void) cancelAllPendingRequestsForTarget:(id)target;

/*!
 *					Immediately exit this thread, even if there is a pending queue. The pending queues will
 *					be canceled.
 */
- (void) exit;

@end