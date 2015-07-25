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

#import "NGLSLConstructor.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

typedef enum
{
	NGLShadingBlinn		= 0x01,
	NGLShadingPhong		= 0x02,
} NGLShading;

typedef struct
{
	NSString *const header;
	NSString *const body;
} NGLSLStrings;

#pragma mark -
#pragma mark Base (Position & FragColor)
//**************************************************
//	Base (Position & FragColor)
//**************************************************

NGLSLVariable UNI_MATRIX_MVP = { NO, @"u_nglMVPMatrix", 0, 1, NGL_MAT4, 0, NULL, NULL };

NGLSLVariable ATT_VERTEX = { YES, @"a_nglPosition", 0, 4, NGL_FLOAT, 0, NULL, NULL };

NGLSLStrings VSH_BASE =
{
	// Header.
	@"\
	uniform highp mat4 u_nglMVPMatrix;\n\
	attribute highp vec4 a_nglPosition;\n",
	
	// Body.
	@"\
	gl_Position = u_nglMVPMatrix * a_nglPosition;\n"
};

NGLSLStrings FSH_BASE =
{
	// Header.
	@"\
	lowp vec4 _nglEmission = vec4(0.0);\n\
	lowp vec4 _nglAmbient = vec4(0.0);\n\
	lowp vec4 _nglDiffuse = vec4(0.0);\n\
	lowp vec4 _nglSpecular = vec4(0.0);\n\
	lowp vec4 _nglLightF = vec4(1.0);\n\
	lowp float _nglShineF = 1.0;\n\
	lowp float _nglAlpha = 1.0;\n",
	
	// Body.
	nil
};

NGLSLStrings FSH_FINAL =
{
	// Header.
	nil,
	
	// Body.
	@"\
	gl_FragColor = _nglEmission + _nglAmbient + _nglDiffuse * _nglLightF + _nglSpecular * _nglShineF;\n\
	gl_FragColor.a = _nglAlpha * _nglDiffuse.a;\n"
};

#pragma mark -
#pragma mark Telemetry
//**************************************************
//	Telemetry
//**************************************************

NGLSLVariable UNI_TELEMETRY = { NO, @"u_nglTelemetry", 0, 1, NGL_VEC4, 0, NULL, NULL };

NGLSLStrings FSH_TELEMETRY =
{
	// Header.
	@"\
	uniform lowp vec4 u_nglTelemetry;\n",
	
	// Body.
	@"\
	gl_FragColor = u_nglTelemetry;"
};

#pragma mark -
#pragma mark UV Map (Texcoord)
//**************************************************
//	UV Map (Texcoord)
//**************************************************

NGLSLVariable ATT_MAP = { YES, @"a_nglTexcoord", 0, 2, NGL_FLOAT, 0, NULL, NULL };

NGLSLStrings VSH_MAP =
{
	// Header.
	@"\
	attribute lowp vec2 a_nglTexcoord;\n\
	varying lowp vec2 v_nglTexcoord;\n",
	
	// Body.
	@"\
	v_nglTexcoord = a_nglTexcoord;\n"
};

NGLSLStrings FSH_MAP =
{
	// Header.
	@"\
	varying lowp vec2 v_nglTexcoord;\n",
	
	// Body.
	nil
};

#pragma mark -
#pragma mark Surface (Normal)
//**************************************************
//	Surface (Normal)
//**************************************************

NGLSLVariable ATT_NORMAL = { YES, @"a_nglNormal", 0, 3, NGL_FLOAT, 0, NULL, NULL };

NGLSLStrings VSH_NORMAL =
{
	// Header.
	@"\
	attribute lowp vec3 a_nglNormal;\n\
	varying lowp vec3 v_nglNormal;\n",
	
	// Body.
	@"\
	v_nglNormal = a_nglNormal;\n"
};

NGLSLStrings FSH_NORMAL =
{
	// Header.
	@"\
	varying lowp vec3 v_nglNormal;\n\
	lowp vec3 _nglNormal;\n",
	
	// Body.
	@"\
	_nglNormal = normalize(v_nglNormal);\n"
};

#pragma mark -
#pragma mark Tangent Space
//**************************************************
//	Tangent Space
//**************************************************

