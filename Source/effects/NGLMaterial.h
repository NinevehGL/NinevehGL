/*
 *	NGLMaterial.h
 *	
 *	The NinevehGL Engine is a free 3D engine to work with OpenGL programmable pipeline, made with pure
 *	Objective-C for iOS (iPhone, iPad and iPod Touch). NinevehGL is prepared to import 3D file with the
 *	formats:
 *		- WaveFront OBJ file (.obj);
 *		- COLLADA file (.dae).
 *
 *	More information at the official web site: http://nineveh.gl
 *
 *	Created by Diney Bomfim on 1/6/11.
 *	Copyright (c) 2011 DB-Interactively. All rights reserved.
 */

#import "NGLRuntime.h"
#import "NGLDataType.h"
#import "NGLVector.h"
#import "NGLCopying.h"
#import "NGLTexture.h"

@class NSString, NGLTexture;

/*!
 *					Defines the NGLMaterial protocol.
 *
 *					This protocol defines the NGLMaterial kind, it can be produce many NGLMaterial
 *					types, like:
 *
 *						- Standard;
 *						- Multi/Sub.
 */
@protocol NGLMaterial <NSObject, NGLCopying>

@end

/*!
 *					<strong>(Internal only)</strong> An object that holds the material scalar values.
 *
 *					This structure is used as a fixed pointer to preserve the necessary information (memory)
 *					to the material's scalar values.
 *
 *	@see			NGLvec4
 *	
 *	@var			NGLMaterialValues::alpha
 *					Represents the alpha value.
 *	
 *	@var			NGLMaterialValues::ambientColor
 *					Represents the ambient color.
 *	
 *	@var			NGLMaterialValues::diffuseColor
 *					Represents the diffuse color.
 *	
 *	@var			NGLMaterialValues::emissiveColor
 *					Represents the emissive color.
 *	
 *	@var			NGLMaterialValues::specularColor
 *					Represents the specular color.
 *	
 *	@var			NGLMaterialValues::shininess
 *					Represents the shininess.
 *	
 *	@var			NGLMaterialValues::reflectiveLevel
 *					Represents the reflective level.
 *	
 *	@var			NGLMaterialValues::refraction
 *					Represents the refraction.
 */
typedef struct
{
	float			alpha;
	NGLvec4			ambientColor;
	NGLvec4			diffuseColor;
	NGLvec4			emissiveColor;
	NGLvec4			specularColor;
	float			shininess;
	float			reflectiveLevel;
	float			refraction;
} NGLMaterialValues;

/*!
 *					The basic material definition to NinevehGL.
 *
 *					The NGLMaterial is an user friendly API to deal with OpenGL's fragment shaders.
 *					Each material's property represents a specific predefined behavior in the fragment
 *					shaders. Obviously you can define and construct custom shaders. The materials
 *					is just a simple way to deal with the most used and populars behaviors in the
 *					fragment shaders.
 *
 *					The actual version of NGLMaterial can deal with:
 *
 *						- Alpha and transparency;
 *						- Ambient color and texture;
 *						- Diffuse color and texture;
 *						- Emissive color and texture;
 *						- Shininess;
 *						- Specular component;
 *						- Bump effect;
 *						- Reflection map.
 *
 *					Even using the materials (that is the default immutable NinevehGL's behavior) you
 *					can create your shaders. The both shaders will be merged to form a new shader with
 *					unique behavior.
 *
 *	@see			NGLShaders
 */
@interface NGLMaterial : NSObject <NGLMaterial>
{
@private
	NSString				*_name;
	unsigned int			_identifier;
	
	NGLMaterialValues		_values;
	NGLTexture				*_alphaMap;
	NGLTexture				*_ambientMap;
	NGLTexture				*_diffuseMap;
	NGLTexture				*_emissiveMap;
	NGLTexture				*_specularMap;
	NGLTexture				*_shininessMap;
	NGLTexture				*_bumpMap;
	NGLTexture				*_reflectiveMap;
}

/*!
 *					The item's name. This can also be used by identify this object.
 */
@property (nonatomic, copy) NSString *name;

/*!
 *					The identifier of this object.
 */
@property (nonatomic) unsigned int identifier;

/*!
 *					The alpha component in a range of (0.0, 1.0). The 0.0 means a fully transparent
 *					material and 1.0 indicates a fully opaque material.
 */
@property (nonatomic) float alpha;

/*!
 *					The material's ambient color reflection. This property is taken by the shaders as
 *					reflection an <em>ambient multi directional white light placed at the infinity</em>,
 *					that means it will cover all the surface with the same color and intensity.
 *
 *					The color is given by NGLvec4 data type with a range of (0.0, 1.0).
 *					You can use the <code>nglColorMake()</code> static function to make sure the values
 *					will be clamped to that range.
 */
@property (nonatomic) NGLvec4 ambientColor;

/*!
 *					The material's diffuse color reflection. This property suffers influence from the
 *					scene lights.
 *
 *					The color is given by NGLvec4 data type with a range of (0.0, 1.0).
 *					You can use the <code>nglColorMake()</code> static function to make sure the values
 *					will be clamped to that range.
 */
@property (nonatomic) NGLvec4 diffuseColor;

/*!
 *					The material's emissive color amount. This property simulates an emission of light from
 *					this material by adding an uniform glow effect on it.
 *
 *					The color is given by NGLvec4 data type with a range of (0.0, 1.0).
 *					You can use the <code>nglColorMake()</code> static function to make sure the values
 *					will be clamped to that range.
 */
