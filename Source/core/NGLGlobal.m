/*
 *	NGLGlobal.m
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 3/14/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLGlobal.h"

#import "NGLMath.h"
#import "NGLTimer.h"
#import "NGLView.h"
#import "NGLMesh.h"
#import "NGLThread.h"

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

// Internal state for global changes.
typedef enum
{
	NGLGlobalChangeNone		= 0x00,
    NGLGlobalChangeEngines	= 0x01,
	NGLGlobalChangeMeshes	= 0x02,
} NGLGlobalChange;

// The queued instruction for the global state.
static NGLGlobalChange _globalChange = NGLGlobalChangeNone;

#pragma mark -
#pragma mark Global Properties
#pragma mark -
//**********************************************************************************************************
//
//	Global Properties
//
//**********************************************************************************************************

NSString				*nglDefaultPath					= nil;
unsigned short			nglDefaultFPS					= NGL_MAX_FPS;
NGLEngineVersion		nglDefaultEngine				= NGLEngineVersionES2;
NGLColorFormat			nglDefaultColorFormat			= NGLColorFormatRGB;
NGLvec4					nglDefaultColor					= {0.3f, 0.4f, 0.5f, 1.0f};
NGLFrontFace			nglDefaultFrontFace				= NGLFrontFaceCCW;
NGLCullFace				nglDefaultCullFace				= NGLCullFaceBack;
NGLAntialias			nglDefaultAntialias				= NGL_NULL;
NGLTextureQuality		nglDefaultTextureQuality		= NGL_NULL;
NGLTextureRepeat		nglDefaultTextureRepeat			= NGL_NULL;
NGLTextureOptimize		nglDefaultTextureOptimize		= NGL_NULL;
NGLRotationSpace		nglDefaultRotationSpace			= NGL_NULL;
NGLRotationOrder		nglDefaultRotationOrder			= NGL_NULL;
NSDictionary			*nglDefaultImportSettings		= nil;
NGLLightEffects			nglDefaultLightEffects			= NGLLightEffectsON;
NGLMultithreading		nglDefaultMultithreading		= NGLMultithreadingFull;

#pragma mark -
#pragma mark Global Functions
#pragma mark -
//**********************************************************************************************************
//
//	Global Functions
//
//**********************************************************************************************************

void nglGlobalFlush(void)
{
	// Updates all engines.
	if (_globalChange & NGLGlobalChangeEngines)
	{
		[NGLView updateAllViews];
	}
	
	// Updates all meshes.
	if (_globalChange & NGLGlobalChangeMeshes)
	{
		[NGLMesh updateAllMeshes];
	}
	
	_globalChange = NGLGlobalChangeNone;
}

void nglGlobalFilePath(NSString *filePath)
{
	nglRelease(nglDefaultPath);
	nglDefaultPath = [filePath copy];
}

void nglGlobalFPS(unsigned short fps)
{
	nglDefaultFPS = nglClamp(fps, 1, NGL_MAX_FPS);
	[[NGLTimer defaultTimer] setPaused:NO];
}

void nglGlobalEngine(NGLEngineVersion engine)
{
	nglDefaultEngine = engine;
	
	// This change affects Engines and Meshes.
	_globalChange |= NGLGlobalChangeEngines | NGLGlobalChangeMeshes;
}

void nglGlobalColor(NGLvec4 color)
{
	nglDefaultColor = color;
	
	// This change affects Engines.
	_globalChange |= NGLGlobalChangeEngines;
}

void nglGlobalColorFormat(NGLColorFormat colorFormat)
{
	nglDefaultColorFormat = colorFormat;
	
	// This change affects Engines and Meshes.
	_globalChange |= NGLGlobalChangeEngines | NGLGlobalChangeMeshes;
}

void nglGlobalFrontAndCullFace(NGLFrontFace front, NGLCullFace cull)
{
	nglDefaultFrontFace = front;
	nglDefaultCullFace = cull;
	
	// This change affects Engines.
	_globalChange |= NGLGlobalChangeEngines;
}

void nglGlobalAntialias(NGLAntialias antialias)
{
	nglDefaultAntialias = antialias;
	
	// This change affects Engines.
	_globalChange |= NGLGlobalChangeEngines;
}

void nglGlobalTextureQuality(NGLTextureQuality quality)
{
	nglDefaultTextureQuality = quality;
}

void nglGlobalTextureRepeat(NGLTextureRepeat repeat)
{
	nglDefaultTextureRepeat = repeat;
}

void nglGlobalTextureOptimize(NGLTextureOptimize optimize)
{
	nglDefaultTextureOptimize = optimize;
}

void nglGlobalRotationSpace(NGLRotationSpace space)
{
	nglDefaultRotationSpace = space;
}

void nglGlobalRotationOrder(NGLRotationOrder order)
{
	nglDefaultRotationOrder = order;
}

void nglGlobalImportSettings(NSDictionary *settings)
{
	nglRelease(nglDefaultImportSettings);
	nglDefaultImportSettings = [settings copy];
}

void nglGlobalLightEffects(NGLLightEffects effect)
{
	nglDefaultLightEffects = effect;
	
	// This change affects Meshes.
	_globalChange |= NGLGlobalChangeMeshes;
}

void nglGlobalMultithreading(NGLMultithreading option)
{
	// Pauses the NGLTimer.
	[[NGLTimer defaultTimer] setPaused:YES];
	
	// Cleans up the current Buffers.
	[NGLMesh emptyAllMeshes];
	[NGLView emptyAllViews];
	
	// Exits all NGLThreads.
	nglThreadExitAll();
	
	// Updates the thread option.
	nglDefaultMultithreading = option;
	
	// Updates all buffers.
	[NGLView updateAllViews];
	[NGLMesh updateAllMeshes];
	
	// Resumes the NGLTimer.
	[[NGLTimer defaultTimer] setPaused:NO];
}