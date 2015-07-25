/*
 *	NGLShaders.h
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
#import "NGLError.h"
#import "NGLCopying.h"
#import "NGLTexture.h"
#import "NGLSLSource.h"
#import "NGLSLVariables.h"

@class NGLSLSource;

/*!
 *					Defines the NGLShaders protocol.
 *
 *					This protocol defines the NGLShaders kind, it can be produce many NGLShaders types,
 *					like:
 *
 *						- Standard;
 *						- Multi/Sub.
 */
@protocol NGLShaders <NSObject, NGLCopying>

@end

/*!
 *					The custom shaders.
 *
 *					NinevehGL works internally with its own shaders based on NGLMaterial. However, you
 *					can create your very own shaders, loading them from files or writing the source code.
 *
 *					There are three important optionals properties you can set: the vertex shader, the
 *					fragment shader and the variables to the pair of shaders. The NinevehGL's core will
 *					join those optionals properties with its own shaders, creating a new unique shader
 *					behavior to your mesh.
 *
 *					Never call the <code>#variables#</code> property directly, it's reserved only for you
 *					to check the current variables. Use one of the <code>bind*</code> methods to set a
 *					shader variable and <code>#removeVariableWithName:#</code> to remove a shader variable.
 *
 *					When you call one of the <code>bind*</code> methods you specify a pointer to data,
 *					by doing so any new changes to the pointed data will imediatly change the shader
 *					variable value.
 *
 *					NGLShaders is identified by its <code>#identifier#</code> property (ID). If its ID
 *					doesn't match with one of the #NGLSurface#'s ID, it will be ignored on the mesh's
 *					compilation phase. If there is no #NGLSurface# specified, the first NGLShader will
 *					be used.
 *
 *					All the shader variables are optimized to mediump or lowp whenever is possible,
 *					according to their purposes.
 *
 *					The NinevehGL's vertex variables are:
 *
 *						- <strong>attribute vec4 a_nglPosition</strong>: The vertex position, per-vertex.
 *						- <strong>attribute vec2 a_nglTexcoord</strong>: [optional] Used only when
 *							exist Texture Coordinates. Stores the Texture Coordinate Vectors, per-vertex.
 *						- <strong>attribute vec3 a_nglNormal</strong>: [optional] Used only when exist
 *							Normals. Stores the Normal Vectors, per-vertex.
 *						- <strong>attribute vec3 a_nglTangent</strong>: [optional] Used only when exist
 *							Light Effect + Tangent Space. Stores the Tangent Vectors, per-vertex.
 *						- <strong>attribute vec3 a_nglBitangent</strong>: [optional] Used only when exist
 *							Light Effect + Tangent Space. Stores the Bitangent Vector, per-vertex.
 *
 *					The NinevehGL's fragment variables are:
 *
 *						- <strong>varying vec2 v_nglTexcoord</strong>: [optional] Only if exist
 *							Texture Coordinates. Represents the texture coordinates.
 *						- <strong>varying vec3 v_nglNormal</strong>: [optional] Used only when exist
 *							Normals. Represents the normals.
 *						- <strong>varying vec3 v_nglVEye</strong>: [optional] Used only with Light Efx.
 *							It's the calculated "Eye Vector", which is used in many light computations.
 *						- <strong>varying vec3 v_nglVLight</strong>: [optional] Used only with Light Efx.
 *							It's the calculated "Light Vector", which is used in many light computations.
 *						- <strong>varying float v_nglLightLevel</strong>: [optional] Only with Light Efx.
 *							It's the calculated light intensity, which is used in many light computations.
 *						- <strong>varying float v_nglFog</strong>: [optional] Used only with Fog effect.
 *							Represents the final fog percentage in the range (0.0, 1.0).
 *						- <strong>vec4 _nglEmission</strong>: Represents the emissive color component.
 *						- <strong>vec4 _nglAmbient</strong>: Represents the ambient color component.
 *						- <strong>vec4 _nglDiffuse</strong>: Represents the diffuse color component.
 *						- <strong>vec4 _nglSpecular</strong>: Represents the specular color component.
 *						- <strong>vec4 _nglLightness</strong>: Represents the lightness color component.
 *						- <strong>float _nglShininess</strong>: Represents the shininess color component.
 *						- <strong>float _nglAlpha</strong>: Represents the alpha component.
 *						- <strong>vec3 _nglNormal</strong>: [optional] The normalized v_nglNormal.
 *						- <strong>vec3 _nglVEye</strong>: [optional] The normalized v_nglEye.
 *						- <strong>vec3 _nglVLight</strong>: [optional] The normalized v_nglLight.
 *						- <strong>float _nglLightD</strong>: [optional] Used only when exist Light Efx.
 *							It's the Light Delta, the calculated dot product between the "Normal Vector"
 *							and the "Light Vector" (NdotL), which is used in many light computations.
 *						- <strong>float _nglShineD</strong>: [optional] Used only when exist Light Efx.
 *							It's the Shine Delta, the calculated dot product between the "Normal Vector"
 *							and "Half Vector" or the "Reflected" (NdotH or NdotR). The NdotR will be
 *							used in displacement calculations, like bump maps, otherwise, the NdotH will
 *							be used in place to boost the performance.
 *
 *					The NinevehGL's Uniforms can be used in any shader, although they will be used by
 *					NinevehGL in the indicated shader, in this case you don't need to redefine them in the
 *					shader's header:
 *						
 *						- <strong>uniform mat4 u_nglMVPMatrix</strong>: (vertex) The Model View Projection
 *							Matrix for a mesh.
 *						- <strong>uniform mat4 u_nglMIMatrix</strong>: (vertex) [optional] Used only when
 *							exist Light Effect. Represents the inverse Model Matrix.
 *						- <strong>uniform mat4 u_nglWIMatrix</strong>: (vertex) [optional] Used only when
 *							exist Light Effect. Represents the inverse World Matrix (Model + View).
 *						- <strong>uniform vec4 u_nglLightPosition</strong>: (vertex) [optional] Used only
 *							when exist Light Effect. Represents the light position.
 *						- <strong>uniform float u_nglLightAttenuation</strong>: (vertex) [optional] Used
 *							only when exist Light Effect. Represents the light attenuation factor.
 *						- <strong>uniform vec4 u_nglLightColor</strong>: (fragment) [optional] Used only
 *							when exist Light Effect. Represents the light color.
 *						- <strong>uniform float u_nglAlpha</strong>: (fragment) Represents the alpha
 *							component color.
 *						- <strong>uniform sampler2D u_nglAlphaMap</strong>: (fragment) [optional] Only if
 *							exist Texture Coordinates + Alpha Map. Replaces the ambient color component.
 *						- <strong>uniform vec4 u_nglAmbientColor</strong>: (fragment) Represents the
 *							ambient color component.
 *						- <strong>uniform sampler2D u_nglAmbientMap</strong>: (fragment) [optional] Only if
 *							exist Texture Coordinates + Ambient Map. Replaces the ambient color component.
 *						- <strong>uniform vec4 u_nglDiffuseColor</strong>: (fragment) Represents the diffuse
 *							color component.
 *						- <strong>uniform sampler2D u_nglDiffuseMap</strong>: (fragment) [optional] Only if
 *							exist Texture Coordinates + Diffuse Map. Replaces the diffuse color component.
 *						- <strong>uniform vec4 u_nglEmissiveColor</strong>: (fragment) Represents the
 *							emissive color component.
 *						- <strong>uniform sampler2D u_nglEmissiveMap</strong>: (fragment) [optional] Only if
 *							exist Texture Coordinates + Emissive Map. Replaces the emissive color component.
 *						- <strong>uniform vec4 u_nglSpecularColor</strong>: (fragment) Represents the
 *							specular color component.
 *						- <strong>uniform sampler2D u_nglSpecularMap</strong>: (fragment) [optional] Only if
 *							exist Texture Coordinates + Specular Map. Replaces the specular color component.
 *						- <strong>uniform float u_nglShininess</strong>: (fragment) Represents the shininess
 *							light component.
 *						- <strong>uniform sampler2D u_nglShininessMap</strong>: (fragment) [optional] Only
 *							if exist Texture Coordinates + Shininess Map. Replaces the shininess component.
 *						- <strong>uniform sampler2D u_nglBumpMap</strong>: (fragment) [optional] Only if
 *							exist Texture Coordinates + Bump Map. Represents the bump texture map.
 *						- <strong>uniform sampler2D u_nglReflMap</strong>: (fragment) [optional] Only if
 *							exist Normals + Reflective Map. Represents the reflection map.
 *						- <strong>uniform float u_nglReflLevel</strong>: (fragment) [optional] Only if exist 
 *							Normals + Reflective Map. Represents the reflection level.
 *						- <strong>uniform vec4 u_nglFogColor</strong>: (fragment) [optional] Used only when
 *							exist Fog effect. Represents the fog color.
 *						- <strong>uniform float u_nglFogEnd</strong>: (vertex) [optional] Used only when
 *							exist Fog effect. Represents the end distance.
 *						- <strong>uniform float u_nglFogFactor</strong>: (vertex) [optional] Used only when
 *							exist Fog effect. Represents the precalculated fog factor.
 *
 *	@see			NGLMaterial
 *	@see			NGLSurface
 */
