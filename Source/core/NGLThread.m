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

#import <objc/message.h>

#import "NGLThread.h"

#import "NGLContext.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

NSString *const kNGLThreadHelper = @"NinevehGLHelper";
NSString *const kNGLThreadParser = @"NinevehGLParser";
NSString *const kNGLThreadRender = @"NinevehGLRender";

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

//*************************
//	Thread Task
//*************************

/*!
 *					<strong>(Internal only)</strong> Helps to hold and manage tasks into a thread.
 */
@interface NGLThreadTask : NSObject

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;

- (id) initWithTarget:(id)target selector:(SEL)selector;

- (void) execute;

@end

@implementation NGLThreadTask

@synthesize target = _target, selector = _selector;

- (id) initWithTarget:(id)target selector:(SEL)selector
{
	if ((self = [super init]))
	{
		self.target = target;
		self.selector = selector;
	}
	
	return self;
}

- (void) execute
{
	nglMsg(_target, _selector);
}

- (void) dealloc
{
	nglRelease(_target);
	_selector = nil;
	
	[super dealloc];
}

@end

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NSMutableDictionary *threads()
{
	// Persistent instance.
	static NSMutableDictionary *_default = nil;
	
	// Allocates once with Grand Central Dispatch (GCD) routine. Thread safe.
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
	{
		_default = [[NSMutableDictionary alloc] init];
	});
	
	return _default;
}

static BOOL threadCheck(NSString *name)
{
	BOOL result;
	
	// Identifies if the thread using the name can be used with the actual multithreading option.
	switch (nglDefaultMultithreading)
	{
		case NGLMultithreadingParser:
			result = ([name rangeOfString:kNGLThreadParser].length > 0);
			break;
		case NGLMultithreadingRender:
			result = ([name rangeOfString:kNGLThreadRender].length > 0 ||
					  [name rangeOfString:kNGLThreadHelper].length > 0);
			break;
		case NGLMultithreadingNone:
			result = NO;
			break;
		default:
			result = YES;
			break;
	}
	
	return result;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NGLThread()

- (void) spawnThread;

- (void) killThread;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

NGLThread *nglThreadGet(NSString *name)
{
    __block NGLThread *thread = nil;
    
    static dispatch_once_t onceToken;
    static pthread_mutex_t mutex;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&mutex, NULL);
    });

    // Serialize getting or making a thread.
    pthread_mutex_lock(&mutex);
    
    thread = [threads() objectForKey:name];
    
    // Just start new threads. Old threads will be reused.
    if (thread == nil)
    {
        // The thread is retained internally by the class and will be released only when it exit.
        thread = [[[NGLThread alloc] initWithName:name] autorelease];
    }
    
    pthread_mutex_unlock(&mutex);

    
	return thread;
}

void nglThreadPerformAsync(NSString *name, SEL selector, id target)
{
	// Creates the thread once, if necessary.
	NGLThread *thread = nglThreadGet(name);
	
	[thread performAsync:selector target:target];
}

void nglThreadPerformSync(NSString *name, SEL selector, id target)
{
	// Creates the thread once, if necessary.
	NGLThread *thread = nglThreadGet(name);
	
    NSLog(@"%@ performSync: %@", name, NSStringFromSelector(selector));
	[thread performSync:selector target:target];
}

void nglThreadSetPaused(NSString *name, BOOL paused)
{
	[[threads() objectForKey:name] setPaused:paused];
}

BOOL nglThreadIsPaused(NSString *name)
{
	return [[threads() objectForKey:name] isPaused];
}

void nglThreadSetAutoExit(NSString *name, BOOL autoExit)
{
	[[threads() objectForKey:name] setAutoExit:autoExit];
}

BOOL nglThreadIsAutoExit(NSString *name)
{
	return [[threads() objectForKey:name] isAutoExit];
}

void nglThreadExit(NSString *name)
{
	[[threads() objectForKey:name] killThread];
}

void nglThreadExitAll(void)
{
	NSDictionary *running = [threads() copy];
	NSString *name;
	
	// Kills all threads.
	for (name in running)
	{
		nglThreadExit(name);
	}
	
	nglRelease(running);
	
	if ([NSThread isMainThread])
	{
		// Stuck while the threads are exiting.
		while ([threads() count] > 0)
		{
			usleep(NGL_CYCLE_USEC);
		}
	}
}