@property (nonatomic) NGLvec4 emissiveColor;

/*!
 *					The material's specular color reflection. This property simulates the specular color
 *					and intensity from lights on this material.
 *
 *					The color is given by NGLvec4 data type with a range of (0.0, 1.0).
 *					You can use the <code>nglColorMake()</code> static function to make sure the values
 *					will be clamped to that range.
 */
@property (nonatomic) NGLvec4 specularColor;

/*!
 *					The shininess specifies the specular exponent, also known as glossiness.
 *					This defines the focus of the specular highlight. The value lies in a range of
 *					(0.0, 1000.0), the high exponent results in a tight reflective light, a concentrated
 *					highlight, low exponent results in large and spread reflection.
 */
@property (nonatomic) float shininess;

/*!
 *					The reflective level attenuates the reflective map.
 *					The value lies in a range of (0.0, 1.0), where 0 means no reflection and 1 means full
 *					reflection. The default value is 0.5.
 *
 *	@see			reflectiveMap
 */
@property (nonatomic) float reflectiveLevel;

/*!
 *					The refraction property indicates the index of refraction to this object.
 *	
 *					The value lies in the range of (0.001, 10.0). The default is 1 and means that light
 *					doesn't bend when pass through the object. A glass should have a value of 1.5.
 *					Values under 1 generate non real behaviors.
 */
@property (nonatomic) float refraction;

/*!
 *					The alpha defined by a texture map. To achieve more precision, the map should be
 *					constructed with grey scale only, where a full white represents the fully opaque areas
 *					and full black represents the fully transparent areas.
 *
 *					The texture coordinates (UV Map) of the mesh will be used to place the map on the mesh.
 */
@property (nonatomic, retain) NGLTexture *alphaMap;

/*!
 *					Defines the material's ambient color reflection by a texture map.
 *
 *					The texture coordinates (UV Map) of the mesh will be used to place the map on the mesh.
 */
@property (nonatomic, retain) NGLTexture *ambientMap;

/*!
 *					Defines the material's diffuse color reflection by a texture map.
 *
 *					The texture coordinates (UV Map) of the mesh will be used to place the map on the mesh.
 */
@property (nonatomic, retain) NGLTexture *diffuseMap;

/*!
 *					Defines the material's emissive color amount by a texture map.
 *
 *					The texture coordinates (UV Map) of the mesh will be used to place the map on the mesh.
 */
@property (nonatomic, retain) NGLTexture *emissiveMap;

/*!
 *					Defines the material's specular color reflection by a texture map.
 *
 *					The texture coordinates (UV Map) of the mesh will be used to place the map on the mesh.
 */
@property (nonatomic, retain) NGLTexture *specularMap;

/*!
 *					Defines the shininess by a texture map. To achieve more precision, the map should be
 *					constructed with grey scale only, where the full white represents the value of 1000 and
 *					full black represents the 0.
 *
 *					The texture coordinates (UV Map) of the mesh will be used to place the map on the mesh.
 */
@property (nonatomic, retain) NGLTexture *shininessMap;

/*!
 *					Defines the bump effect by a texture map. By default the bump map should be constructed
 *					with a normal map with the tangent space colors.
 *
 *					For more information about this kind of texture map, check out:
 *
 *						- <a href="http://bit.ly/mfyQM6" target="_blank">Photoshop Plugin by NVIDIA;</a>
 *						- <a href="http://bit.ly/lbQYEr" target="_blank">PixPlant App;</a>
 *						- <a href="http://bit.ly/kf2b6a" target="_blank">Photoshop
 *							tutorial to create normal maps with no plugins;</a>
 *						- <a href="http://bit.ly/lJ2Dt7" target="_blank">Tutorial about normal map
 *							concept.</a>
 *
 *					The texture coordinates (UV Map) of the mesh will be used to place the map on the mesh.
 */
@property (nonatomic, retain) NGLTexture *bumpMap;

/*!
 *					Defines the reflection of the material by a texture map. All the reflection maps will
 *					be treated as an enviroment spherical map.
 */
@property (nonatomic, retain) NGLTexture *reflectiveMap;

/*!
 *					<strong>(Internal only)</strong> Returns a pointer to the material scalar values.
 *					You should not call this method directly.
 */
@property (nonatomic, readonly) NGLMaterialValues *values;

/*!
 *					Returns an autorelease instance of NGLMaterial.
 *
 *					This material represents the default grey material, which will be automatically assigned
 *					to a mesh with no materials on it. This material is the same used by many 3D softwares
 *					like Maya, 3DS Max, LightWave, Modo and others. It's also known as clay material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) material;

/*!
 *					Returns the brass material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialBrass;

/*!
 *					Returns the bronze material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialBronze;

/*!
 *					Returns the cooper material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialCooper;

/*!
 *					Returns the gold material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialGold;

/*!
 *					Returns the silver material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialSilver;

/*!
 *					Returns the chrome material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialChrome;

/*!
 *					Returns the pewter material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialPewter;

/*!
 *					Returns the emerald material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialEmerald;

/*!
 *					Returns the jade material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialJade;

/*!
 *					Returns the obsidian material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialObsidian;

/*!
 *					Returns the ruby material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialRuby;

/*!
 *					Returns the turqoise material.
 *
 *	@result			A NGLMaterial autoreleased instance.
 */
+ (id) materialTurqoise;

@end