@interface NGLShaders : NSObject <NGLShaders>
{
@private
	unsigned int			_identifier;
	
	NGLSLSource				*_vsh;
	NGLSLSource				*_fsh;
	NGLSLVariables			*_variables;
	
	NGLError				*_error;
}

/*!
 *					The identifier of this object.
 */
@property (nonatomic) unsigned int identifier;

/*!
 *					Represents the custom vertex shader.
 */
@property (nonatomic, readonly) NGLSLSource *vertex;

/*!
 *					Represents the custom fragment shader.
 */
@property (nonatomic, readonly) NGLSLSource *fragment;

/*!
 *					Represents the custom shader variables. Never call this property directly to set or
 *					remove a variable from these shaders. Instead, make use one of the <code>bind*</code>
 *					methods to add a variable and <code>#removeVariableWithName:#</code> to remove one
 *					of them.
 *
 *	@see			bindAttribute:stride:dataType:data:
 *	@see			bindUniform:count:dataType:data:
 *	@see			removeVariableWithName:
 */
@property (nonatomic, readonly) NGLSLVariables *variables;

/*!
 *					Initializes this NGLShaders with one or two shaders inside based on source code.
 *					The source must be inside a NSString.
 *
 *	@param			vsh
 *					A NSString containing source code for the vertex shader.
 *
 *	@param			fsh
 *					A NSString containing source code for the fragment shader.
 *
 *	@result			A new initialized NGLShaders instance.
 */
