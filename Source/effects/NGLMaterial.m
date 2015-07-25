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

#import "NGLMaterial.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************


#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************


#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NGLMaterial

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize name = _name, identifier = _identifier, alphaMap = _alphaMap, ambientMap = _ambientMap,
			diffuseMap = _diffuseMap, emissiveMap = _emissiveMap, specularMap = _specularMap,
			shininessMap = _shininessMap, bumpMap = _bumpMap, reflectiveMap = _reflectiveMap;

@dynamic alpha, ambientColor, diffuseColor, emissiveColor, specularColor,
		 shininess, reflectiveLevel, refraction, values;

- (float) alpha { return _values.alpha; }
- (void) setAlpha:(float)alpha
{
	alpha = nglClamp(alpha, 0.0f, 1.0f);
	_values.alpha = alpha;
}

- (NGLvec4) ambientColor { return _values.ambientColor; }
- (void) setAmbientColor:(NGLvec4)color
{
	_values.ambientColor = color;
}

- (NGLvec4) diffuseColor { return _values.diffuseColor; }
- (void) setDiffuseColor:(NGLvec4)color
{
	_values.diffuseColor = color;
}

- (NGLvec4) emissiveColor { return _values.emissiveColor; }
- (void) setEmissiveColor:(NGLvec4)color
{
	_values.emissiveColor = color;
}

- (NGLvec4) specularColor { return _values.specularColor; }
- (void) setSpecularColor:(NGLvec4)color
{
	_values.specularColor = color;
}

- (float) shininess { return _values.shininess; }
- (void) setShininess:(float)value
{
	value = nglClamp(value, 0.0f, 1000.0f);
	_values.shininess = value;
}

- (float) reflectiveLevel { return _values.reflectiveLevel; }
- (void) setReflectiveLevel:(float)value
{
	value = nglClamp(value, 0.0f, 1.0f);
	_values.reflectiveLevel = value;
}

- (float) refraction { return _values.refraction; }
- (void) setRefraction:(float)value
{
	value = nglClamp(value, 0.001f, 10.0f);
	_values.refraction = value;
}

- (NGLMaterialValues *) values { return &_values; }

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		self.name = nil;
		self.identifier = 0;
		self.alpha = 1.0f;
		self.ambientColor = nglColorMake(0.0f, 0.0f, 0.0f, 1.0f);
		self.diffuseColor = nglColorMake(0.5f, 0.5f, 0.5f, 1.0f);
		self.specularColor = nglColorMake(0.5f, 0.5f, 0.5f, 1.0f);
		self.emissiveColor = nglColorMake(0.0f, 0.0f, 0.0f, 1.0f);
		self.shininess = 32.0f;
		self.reflectiveLevel = 0.5f;
		self.refraction = 1.0f;
	}
	
	return self;
}

+ (id) material
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	return [material autorelease];
}

+ (id) materialBrass
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.32f, 0.22f, 0.02f, 1.0f);
	material.diffuseColor = nglColorMake(0.78f, 0.56f, 0.11f, 1.0f);
	material.specularColor = nglColorMake(0.99f, 0.94f, 0.80f, 1.0f);
	material.shininess = 27.0f;
	
	return [material autorelease];
}

+ (id) materialBronze
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.21f, 0.12f, 0.05f, 1.0f);
	material.diffuseColor = nglColorMake(0.71f, 0.42f, 0.18f, 1.0f);
	material.specularColor = nglColorMake(0.39f, 0.27f, 0.16f, 1.0f);
	material.shininess = 25.6f;
	
	return [material autorelease];
}

+ (id) materialCooper
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.22f, 0.08f, 0.02f, 1.0f);
	material.diffuseColor = nglColorMake(0.75f, 0.60f, 0.22f, 1.0f);
	material.specularColor = nglColorMake(0.62f, 0.55f, 0.36f, 1.0f);
	material.shininess = 76.8f;
	
	return [material autorelease];
}

