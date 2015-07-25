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

#import "NGLRuntime.h"
#import "NGLMesh.h"
#import "NGLMaterial.h"
#import "NGLShaders.h"
#import "NGLLight.h"
#import "NGLFog.h"

/*!
 *					<strong>(Internal only)</strong> Constructs the shaders based on GLSL ES.
 *
 *					This function is responsible for creating all the shaders content of NinevehGL.
 *					It can Create shaders with the following effects:
 *
 *						- Alpha Color or Map;
 *						- Ambient Color or Map;
 *						- Diffuse Color or Map;
 *						- Emissive Color or Map;
 *						- Specular Color or Map;
 *						- Bump Map;
 *						- Reflection Map;
 *						- Specular and Shininess effect;
 *						- Light effect;
 *						- Fog effect.
 *
 *	@param			material
 *					The base single #NGLMaterial# instance to generate the shader for.
 *
 *	@param			shaders
 *					A NGLShaders which will receive the new shader strings.
 *
 *	@param			mesh
 *					The base NGLMesh which will work with this new shader.
 *
 *	@see			NGLMaterial
 *	@see			NGLShaders
 *	@see			NGLMesh
 */
NGL_API void nglConstructShaders(NGLShaders *shaders, NGLMaterial *material, NGLMesh *mesh);

NGL_API void nglPrepareTelemetryShaders(NGLShaders *shaders, void *data);

/*!
 *					<strong>(Internal only)</strong> Constructs shaders to be used as telemetry technique.
 *
 *					The telemetry technique is used to set a kind of ID to each mesh in the render image.
 *
 *	@param			shaders
 *					A NGLShaders which will receive the new shader strings.
 *
 *	@see			NGLShaders
 */
NGL_API void nglConstructTelemetryShaders(NGLShaders *shaders);