- (id) initWithSourcesVertex:(NSString *)vsh andFragment:(NSString *)fsh;

/*!
 *					Initializes this NGLShaders with one or two shader inside based on files. This method
 *					will use NinevehGL Global Path to search the files.
 *
 *	@param			vshPath
 *					A NSString representing the file path for the vertex shader.
 *
 *	@param			fshPath
 *					A NSString representing the file path for the fragment shader.
 *
 *	@result			A new initialized NGLShaders instance.
 */
- (id) initWithFilesVertex:(NSString *)vshPath andFragment:(NSString *)fshPath;

/*!
 *					Creates and binds a new attribute variable to the shaders.
 *
 *					The attribute represents a dynamic value. Usually its data are an array where each
 *					element represents a value to be used during a vertex processing. Values that are
 *					intended to be constant through all the vertices, should be Uniforms rather
 *					than Attributes.
 *
 *	@param			name
 *					A NSString containing exactly the same name as the variable has inside the shaders.
 *
 *	@param			stride
 *					The stride of each set of values. This value is given in basic machine units (bytes).
 *
 *	@param			dataType
 *					The shader data type. You must use one of the NinevehGL correlated definitions:
 *
 *						- <strong>NGL_FLOAT</strong> = float;
 *						- <strong>NGL_VEC2</strong> = vec2;
 *						- <strong>NGL_VEC3</strong> = vec3;
 *						- <strong>NGL_VEC4</strong> = vec4;
 *						- <strong>NGL_MAT2</strong> = mat2;
 *						- <strong>NGL_MAT3</strong> = mat3;
 *						- <strong>NGL_MAT4</strong> = mat4.
 *
 *					Attributes just accept floating points data types.
 *
 *	@param			data
 *					A pointer to the data source.
 */