@implementation NGLThread

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize name = _name, thread = _thread, alive = _alive, paused = _paused, autoExit = _autoExit;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithName:(NSString *)name
{
	if ((self = [super init]))
	{
		// Settings.
		_name = [name copy];
		_changed = NO;
		_paused = NO;
		
		// Only the render thread is a long-lived one.
		_autoExit = (!([name isEqualToString:kNGLThreadRender]||[name isEqualToString:kNGLThreadHelper]));
        if( [name isEqualToString:@"NinevehGLHelper"] ) {
            NSLog(@"Helper alloc..");
        }
		
		// The threads are internally retained to make future changes on it.
		[threads() setObject:self forKey:_name];
		
#ifdef NGL_MULTITHREADING
		if (threadCheck(_name))
		{
			_queue = [[NGLArray alloc] initWithRetainOption];
			_thread = [[NSThread alloc] initWithTarget:self selector:@selector(spawnThread) object:nil];
			_thread.name = _name;
			[_thread start];
		}
#endif
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) spawnThread
{
	// Thread settings.
	_alive = YES;
	
	// Task settings.
	NGLThreadTask *task;
	BOOL oneTaskDone = NO;
	
	// Thread routine
	while (_alive)
	{
		// Ignores thread processing when paused.
		if (_paused)
		{
			continue;
		}
		
		// Autorelease pool.
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// The thread's run loop. When there is no timer or sources in the run loop it will not wait the
		// NGL cycle (in seconds), so this thread must sleep for a NGL cycle.
		if (CFRunLoopRunInMode(kCFRunLoopDefaultMode, NGL_CYCLE, NO) == kCFRunLoopRunFinished)
		{
			usleep(NGL_CYCLE_USEC);
		}
		
		// Processes the Objc-C messages and frees the previous allocated memory for the message.
		// First-in First-out rule.
        while (_queue.count) {
            // Grab the task off the queue, minimizing thread contention.
            task = [_queue pointerAtIndex:0];

            // Executes the Obj-C message as fast as possible.
            [task execute];
            
            // Then remove and release task.
            [_queue removeFirst];

            // Defines one task done.
            oneTaskDone = YES;
        }

// First-in First-out rule. The first item will be detached, so the iterator "doesn't move".
//		nglFor(task, _queue)
//		{
//			// Executes the Obj-C message as fast as possible.
//			[task execute];
//			
//			// Removes the first task.
//			[_queue removeFirst];
//			
//			// Defines one task done.
//			oneTaskDone = YES;
//		}
		
		// Draining the pool.
		nglRelease(pool);
		
		// The autoExit and changed status will wait for at least one task be done.
		if (oneTaskDone)
		{
			// Autoexit thread after processing the queue.
			if (_autoExit && [_queue count] == 0)
			{
				[self killThread];
			}
			
			// Unflaging the changes.
			_changed = NO;
		}
	}
	
	// Freeing the non-used memory and exiting thread.
	[self cancelAllPendingRequests];
	
	// Sends a message to delete the current EAGLContext, because the context is thread dependent.
	nglContextDeleteCurrent();
}

- (void) killThread
{
	// The thread will exit its entry point routine normally. This is the best approach.
	// The running thread will complete its current queue.
	_alive = NO;
	[threads() removeObjectForKey:_name];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) performAsync:(SEL)selector target:(id)target
{
#ifdef NGL_MULTITHREADING
	if (threadCheck(_name))
	{
		// New messages goes to the end of the queue.
		// The memory allocated here will be free inside the thread.
		NGLThreadTask *task = [[NGLThreadTask alloc] initWithTarget:target selector:selector];
		
		// Adds the new task and change the task queue status.
		[_queue addPointer:task];
		_changed = YES;
		
		nglRelease(task);
		
		return;
	}
#endif
	nglMsg(target, selector);
}

- (void) performSync:(SEL)selector target:(id)target
{
	// If the target thread is not the current thread, waits until the task is finished.
	if (_thread != [NSThread currentThread])
	{
		[self performAsync:selector target:target];
		
		// Waiting for the task be performed.
		while (_changed)
		{
			usleep(NGL_CYCLE_USEC);
		}
	}
	// If the target thread is the current thread, just performs the task.
	else
	{
		nglMsg(target, selector);
	}
}

- (void) cancelAllPendingRequests
{	
	[_queue removeAll];
}

- (void) cancelAllPendingRequestsForTarget:(id)target
{
	unsigned int i = 0;
	NGLThreadTask *task;
	
	// Searches for all occurrences of the target.
	nglFor(task, _queue)
	{
		if (task.target == target)
		{
			[_queue removePointerAtIndex:i];
		}
		
		++i;
	}
}

- (void) exit
{
	[self killThread];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	// Doesn't need to exit the NGLThread because the dealloc can't be called while the thread is alive.
    NSLog(@"Dealloc thread: %@", _name);
    if( [_name isEqualToString:@"NinevehGLHelper"] ) {
        NSLog(@"Helper dealloc!!");
    }
    
	nglRelease(_name);
	nglRelease(_queue);
	nglRelease(_thread);
	
	[super dealloc];
}

@end