NGLSLVariable ATT_TANGENT = { YES, @"a_nglTangent", 0, 3, NGL_FLOAT, 0, NULL, NULL };
NGLSLVariable ATT_BITANGENT = { YES, @"a_nglBitangent", 0, 3, NGL_FLOAT, 0, NULL, NULL };

//lowp vec3 _nglBitangent = normalize(cross(a_nglNormal, a_nglTangent));
NGLSLStrings VSH_TANGENT =
{
	// Header.
	@"\
	attribute lowp vec3 a_nglTangent;\n\
	attribute lowp vec3 a_nglBitangent;\n\
	lowp mat3 _nglTBNMatrix;\n",
	
	// Body.
	@"\
	_nglTBNMatrix = mat3(a_nglTangent, a_nglBitangent, a_nglNormal);\n\
	v_nglVEye *= _nglTBNMatrix;\n\
	v_nglVLight *= _nglTBNMatrix;\n"
};

NGLSLStrings FSH_TANGENT =
{
	// Header.
	nil,
	
	// Body.
	nil
};

#pragma mark -
#pragma mark Fog
//**************************************************
//	Fog
//**************************************************

NGLSLVariable UNI_FOG_END = { NO, @"u_nglFogEnd", 0, 1, NGL_FLOAT, 0, NULL, NULL };
NGLSLVariable UNI_FOG_COLOR = { NO, @"u_nglFogColor", 0, 1, NGL_VEC4, 0, NULL, NULL };
NGLSLVariable UNI_FOG_FACTOR = { NO, @"u_nglFogFactor", 0, 1, NGL_FLOAT, 0, NULL, NULL };

NGLSLStrings VSH_FOG =
{
	// Header.
	@"\
	uniform highp float u_nglFogEnd;\n\
	uniform highp float u_nglFogFactor;\n\
	varying lowp float v_nglFog;\n",
	
	// Body.
	@"\
	v_nglFog = clamp((u_nglFogEnd - length(gl_Position)) / u_nglFogFactor, 0.0, 1.0);\n"
};

NGLSLStrings FSH_FOG =
{
	// Header.
	@"\
	varying lowp float v_nglFog;\n\
	uniform lowp vec4 u_nglFogColor;\n",
	
	// Body.
	@"\
	gl_FragColor = mix(u_nglFogColor, gl_FragColor, v_nglFog);\n"
};

#pragma mark -
#pragma mark Light Basic
//**************************************************
//	Light Basic
//**************************************************

NGLSLVariable UNI_SCALE = { NO, @"u_nglScale", 0, 1, NGL_VEC3, 0, NULL, NULL };
NGLSLVariable UNI_MATRIX_MI = { NO, @"u_nglMIMatrix", 0, 1, NGL_MAT4, 0, NULL, NULL };
NGLSLVariable UNI_MATRIX_MVI = { NO, @"u_nglMVIMatrix", 0, 1, NGL_MAT4, 0, NULL, NULL };
NGLSLVariable UNI_LIGHT_COLOR = { NO, @"u_nglLightColor", 0, 1, NGL_VEC4, 0, NULL, NULL };
NGLSLVariable UNI_LIGHT_POSITION = { NO, @"u_nglLightPosition", 0, 1, NGL_VEC4, 0, NULL, NULL };
NGLSLVariable UNI_LIGHT_ATTENUATION = { NO, @"u_nglLightAttenuation", 0, 1, NGL_FLOAT, 0, NULL, NULL };

NGLSLStrings VSH_LIGHT =
{
	// Header.
	@"\
	const lowp vec4 _nglOrigin = vec4(0.0,0.0,0.0,1.0);\n\
	highp vec4 _nglPosition;\n\
	uniform highp vec3 u_nglScale;\n\
	uniform highp mat4 u_nglMIMatrix;\n\
	uniform highp mat4 u_nglMVIMatrix;\n\
	uniform highp vec4 u_nglLightPosition;\n\
	uniform highp float u_nglLightAttenuation;\n\
	varying highp vec3 v_nglVEye;\n\
	varying highp vec3 v_nglVLight;\n\
	varying lowp float v_nglLightLevel;\n",
	
	// Body.
	@"\
	_nglPosition = a_nglPosition * vec4(u_nglScale, 1.0);\n\
	v_nglVEye = (u_nglMVIMatrix * _nglOrigin - _nglPosition).xyz;\n\
	v_nglVLight = (u_nglMIMatrix * u_nglLightPosition - _nglPosition).xyz;\n\
	v_nglLightLevel = clamp(u_nglLightAttenuation / length(v_nglVLight), 0.0, 1.0);\n"
};