+ (id) materialGold
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.24f, 0.19f, 0.07f, 1.0f);
	material.diffuseColor = nglColorMake(0.75f, 0.60f, 0.22f, 1.0f);
	material.specularColor = nglColorMake(0.62f, 0.55f, 0.36f, 1.0f);
	material.shininess = 51.2f;
	
	return [material autorelease];
}

+ (id) materialSilver
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.20f, 0.20f, 0.20f, 1.0f);
	material.diffuseColor = nglColorMake(0.50f, 0.50f, 0.50f, 1.0f);
	material.specularColor = nglColorMake(0.50f, 0.50f, 0.50f, 1.0f);
	material.shininess = 51.2f;
	
	return [material autorelease];
}

+ (id) materialChrome
{
	// Materials by default is grey.
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.25f, 0.25f, 0.25f, 1.0f);
	material.diffuseColor = nglColorMake(0.40f, 0.40f, 0.40f, 1.0f);
	material.specularColor = nglColorMake(0.77f, 0.77f, 0.77f, 1.0f);
	material.shininess = 76.8f;
	
	return [material autorelease];
}

+ (id) materialPewter
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.10f, 0.05f, 0.11f, 1.0f);
	material.diffuseColor = nglColorMake(0.42f, 0.47f, 0.54f, 1.0f);
	material.specularColor = nglColorMake(0.33f, 0.33f, 0.52f, 1.0f);
	material.shininess = 9.8f;
	
	return [material autorelease];
}

+ (id) materialEmerald
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.02f, 0.17f, 0.02f, 0.55f);
	material.diffuseColor = nglColorMake(0.07f, 0.61f, 0.07f, 0.55f);
	material.specularColor = nglColorMake(0.63f, 0.72f, 0.63f, 0.55f);
	material.shininess = 76.8f;
	
	return [material autorelease];
}

+ (id) materialJade
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.13f, 0.22f, 0.15f, 0.95f);
	material.diffuseColor = nglColorMake(0.54f, 0.89f, 0.63f, 0.95f);
	material.specularColor = nglColorMake(0.31f, 0.31f, 0.31f, 0.95f);
	material.shininess = 12.8f;
	
	return [material autorelease];
}

+ (id) materialObsidian
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.05f, 0.05f, 0.06f, 0.82f);
	material.diffuseColor = nglColorMake(0.18f, 0.17f, 0.22f, 0.82f);
	material.specularColor = nglColorMake(0.33f, 0.32f, 0.34f, 0.82f);
	material.shininess = 38.4f;
	
	return [material autorelease];
}

+ (id) materialRuby
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.17f, 0.01f, 0.01f, 0.55f);
	material.diffuseColor = nglColorMake(0.61f, 0.04f, 0.04f, 0.55f);
	material.specularColor = nglColorMake(0.72f, 0.62f, 0.62f, 0.55f);
	material.shininess = 76.8f;
	
	return [material autorelease];
}

