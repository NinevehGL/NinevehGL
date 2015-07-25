/*
 *	NGLSLConstructor.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *	
 *	Created by Diney Bomfim on 2/18/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
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