// _nglLightD (Delta) is equivalent to the commom N . Light (NdotL)
// _nglShineD (Delta) is equivalent to the common N . Half (NdotH) or Reflect . Eye (RdotE)
NGLSLStrings FSH_LIGHT =
{
	// Header.
	@"\
	uniform lowp vec4 u_nglLightColor;\n\
	varying highp vec3 v_nglVEye;\n\
	varying highp vec3 v_nglVLight;\n\
	varying lowp float v_nglLightLevel;\n\
	lowp vec3 _nglVEye;\n\
	lowp vec3 _nglVLight;\n\
	lowp float _nglLightD;\n\
	lowp float _nglShineD;\n",
	
	// Body.
	@"\
	_nglVEye = normalize(v_nglVEye);\n\
	_nglVLight = normalize(v_nglVLight);\n"
};

#pragma mark -
#pragma mark Light Shading
//**************************************************
//	Light Shading
//**************************************************

// Blinn
// color = emission + ambient + diffuse * max(N . LV, 0) + specular * max(N . HV, 0)
// HV = normalize(EV + LV)
NGLSLStrings FSH_SHADING_BLINN =
{
	// Header.
	@"\
	void nglComputeLight(lowp vec3 normal)\n\
	{\n\
		_nglLightD = max(dot(normal, _nglVLight), 0.0);\n\
		_nglShineD = max(dot(normal, normalize(v_nglVEye + v_nglVLight)), 0.0);\n\
	}\n",
	
	// Body.
	nil
};

// Phong
// color = emission + ambient + diffuse * max(N . LV, 0) + specular * max(R . EV, 0)
// R = reflect(LV, N)	or	R = LV – 2 * dot(N, LV) * N
NGLSLStrings FSH_SHADING_PHONG =
{
	// Header.
	@"\
	void nglComputeLight(lowp vec3 normal)\n\
	{\n\
		_nglLightD = max(dot(normal, _nglVLight), 0.0);\n\
		_nglShineD = max(dot(2.0 * normal * _nglLightD - _nglVLight, _nglVEye), 0.0);\n\
	}\n",
	
	// Body.
	nil
};

//_nglShineD = max(dot(reflect(-_nglVLight, _nglNormalMap), _nglVEye), 0.0);\n\
//– (2 * dot(_nglNormalMap, -_nglVLight) * _nglNormalMap) - _nglVLight

#pragma mark -
#pragma mark Light Mapping
//**************************************************
//	Light Mapping
//**************************************************

NGLSLStrings FSH_LINEAR_MAP =
{
	// Header.
	nil,
	
	// Body.
	@"\
	nglComputeLight(_nglNormal);\n\
	_nglLightF = u_nglLightColor * v_nglLightLevel * _nglLightD;\n"
};

NGLSLVariable UNI_BUMP_MAP = { NO, @"u_nglBumpMap", 0, 1, NGL_SAMPLER_2D, 0, NULL, NULL };

NGLSLStrings FSH_BUMP_MAP =
{
	// Header.
	@"\
	uniform sampler2D u_nglBumpMap;\n",
	
	// Body.
	@"\
	nglComputeLight(normalize(texture2D(u_nglBumpMap, v_nglTexcoord).rgb * 2.0 - 1.0));\n\
	_nglLightF = u_nglLightColor * v_nglLightLevel * _nglLightD;\n"
};

#pragma mark -
#pragma mark Alpha Test
//**************************************************
//	Alpha Test
//**************************************************

NGLSLStrings FSH_ALPHA_TEST =
{
	// Header.
	@"\
	const lowp float _nglAlphaLimit = 0.05;\n",
	
	// Body.
	@"\
	if (_nglAlphaLimit > _nglAlpha * _nglDiffuse.a)\n\
	{\n\
		discard;\n\
	}\n"
};

