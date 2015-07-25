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

#pragma mark -
#pragma mark NinevehGL Animation
#pragma mark -
//**************************************************
//	NinevehGL Animation
//**************************************************

#import <NinevehGL/NGLEase.h>
#import <NinevehGL/NGLTween.h>

#pragma mark -
#pragma mark NinevehGL Base
#pragma mark -
//**************************************************
//	NinevehGL Core
//**************************************************

#import <NinevehGL/NGLCamera.h>
#import <NinevehGL/NGLContext.h>
#import <NinevehGL/NGLCopying.h>
#import <NinevehGL/NGLCoreEngine.h>
#import <NinevehGL/NGLCoreMesh.h>
#import <NinevehGL/NGLCoreTimer.h>
#import <NinevehGL/NGLDataType.h>
#import <NinevehGL/NGLError.h>
#import <NinevehGL/NGLFunctions.h>
#import <NinevehGL/NGLGlobal.h>
#import <NinevehGL/NGLGroup3D.h>
#import <NinevehGL/NGLMesh.h>
#import <NinevehGL/NGLMeshElements.h>
#import <NinevehGL/NGLObject3D.h>
#import <NinevehGL/NGLRuntime.h>
#import <NinevehGL/NGLTexture.h>
#import <NinevehGL/NGLThread.h>
#import <NinevehGL/NGLTimer.h>
#import <NinevehGL/NGLView.h>

#pragma mark -
#pragma mark NinevehGL Effects
#pragma mark -
//**************************************************
//	NinevehGL Effects
//**************************************************

#import <NinevehGL/NGLFog.h>
#import <NinevehGL/NGLLight.h>
#import <NinevehGL/NGLMaterial.h>
#import <NinevehGL/NGLMaterialMulti.h>
#import <NinevehGL/NGLSurface.h>
#import <NinevehGL/NGLSurfaceMulti.h>
#import <NinevehGL/NGLShaders.h>
#import <NinevehGL/NGLShadersMulti.h>

#pragma mark -
#pragma mark NinevehGL Math
#pragma mark -
//**************************************************
//	NinevehGL Math
//**************************************************

#import <NinevehGL/NGLMath.h>
#import <NinevehGL/NGLMatrix.h>
#import <NinevehGL/NGLQuaternion.h>
#import <NinevehGL/NGLVector.h>

#pragma mark -
#pragma mark NinevehGL Shader
#pragma mark -
//**************************************************
//	NinevehGL Shader
//**************************************************

#import <NinevehGL/NGLSLSource.h>
#import <NinevehGL/NGLSLVariables.h>

#pragma mark -
#pragma mark NinevehGL Utils
#pragma mark -
//**************************************************
//	NinevehGL Utils
//**************************************************

#import <NinevehGL/NGLArray.h>
#import <NinevehGL/NGLDebug.h>
#import <NinevehGL/NGLGestures.h>
#import <NinevehGL/NGLIterator.h>
#import <NinevehGL/NGLRegEx.h>