+ (id) materialTurqoise
{
	NGLMaterial *material = [[NGLMaterial alloc] init];
	
	material.ambientColor = nglColorMake(0.10f, 0.18f, 0.17f, 0.82f);
	material.diffuseColor = nglColorMake(0.39f, 0.74f, 0.69f, 0.82f);
	material.specularColor = nglColorMake(0.29f, 0.30f, 0.30f, 0.82f);
	material.shininess = 12.8f;
	
	return [material autorelease];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (id) copyInstance
{
	id copy = [[[self class] allocWithZone:nil] init];
	
	// Copying properties.
	[self defineCopyTo:copy shared:YES];
	
	return copy;
}

- (id) copyWithZone:(NSZone *)zone
{
	id copy = [[[self class] allocWithZone:zone] init];
	
	// Copying properties.
	[self defineCopyTo:copy shared:NO];
	
	return copy;
}

- (void) defineCopyTo:(id)aCopy shared:(BOOL)isShared
{
	NGLMaterial *copy = aCopy;
	
	// Copying properties.
	copy.name = _name;
	copy.identifier = _identifier;
	copy.alpha = _values.alpha;
	copy.ambientColor = _values.ambientColor;
	copy.diffuseColor = _values.diffuseColor;
	copy.emissiveColor = _values.emissiveColor;
	copy.shininess = _values.shininess;
	copy.reflectiveLevel = _values.reflectiveLevel;
	copy.refraction = _values.refraction;
	
	if (isShared)
	{
		copy.alphaMap = _alphaMap;
		copy.ambientMap = _ambientMap;
		copy.diffuseMap = _diffuseMap;
		copy.emissiveMap = _emissiveMap;
		copy.specularMap = _specularMap;
		copy.shininessMap = _shininessMap;
		copy.bumpMap = _bumpMap;
		copy.reflectiveMap = _reflectiveMap;
	}
	else
	{
		NGLTexture *tAlpha = [_alphaMap copy];
		NGLTexture *tAmbient = [_ambientMap copy];
		NGLTexture *tDiffuse = [_diffuseMap copy];
		NGLTexture *tEmissive = [_emissiveMap copy];
		NGLTexture *tSpecular = [_specularMap copy];
		NGLTexture *tShininess = [_shininessMap copy];
		NGLTexture *tBump = [_bumpMap copy];
		NGLTexture *tReflective = [_reflectiveMap copy];
		
		copy.alphaMap = tAlpha;
		copy.ambientMap = tAmbient;
		copy.diffuseMap = tDiffuse;
		copy.emissiveMap = tEmissive;
		copy.specularMap = tSpecular;
		copy.shininessMap = tShininess;
		copy.bumpMap = tBump;
		copy.reflectiveMap = tReflective;
		
		nglRelease(tAlpha);
		nglRelease(tAmbient);
		nglRelease(tDiffuse);
		nglRelease(tEmissive);
		nglRelease(tSpecular);
		nglRelease(tShininess);
		nglRelease(tBump);
		nglRelease(tReflective);
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (NSString *) description
{
	NSString *string = [NSString stringWithFormat:@"\n%@\n\
						Name: %@\n\
						ID: %i\n\
						Alpha: %f\n\
						Ambient: %f %f %f %f\n\
						Diffuse: %f %f %f %f\n\
						Emissive: %f %f %f %f\n\
						Specular: %f %f %f %f\n\
						Shininess: %f\n\
						ReflectiveLevel: %f\n\
						Refraction: %f\n\
						AlphaMap: %@\n\
						AambientMap: %@\n\
						DiffuseMap: %@\n\
						EmissiveMap: %@\n\
						SpecularMap: %@\n\
						ShininessMap: %@\n\
						BumpMap: %@\n\
						reflectiveMap: %@\n",
						[super description],
						_name,
						_identifier,
						_values.alpha,
						self.ambientColor.x,self.ambientColor.y,self.ambientColor.z,self.ambientColor.w,
						self.diffuseColor.x,self.diffuseColor.y,self.diffuseColor.z,self.diffuseColor.w,
						self.emissiveColor.x,self.emissiveColor.y,self.emissiveColor.z,self.emissiveColor.w,
						self.specularColor.x,self.specularColor.y,self.specularColor.z,self.specularColor.w,
						_values.shininess,
						_values.reflectiveLevel,
						_values.refraction,
						_alphaMap,
						_ambientMap,
						_diffuseMap,
						_emissiveMap,
						_specularMap,
						_shininessMap,
						_bumpMap,
						_reflectiveMap];
	
	return string;
}

- (void) dealloc
{
	nglRelease(_name);
	nglRelease(_alphaMap);
	nglRelease(_ambientMap);
	nglRelease(_diffuseMap);
	nglRelease(_emissiveMap);
	nglRelease(_specularMap);
	nglRelease(_shininessMap);
	nglRelease(_bumpMap);
	nglRelease(_reflectiveMap);
	
	[super dealloc];
}

@end