#pragma mark -
#pragma mark Alpha
//**************************************************
//	Alpha
//**************************************************

NGLSLVariable UNI_ALPHA_COLOR = { NO, @"u_nglAlpha", 0, 1, NGL_FLOAT, 0, NULL, NULL };
NGLSLVariable UNI_ALPHA_MAP = { NO, @"u_nglAlphaMap", 0, 1, NGL_SAMPLER_2D, 0, NULL, NULL };

NGLSLStrings FSH_ALPHA =
{
	// Header.
	@"\
	uniform lowp float u_nglAlpha;\n",
	
	// Boby.
	@"\
	_nglAlpha = u_nglAlpha;\n"
};

// Alpha Map:
// • Black = 0.0 (transparent).
// • White = 1.0 (opaque).
NGLSLStrings FSH_ALPHA_MAP =
{
	// Header.
	@"\
	const lowp float _nglThird = 0.334;\n\
	uniform sampler2D u_nglAlphaMap;\n\
	lowp vec4 _nglAlphaMap;\n",
	
	// Body.
	@"\
	_nglAlphaMap = texture2D(u_nglAlphaMap, v_nglTexcoord);\n\
	_nglAlpha = (_nglAlphaMap.r + _nglAlphaMap.g + _nglAlphaMap.b) * _nglThird;\n"
};

#pragma mark -
#pragma mark Ambient
//**************************************************
//	Ambient
//**************************************************

NGLSLVariable UNI_AMBIENT_COLOR = { NO, @"u_nglAmbientColor", 0, 1, NGL_VEC4, 0, NULL, NULL };
NGLSLVariable UNI_AMBIENT_MAP = { NO, @"u_nglAmbientMap", 0, 1, NGL_SAMPLER_2D, 0, NULL, NULL };

NGLSLStrings FSH_AMBIENT_COLOR =
{
	// Header.
	@"\
	uniform lowp vec4 u_nglAmbientColor;\n",
	
	// Body.
	@"\
	_nglAmbient = u_nglAmbientColor;\n"
};

NGLSLStrings FSH_AMBIENT_MAP =
{
	// Header.
	@"\
	uniform sampler2D u_nglAmbientMap;\n",
	
	// Body.
	@"\
	_nglAmbient = texture2D(u_nglAmbientMap, v_nglTexcoord);\n"
};

#pragma mark -
#pragma mark Diffuse
//**************************************************
//	Diffuse
//**************************************************

NGLSLVariable UNI_DIFFUSE_COLOR = { NO, @"u_nglDiffuseColor", 0, 1, NGL_VEC4, 0, NULL, NULL };
NGLSLVariable UNI_DIFFUSE_MAP = { NO, @"u_nglDiffuseMap", 0, 1, NGL_SAMPLER_2D, 0, NULL, NULL };

NGLSLStrings FSH_DIFFUSE_COLOR =
{
	// Header.
	@"\
	uniform lowp vec4 u_nglDiffuseColor;\n",
	
	// Body.
	@"\
	_nglDiffuse = u_nglDiffuseColor;\n"
};

NGLSLStrings FSH_DIFFUSE_MAP =
{
	// Header.
	@"\
	uniform sampler2D u_nglDiffuseMap;\n",
	
	// Body.
	@"\
	_nglDiffuse = texture2D(u_nglDiffuseMap, v_nglTexcoord);\n"
};

#pragma mark -
#pragma mark Emissive
//**************************************************
//	Emissive
//**************************************************

NGLSLVariable UNI_EMISSIVE_COLOR = { NO, @"u_nglEmissiveColor", 0, 1, NGL_VEC4, 0, NULL, NULL };
NGLSLVariable UNI_EMISSIVE_MAP = { NO, @"u_nglEmissiveMap", 0, 1, NGL_SAMPLER_2D, 0, NULL, NULL };

NGLSLStrings FSH_EMISSIVE_COLOR =
{
	// Header.
	@"\
	uniform lowp vec4 u_nglEmissiveColor;\n",
	
	// Body.
	@"\
	_nglEmission = u_nglEmissiveColor;\n"
};

NGLSLStrings FSH_EMISSIVE_MAP =
{
	// Header.
	@"\
	uniform sampler2D u_nglEmissiveMap;\n",
	
	// Body.
	@"\
	_nglEmission = texture2D(u_nglEmissiveMap, v_nglTexcoord);\n"
};