- (void) bindAttribute:(NSString *)name stride:(int)stride dataType:(int)dataType data:(void *)data;

/*!
 *					Creates and binds a new uniform variable to the shaders.
 *
 *					The uniform represents a constant value. Its data can be a single instance or an array.
 *					In case of an arrays of uniforms, you must specify the array's length with the
 *					<code>#count#</code> param.
 *
 *	@param			name
 *					A NSString containing exactly the same name as the variable has inside the shaders.
 *					This NSString will be internally retained as a key.
 *
 *	@param			count
 *					The elements count. For array it should be the array's length, for single instances it
 *					should be 1.
 *
 *	@param			dataType
 *					The shader data type. You must use one of the NinevehGL correlated definitions:
 *
 *						- <strong>NGL_FLOAT</strong> = float;
 *						- <strong>NGL_INT</strong> = int;
 *						- <strong>NGL_BOOL</strong> = bool;
 *						- <strong>NGL_VEC2</strong> = vec2;
 *						- <strong>NGL_VEC3</strong> = vec3;
 *						- <strong>NGL_VEC4</strong> = vec4;
 *						- <strong>NGL_IVEC2</strong> = ivec2;
 *						- <strong>NGL_IVEC3</strong> = ivec3;
 *						- <strong>NGL_IVEC4</strong> = ivec4;
 *						- <strong>NGL_BVEC2</strong> = bvec2;
 *						- <strong>NGL_BVEC3</strong> = bvec3;
 *						- <strong>NGL_BVEC4</strong> = bvec4;
 *						- <strong>NGL_MAT2</strong> = mat2;
 *						- <strong>NGL_MAT3</strong> = mat3;
 *						- <strong>NGL_MAT4</strong> = mat4;
 *
 *	@param			data
 *					A pointer to the data source.
 */
- (void) bindUniform:(NSString *)name count:(int)count dataType:(int)dataType data:(void *)data;

/*!
 *					Creates and binds a new texture variable to the shaders.
 *
 *					This method is specific for any kind of textures in the shaders, as the textures form
 *					a special data type group in GLSL. It'll bind a #NGLTexture# with a shader variable
 *					uniform. The data type will depend on the #NGLTexture# type.
 *
 *	@param			name
 *					A NSString containing exactly the same name as the variable has inside the shaders.
 *					This NSString will be internally retained as a key.
 *
 *	@param			texture
 *					The initialized #NGLTexture# instance.
 */
- (void) bindTexture:(NSString *)name texture:(NGLTexture *)texture;

/*!
 *					Removes a variable previously bound to the shaders.
 *
 *					This method will remove a specific variable which was previously bound to these shaders.
 *
 *	@param			name
 *					A NSString containing exactly the same name as the variable has inside the shaders.
 *					This NSString will be internally retained as a key.
 */
- (void) removeVariableWithName:(NSString *)name;

/*!
 *					Returns an autorelease instance of NGLShaders.
 *
 *					This method creates a shader pair with some source code in it.
 *
 *	@param			vsh
 *					A NSString containing source code for the vertex shader.
 *
 *	@param			fsh
 *					A NSString containing source code for the fragment shader.
 *
 *	@result			A NGLShaders autoreleased instance.
 */
+ (id) shadersWithSourcesVertex:(NSString *)vsh andFragment:(NSString *)fsh;

/*!
 *					Returns an autorelease instance of NGLShaders.
 *
 *					This method creates a shader pair with the source code from file(s). The file will
 *					be searched using the NinevehGL Global Path.
 *
 *	@param			vshPath
 *					A NSString representing the file path for the vertex shader.
 *
 *	@param			fshPath
 *					A NSString representing the file path for the fragment shader.
 *
 *	@result			A new initialized NGLShaders instance.
 */
+ (id) shadersWithFilesVertex:(NSString *)vshPath andFragment:(NSString *)fshPath;

@end