#pragma mark -
#pragma mark Specular
//**************************************************
//	Specular
//**************************************************

NGLSLVariable UNI_SPECULAR_COLOR = { NO, @"u_nglSpecularColor", 0, 1, NGL_VEC4, 0, NULL, NULL };
NGLSLVariable UNI_SPECULAR_MAP = { NO, @"u_nglSpecularMap", 0, 1, NGL_SAMPLER_2D, 0, NULL, NULL };

NGLSLStrings FSH_SPECULAR_COLOR =
{
	// Header.
	@"\
	uniform lowp vec4 u_nglSpecularColor;\n",
	
	// Body.
	@"\
	_nglSpecular = u_nglSpecularColor * v_nglLightLevel;\n"
};

NGLSLStrings FSH_SPECULAR_MAP =
{
	// Header.
	@"\
	uniform sampler2D u_nglSpecularMap;\n",
	
	// Body.
	@"\
	_nglSpecular = texture2D(u_nglSpecularMap, v_nglTexcoord) * v_nglLightLevel;\n"
};

#pragma mark -
#pragma mark Shininess
//**************************************************
//	Shininess
//**************************************************

NGLSLVariable UNI_SHININESS = { NO, @"u_nglShininess", 0, 1, NGL_FLOAT, 0, NULL, NULL };
NGLSLVariable UNI_SHININESS_MAP = { NO, @"u_nglShininessMap", 0, 1, NGL_SAMPLER_2D, 0, NULL, NULL };

NGLSLStrings FSH_SHININESS =
{
	// Header.
	@"\
	uniform mediump float u_nglShininess;\n",
	
	// Body.
	@"\
	_nglShineF = pow(_nglShineD, u_nglShininess);\n"
};

// Shininess Map:
// • Black = 0.
// • White = 1000.0.
NGLSLStrings FSH_SHININESS_MAP =
{
	// Header.
	@"\
	const mediump float _nglThreeHundred = 333.34;\n\
	uniform sampler2D u_nglShininessMap;\n\
	lowp vec4 _nglShineMap;\n",
	
	// Body.
	@"\
	_nglShineMap = texture2D(u_nglShininessMap, v_nglTexcoord);\n\
	_nglShineF = pow(_nglShineD, (_nglShineMap.r + _nglShineMap.g + _nglShineMap.b) * _nglThreeHundred);\n"
};

#pragma mark -
#pragma mark Reflection
//**************************************************
//	Reflection
//**************************************************

NGLSLVariable UNI_REFL_MAP = { NO, @"u_nglReflMap", 0, 1, NGL_SAMPLER_2D, 0, NULL, NULL };
NGLSLVariable UNI_REFL_LEVEL = { NO, @"u_nglReflLevel", 0, 1, NGL_FLOAT, 0, NULL, NULL };

//TODO remake the reflections.
NGLSLStrings FSH_REFL_MAP =
{
	// Header.
	@"\
	uniform sampler2D u_nglReflMap;\n\
	uniform lowp float u_nglReflLevel;\n",
	
	// Body.
	@"\
	lowp vec3 _nglVEye = (u_nglMVIMatrix * vec4(0.0,0.0,0.0,1.0) - v_nglPosition).xyz;\n\
	highp vec3 _nglVRefl = mat3(u_nglMVIMatrix) * reflect(normalize(_nglVEye), _nglNormal);\n\
	_nglAmbient = mix(_nglAmbient, texture2D(u_nglReflMap, _nglVRefl.xy * 0.5 + 0.5), u_nglReflLevel);\n"
};

#pragma mark -
#pragma mark Private Interface
//**********************************************************************************************************
//
//  Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static void addShaderElement(NGLSLStrings element, NGLSLSource *shader)
{
	[shader addHeader:element.header mode:NGLSLAddModePrepend];
	[shader addBody:element.body mode:NGLSLAddModePrepend];
}

#pragma mark -
#pragma mark Public Functions
//**********************************************************************************************************
//
//  Public Functions
//
//**********************************************************************************************************

void nglConstructShaders(NGLShaders *shaders, NGLMaterial *material, NGLMesh *mesh)
{
	BOOL hasMap, hasNormal, hasTangent;
	BOOL useMap, useNormal, useTangent, useLight;
	BOOL alphaEnabled = (nglDefaultColorFormat == NGLColorFormatRGBA);
	NGLShading shading;
	
	NGLMaterialValues *values = material.values;
	NGLLightValues *light = [NGLLight defaultLight].values;
	NGLFogValues *fog = [NGLFog defaultFog].values;
	
	NGLSLVariable variable;
	NGLElement *element;
	NGLMeshElements *elements = mesh.meshElements;
	unsigned int stride = mesh.stride * NGL_SIZE_FLOAT;
	
	if (shaders == nil)
	{
		return;
	}
	
	// Setting the initial parameters.
	useMap = useNormal = useTangent = NO;
	useLight = (nglDefaultLightEffects == NGLLightEffectsON);
	
	// Defines possible effects to this shader.
	hasMap = ([elements elementWithComponent:NGLComponentTexcoord] != NULL);
	hasNormal = ([elements elementWithComponent:NGLComponentNormal] != NULL) && useLight;
	hasTangent = ([elements elementWithComponent:NGLComponentTangent] != NULL) && hasNormal;
	
	//**************************************************
	//	Global Effects
	//**************************************************
	
	//*************************
	//	Fog
	//*************************
	// Adds the fog effect.
	if ((*fog).type != NGLFogTypeNone)
	{
		variable = UNI_FOG_COLOR;
		variable.data = &(*fog).color;
		[shaders.variables addVariable:variable];
		
		variable = UNI_FOG_END;
		variable.data = &(*fog).end;
		[shaders.variables addVariable:variable];
		
		variable = UNI_FOG_FACTOR;
		variable.data = &(*fog).factor;
		[shaders.variables addVariable:variable];
		
		addShaderElement(VSH_FOG, shaders.vertex);
		addShaderElement(FSH_FOG, shaders.fragment);
	}
	
	//*************************
	//	Shader Technique
	//*************************
	
	addShaderElement(FSH_FINAL, shaders.fragment);
	
	//**************************************************
	//	Special Effects Using Lights
	//**************************************************
	
	//*************************
	//	Shininess
	//*************************
	if (material.shininessMap != nil && hasMap && hasNormal)
	{
		useMap = useNormal = YES;
		
		variable = UNI_SHININESS_MAP;
		variable.data = material.shininessMap;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_SHININESS_MAP, shaders.fragment);
	}
	else if (material.shininess > 0.0f && hasNormal)
	{
		useNormal = YES;
		
		variable = UNI_SHININESS;
		variable.data = &(*values).shininess;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_SHININESS, shaders.fragment);
	}
	
	//*************************
	//	Specular
	//*************************
	if (material.specularMap != nil && hasMap && hasNormal)
	{
		useMap = useNormal = YES;
		
		variable = UNI_SPECULAR_MAP;
		variable.data = material.specularMap;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_SPECULAR_MAP, shaders.fragment);
	}
	else if (nglColorIsNotBlack(material.specularColor) && hasNormal)
	{
		useNormal = YES;
		
		variable = UNI_SPECULAR_COLOR;
		variable.data = &(*values).specularColor;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_SPECULAR_COLOR, shaders.fragment);
	}
	
	//*************************
	//	Alpha Test
	//*************************
	if (alphaEnabled)
	{
		// Alpha test is made right after the Light Mapping.
		addShaderElement(FSH_ALPHA_TEST, shaders.fragment);
	}
	
	//*************************
	//	Bump
	//*************************
	if (material.bumpMap != nil && hasTangent)
	{
		useMap = useNormal = useTangent = YES;
		shading = NGLShadingPhong;
		
		variable = UNI_BUMP_MAP;
		variable.data = material.bumpMap;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_BUMP_MAP, shaders.fragment);
	}
	else if (hasNormal)
	{
		useNormal = YES;
		shading = NGLShadingBlinn;
		
		addShaderElement(FSH_LINEAR_MAP, shaders.fragment);
	}
	
	//*************************
	//	Reflection
	//*************************
	/*
	 if (material.reflectiveMap != nil && hasNormal)
	 {
	 useNormal = YES;
	 
	 variable = UNI_REFL_MAP;
	 variable.data = material.reflectiveMap;
	 [shaders.variables addVariable:variable];
	 
	 variable = UNI_REFL_LEVEL;
	 variable.data = &(*values).reflectiveLevel;
	 [shaders.variables addVariable:variable];
	 
	 addShaderElement(FSH_REFL_MAP, shaders.fragment);
	 }
	 */
	//*************************
	//	Refraction
	//*************************
	/*
	 // Refraction FSH if the refraction is different than normal, 1.0.
	 if (material.refraction != 1.0 && hasNormal)
	 {
	 useNormal = YES;
	 
	 variable = UNI_REFRACTION;
	 variable.data = &(*values).refraction;
	 [shaders.variables addVariable:variable];
	 
	 addShaderElement(FSH_REFRACTION, shaders.fragment);
	 }
	 //*/
	
	//**************************************************
	//	Basic Effects
	//**************************************************
	
	//*************************
	//	Alpha
	//*************************
	if (alphaEnabled)
	{
		if (material.alphaMap != nil && hasMap)
		{
			useMap = YES;
			
			variable = UNI_ALPHA_MAP;
			variable.data = material.alphaMap;
			[shaders.variables addVariable:variable];
			
			addShaderElement(FSH_ALPHA_MAP, shaders.fragment);
		}
		else
		{
			variable = UNI_ALPHA_COLOR;
			variable.data = &(*values).alpha;
			[shaders.variables addVariable:variable];
			
			addShaderElement(FSH_ALPHA, shaders.fragment);
		}
	}
	
	//*************************
	//	Ambient Illumination
	//*************************
	if (material.ambientMap != nil && hasMap)
	{
		useMap = YES;
		
		variable = UNI_AMBIENT_MAP;
		variable.data = material.ambientMap;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_AMBIENT_MAP, shaders.fragment);
	}
	else
	{
		variable = UNI_AMBIENT_COLOR;
		variable.data = &(*values).ambientColor;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_AMBIENT_COLOR, shaders.fragment);
	}
	
	//*************************
	//	Diffuse
	//*************************
	if (material.diffuseMap != nil && hasMap)
	{
		useMap = YES;
		
		variable = UNI_DIFFUSE_MAP;
		variable.data = material.diffuseMap;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_DIFFUSE_MAP, shaders.fragment);
	}
	else
	{
		variable = UNI_DIFFUSE_COLOR;
		variable.data = &(*values).diffuseColor;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_DIFFUSE_COLOR, shaders.fragment);
	}
	
	//*************************
	//	Emissive Illumination
	//*************************
	if (material.emissiveMap != nil && hasMap)
	{
		useMap = YES;
		
		variable = UNI_EMISSIVE_MAP;
		variable.data = material.emissiveMap;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_EMISSIVE_MAP, shaders.fragment);
	}
	else
	{
		variable = UNI_EMISSIVE_COLOR;
		variable.data = &(*values).emissiveColor;
		[shaders.variables addVariable:variable];
		
		addShaderElement(FSH_EMISSIVE_COLOR, shaders.fragment);
	}
	
	//**************************************************
	//	Shaders Structures
	//**************************************************
	
	//*************************
	//	Tangent Space
	//*************************
	if (useTangent)
	{
		element = [elements elementWithComponent:NGLComponentTangent];
		
		variable = ATT_TANGENT;
		variable.stride = stride;
		variable.count = (*element).length;
		variable.data = (void *)(unsigned long)((*element).start * NGL_SIZE_FLOAT);
		[shaders.variables addVariable:variable];
		
		element = [elements elementWithComponent:NGLComponentBitangent];
		
		variable = ATT_BITANGENT;
		variable.stride = stride;
		variable.count = (*element).length;
		variable.data = (void *)(unsigned long)((*element).start * NGL_SIZE_FLOAT);
		[shaders.variables addVariable:variable];
		
		addShaderElement(VSH_TANGENT, shaders.vertex);
		addShaderElement(FSH_TANGENT, shaders.fragment);
	}
	
	//*************************
	//	Light
	//*************************
	if (useNormal)
	{
		switch (shading)
		{
			case NGLShadingBlinn:
				addShaderElement(FSH_SHADING_BLINN, shaders.fragment);
				break;
			case NGLShadingPhong:
				addShaderElement(FSH_SHADING_PHONG, shaders.fragment);
				break;
		}
		
		variable = UNI_SCALE;
		variable.data = mesh.scale;
		[shaders.variables addVariable:variable];
		
		variable = UNI_MATRIX_MI;
		variable.data = mesh.matrixMInverse;
		[shaders.variables addVariable:variable];
		
		variable = UNI_MATRIX_MVI;
		variable.data = mesh.matrixMVInverse;
		[shaders.variables addVariable:variable];
		
		variable = UNI_LIGHT_POSITION;
		variable.data = &(*light).position;
		[shaders.variables addVariable:variable];
		
		variable = UNI_LIGHT_COLOR;
		variable.data = &(*light).color;
		[shaders.variables addVariable:variable];
		
		variable = UNI_LIGHT_ATTENUATION;
		variable.data = &(*light).attenuation;
		[shaders.variables addVariable:variable];
		
		addShaderElement(VSH_LIGHT, shaders.vertex);
		addShaderElement(FSH_LIGHT, shaders.fragment);
	}
	
	//*************************
	//	Normals
	//*************************
	
	// Checks if this shader makes use of normals, if the material already does not.
	useNormal = useNormal || [shaders.vertex hasPattern:@"_nglNormal"];
	useNormal = useNormal || [shaders.fragment hasPattern:@"_nglNormal"];
	
	if (useNormal)
	{
		element = [elements elementWithComponent:NGLComponentNormal];
		
		variable = ATT_NORMAL;
		variable.stride = stride;
		variable.count = (*element).length;
		variable.data = (void *)(unsigned long)((*element).start * NGL_SIZE_FLOAT);
		[shaders.variables addVariable:variable];
		
		addShaderElement(VSH_NORMAL, shaders.vertex);
		addShaderElement(FSH_NORMAL, shaders.fragment);
	}
	
	//*************************
	//	Maps
	//*************************
	
	// Checks if this shader makes use of texcoords, if the material already does not.
	useMap = (useMap || [shaders.vertex hasPattern:@"_nglTexcoord"]);
	useMap = (useMap || [shaders.fragment hasPattern:@"_nglTexcoord"]);
	
	if (useMap)
	{
		element = [elements elementWithComponent:NGLComponentTexcoord];
		
		variable = ATT_MAP;
		variable.stride = stride;
		variable.count = (*element).length;
		variable.data = (void *)(unsigned long)((*element).start * NGL_SIZE_FLOAT);
		[shaders.variables addVariable:variable];
		
		addShaderElement(VSH_MAP, shaders.vertex);
		addShaderElement(FSH_MAP, shaders.fragment);
	}
	
	//*************************
	//	Base
	//*************************
	
	element = [elements elementWithComponent:NGLComponentVertex];
	
	// The base uniform and attributes from the base shaders.
	variable = UNI_MATRIX_MVP;
	variable.data = mesh.matrixMVP;
	[shaders.variables addVariable:variable];
	
	variable = ATT_VERTEX;
	variable.stride = stride;
	variable.count = (*element).length;
	variable.data = (void *)(unsigned long)((*element).start * NGL_SIZE_FLOAT);
	[shaders.variables addVariable:variable];
	
	// The base FSH and VSH will always exist.
	addShaderElement(VSH_BASE, shaders.vertex);
	addShaderElement(FSH_BASE, shaders.fragment);
}

void nglPrepareTelemetryShaders(NGLShaders *shaders, void *data)
{
	NGLSLVariable variable = UNI_TELEMETRY;
	variable.data = data;
	[shaders.variables addVariable:variable];
}

void nglConstructTelemetryShaders(NGLShaders *shaders)
{
	[shaders.variables addVariable:ATT_VERTEX];
	[shaders.variables addVariable:UNI_MATRIX_MVP];
	[shaders.variables addVariable:UNI_TELEMETRY];
	
	// The telemetry technique only calculates the final position.
	// The color is used as a kind of ID.
	addShaderElement(VSH_BASE, shaders.vertex);
	addShaderElement(FSH_TELEMETRY, shaders.fragment);
}