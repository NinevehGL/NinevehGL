/*
 *	NGLGlobal.h
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

#import "NGLRuntime.h"
#import "NGLDataType.h"

#pragma mark -
#pragma mark Global Definitions
#pragma mark -
//**********************************************************************************************************
//
//	Global Definitions
//
//**********************************************************************************************************

/*!
 *					The OpenGL version.
 *
 *					The engine affects the whole application.
 *
 *	@see			nglGlobalEngine
 *	
 *	@var			NGLEngineVersionES2
 *					Represents the OpenGL ES 2.0. This is the default.
 */
typedef enum
{
	// To ensure the NGL integrity, the default engine is set to 0.
	NGLEngineVersionES2		= 0x00,	// Default
} NGLEngineVersion;

/*!
 *					Identifies the color format.
 *
 *					The color format affects any class that works with colors, images or drawings.
 *
 *	@see			nglGlobalColorFormat
 *	
 *	@var			NGLColorFormatRGB
 *					Represents only the true color channels, without the alpha. This is the default value.
 *
 *	@var			NGLColorFormatRGBA
 *					Represents all the channels, including the alpha.
 */
typedef enum
{
	// To ensure the NGL integrity, the default color format is the set to 0.
	NGLColorFormatRGB		= 0x00,	// Default
	NGLColorFormatRGBA		= 0x01,
} NGLColorFormat;

/*!
 *					Identifies which vertex order construcs a front face.
 *
 *					OpenGL defines the front and back face based on the constructing vertex order on each
 *					face.
 *
 *	@see			nglGlobalFrontAndCullFace
 *	
 *	@var			NGLFrontFaceCCW
 *					Represents that the Counter Clock Wise order will define the front face.
 *					This is the default value.
 *
 *	@var			NGLFrontFaceCW
 *					Represents that the Clock Wise order will define the front face.
 */
typedef enum
{
	NGLFrontFaceCCW			= 0x00, // Default
	NGLFrontFaceCW			= 0x01,
} NGLFrontFace;

/*!
 *					Identifies which face could be culled.
 *
 *					Culling is an OpenGL feature to optmize the render and to avoid rendering something
 *					you don't want to use. OpenGL could cull the back face, front face or even doesn't
 *					make any cull.
 *	
 *	@var			NGLCullFaceBack
 *					Represents that the back face will be culled. This is the default value.
 *
 *	@var			NGLCullFaceFront
 *					Represents that the front face will be culled.
 *
 *	@var			NGLCullFaceNone
 *					Represents that no face will be culled.
 */
typedef enum
{
	NGLCullFaceBack			= 0x00, // Default
	NGLCullFaceFront		= 0x01,
	NGLCullFaceNone			= 0x02,
} NGLCullFace;

/*!
 *					Identifies the global antialias filter.
 *
 *					The antialias (also known as Multisample) produces smooth images on NinevehGL render.
 *					
 *	@see			nglGlobalAntialias
 *
 *	@var			NGLColorFormatRGB
 *					Represents only the true color channels, without the alpha. This is the default value.
 *
 *	@var			NGLColorFormatRGBA
 *					Represents all the channels, including the alpha.
 */
typedef enum
{
	NGLAntialiasNone		= 0x01,
	NGLAntialias4X			= 0x04,
} NGLAntialias;

/*!
 *					Defines the quality for a texture map.
 *
 *					The quality may produce aliased or smooth images. Each quality has a performance cost.
 *
 *	@see			NGLTexture::quality
 *	@see			nglGlobalTextureQuality
 *	
 *	@var			NGLTextureQualityNearest
 *					Represents the nearest filter. This is the fastest filter, but the images may seem
 *					to be a bit aliased.
 *	
 *	@var			NGLTextureQualityBilinear
 *					Represents a filter with bilinear interpolation. The images may seem to be smoother,
 *					but when using mipmap level the image may still aliased.
 *
 *	@var			NGLTextureQualityTrilinear
 *					Represents a filter with trilinear interpolation. The images will always seem to be
 *					smoother, even when using low mipmap levels.
 */
typedef enum
{
	NGLTextureQualityNearest		= 0x01,
	NGLTextureQualityBilinear		= 0x02,
	NGLTextureQualityTrilinear		= 0x03,
} NGLTextureQuality;

/*!
 *					Defines the map repeat coordinates in the S and T coordinates direction.
 *
 *					This configuration will be used for both directions.
 *
 *	@see			NGLTexture::repeat
 *	@see			nglGlobalTextureRepeat
 *	
 *	@var			NGLTextureRepeatNormal
 *					Represents that the image will repeate in S and T directions.
 *	
 *	@var			NGLTextureRepeatMirrored
 *					Represents that the image will repeate in S and T directions, but it will be mirrored,
 *					at each new repetition. This artifact makes the map to look more homogeneous at
 *					the edges of the repetition.
 *
 *	@var			NGLTextureRepeatNone
 *					Represents no repetition. The last pixel line will be stretched to clamp the edges,
 *					if necessary.
 */
typedef enum
{
	NGLTextureRepeatNormal			= 0x01,
	NGLTextureRepeatMirrored		= 0x02,
	NGLTextureRepeatNone			= 0x03,
} NGLTextureRepeat;

/*!
 *					Defines the circumstance(s) in which the pixel data could be optimized.
 *
 *					OpenGL accepts optimized format, which has 2bpp (bytes per pixel). The optimized
 *					formats are:
 *
 *						- <strong>RGB565</strong> - Has 5 bits for red channel, 6 for green and 5 for blue;
 *						- <strong>RGBA4444</strong> - Has 4 bits for each channel, including alpha channel.
 *
 *					NinevehGL will choose the proper format depending on the global color format
 *					automatically. This configuration instructs in which situation the texture could be
 *					optimized.
 *
 *					It's important to remember that the optimization happens by reducing the color range.
 *					So make tests to see if the texture colors are acceptable.
 *
 *	@see			NGLTexture::optimize
 *	@see			nglGlobalTextureOptimize
 *	
 *	@var			NGLTextureOptimizeAlways
 *					The pixel data will always be optimized.
 *	
 *	@var			NGLTextureOptimizeRGBA
 *					The pixel data will be optimized only for RGBA color format.
 *
 *	@var			NGLTextureOptimizeRGB
 *					The pixel data will be optimized only for RGB color format.
 *
 *	@var			NGLTextureOptimizeNone
 *					The pixel data will never be optimized.
 */
typedef enum
{
	NGLTextureOptimizeAlways		= 0x01,
	NGLTextureOptimizeRGBA			= 0x02,
	NGLTextureOptimizeRGB			= 0x03,
	NGLTextureOptimizeNone			= 0x04,
} NGLTextureOptimize;

/*!
 *					Defines the mode in which the rotations on an object are going to happen:
 *					Local or World (also known as Global).
 *
 *					Some 3D softwares like Maya, 3D Max, Modo and others, provides many kind of rotation's
 *					mode (user friendly rotations) to help the user in the modeling and animating.
 *					But in matrices, there are only exist two types of rotations: Local and World.
 *					All others derive from both.
 *
 *					With simple words, as matrix multiplication is not commutative, in-depth, the
 *					diference between both rotation's mode is just the order of the product matrices
 *					in multiplication:
 *
 *						- Local rotation = Multiply the new matrix by the old one
 *							(also known as Pre-multiply);
 *						- World rotation = Multiply the old matrix by the new one
 *							(also known as Post-multiply).
 *
 *					Make sure you understand that there is a great difference between the concept of
 *					World VS Local and Absolute VS Relative. Both concepts are used in NinevehGL rotations,
 *					but they are completely different and achieve different results.
 *
 *					The default global value is NGL_NULL.
 *
 *	@see			NGLObject3D::rotationSpace
 *	@see 			NGLObject3D::rotateX
 *	@see 			NGLObject3D::rotateY
 *	@see 			NGLObject3D::rotateZ
 *	@see 			NGLObject3D::rotateToX:toY:toZ:
 *	@see			NGLObject3D::rotateRelativeToX:toY:toZ:
 *	@see			nglGlobalRotationSpace
 *	
 *	@var			NGLRotationSpaceLocal
 *					Indicates every new rotation will be made in Local mode.
 *
 *	@var			NGLRotationSpaceLocal
 *					Indicates every new rotation will be made in World mode.
 */
typedef enum
{
    NGLRotationSpaceLocal	= 0x01,
	NGLRotationSpaceWorld	= 0x02,
} NGLRotationSpace;

/*!
 *					Defines the order in which the rotations will happen.
 *
 *					As all rotations in NinevehGL are made using #NGLQuaternion# class, you don't need
 *					to worry about Gimbal Lock and some unexpected rotations. The only thing you need
 *					to worry is about the order of the rotation. To boost the performance, all rotations
 *					in one object are done togheter at the render time, so you need to instruct in which
 *					order the rotations will happen.
 *
 *					To all generic objects, the default rotation order is the same as Euler Rotation
 *					YZX.
 *
 *					Actually, these constants are hexadecimal values (binary), where each pair represents
 *					one coordinate:
 *
 *						- 00 = X;
 *						- 01 = Y;
 *						- 02 = Z.
 *
 *					And each decimal house represents one order:
 *
 *						- 0xXX0000 = First to be processed;
 *						- 0x00XX00 = Second to be processed;
 *						- 0x0000XX = Third to be processed.
 *
 *					The default global value is NGL_NULL.
 *
 *	@see			NGLObject3D::rotationOrder
 *	@see 			NGLObject3D::rotateX
 *	@see			NGLObject3D::rotateY
 *	@see			NGLObject3D::rotateZ
 *	@see			NGLObject3D::rotateToX:toY:toZ:
 *	@see			NGLObject3D::rotateRelativeToX:toY:toZ:
 *	@see			nglGlobalRotationOrder
 *	
 *	@var			NGLRotationOrderXYZ
 *					Represents rotations in the order XYZ.
 *
 *	@var			NGLRotationOrderXZY
 *					Represents rotations in the order XZY.  This is the default.
 *
 *	@var			NGLRotationOrderYZX
 *					Represents rotations in the order YZX.
 *
 *	@var			NGLRotationOrderYXZ
 *					Represents rotations in the order YXZ.
 *
 *	@var			NGLRotationOrderZXY
 *					Represents rotations in the order ZXY.
 *
 *	@var			NGLRotationOrderZYX
 *					Represents rotations in the order ZYX.
 */
typedef enum
{
	NGLRotationOrderXYZ		= 0x000102,
	NGLRotationOrderXZY		= 0x000201,
	NGLRotationOrderYZX		= 0x010200,
	NGLRotationOrderYXZ		= 0x010002,
	NGLRotationOrderZXY		= 0x020001,
	NGLRotationOrderZYX		= 0x020100,
} NGLRotationOrder;

/*!
 *					Represents the NinevehGL global light state.
 *
 *					NinevehGL works with a single global light, these parameters defines if it will
 *					be used or not.
 *
 *	@see			nglGlobalLightEffects
 *	
 *	@var			NGLLightEffectsON
 *					Turns the global light on.
 *	
 *	@var			NGLLightEffectsOFF
 *					Turns the global light off.
 */
typedef enum
{
	NGLLightEffectsON		= 0x00,	// Default
	NGLLightEffectsOFF		= 0x01,
} NGLLightEffects;

/*!
 *					Represents the NinevehGL global multithreading option.
 *
 *					By default, NinevehGL will use full multithreading, that means:
 *						- One single detached long-lived thread to render.
 *						- Up to five (5) detached short-lived threads to parser.
 *
 *	@see			nglGlobalMultithreading
 *	
 *	@var			NGLMultithreadingFull
 *					Sets NinevehGL to use all the multiple threads.
 *	
 *	@var			NGLMultithreadingParser
 *					Sets NinevehGL to use the parser threads. The render will be done in the main thread.
 *	
 *	@var			NGLMultithreadingRender
 *					Sets NinevehGL to use the render threads. The parsers will be done in the main thread.
 *	
 *	@var			NGLMultithreadingNone
 *					Sets NinevehGL to use no threads. Everything will be done in the main thread.
 */
typedef enum
{
	NGLMultithreadingFull	= 0x00,	// Default
	NGLMultithreadingParser	= 0x01,
	NGLMultithreadingRender	= 0x02,
	NGLMultithreadingNone	= 0x03,
} NGLMultithreading;

#pragma mark -
#pragma mark Global Variables
#pragma mark -
//**********************************************************************************************************
//
//	Global Variables
//
//**********************************************************************************************************

/*!
 *					The global path variable to NinevehGL Path API.
 *
 *					This global property can't be nil. If it is set to nil, it will become the path
 *					to the main bundle.
 */
NGL_API NSString *nglDefaultPath;

/*!
 *					The NinevehGL global frame rate.
 *
 *	@see			nglGlobalFPS
 */
NGL_API unsigned short nglDefaultFPS;

/*!
 *					The NinevehGL global engine property.
 *
 *	@see			NGLEngineVersion
 *	@see			nglGlobalEngine
 */
NGL_API NGLEngineVersion nglDefaultEngine;

/*!
 *					The NinevehGL global color property.
 *
 *	@see			NGLvec4
 *	@see			nglGlobalColor
 */
NGL_API NGLvec4 nglDefaultColor;

/*!
 *					The NinevehGL global color format property.
 *
 *	@see			NGLColorFormat
 *	@see			nglGlobalColorFormat
 */
NGL_API NGLColorFormat nglDefaultColorFormat;

/*!
 *					The NinevehGL front face property.
 *
 *	@see			NGLFrontFace
 *	@see			nglGlobalFrontAndCullFace
 */
NGL_API NGLFrontFace nglDefaultFrontFace;

/*!
 *					The NinevehGL cull face property.
 *
 *	@see			NGLCullFace
 *	@see			nglGlobalFrontAndCullFace
 */
NGL_API NGLCullFace nglDefaultCullFace;

/*!
 *					The NinevehGL global antialias property.
 *
 *	@see			NGLAntialias
 *	@see			nglGlobalAntialias
 */
NGL_API NGLAntialias nglDefaultAntialias;

/*!
 *					The NinevehGL global texture quality property.
 *
 *	@see			NGLTextureQuality
 *	@see			nglGlobalTextureQuality
 */
NGL_API NGLTextureQuality nglDefaultTextureQuality;

/*!
 *					The NinevehGL global texture repeat property.
 *
 *	@see			NGLTextureRepeat
 *	@see			nglGlobalTextureRepeat
 */
NGL_API NGLTextureRepeat nglDefaultTextureRepeat;

/*!
 *					The NinevehGL global texture optimization property.
 *
 *	@see			NGLTextureOptimize
 *	@see			nglGlobalTextureOptimize
 */
NGL_API NGLTextureOptimize nglDefaultTextureOptimize;

/*!
 *					The NinevehGL global rotation space property.
 *
 *	@see			NGLRotationSpace
 *	@see			nglGlobalRotationSpace
 */
NGL_API NGLRotationSpace nglDefaultRotationSpace;

/*!
 *					The NinevehGL global rotation order property.
 *
 *	@see			NGLRotationOrder
 *	@see			nglGlobalRotationOrder
 */
NGL_API NGLRotationOrder nglDefaultRotationOrder;

/*!
 *					The NinevehGL global import settings for NGLMeshes.
 *
 *	@see			NGLMesh::initWithFile:settings:delegate:
 *	@see			NGLMesh::loadFile:file:settings:
 */
NGL_API NSDictionary *nglDefaultImportSettings;

/*!
 *					The NinevehGL global light effect.
 *
 *	@see			NGLLightEffects
 */
NGL_API NGLLightEffects nglDefaultLightEffects;

/*!
 *					The NinevehGL global multithreading option.
 *
 *	@see			NGLMultithreading
 *	@see			nglGlobalMultithreading
 */
NGL_API NGLMultithreading nglDefaultMultithreading;

#pragma mark -
#pragma mark Global Functions
#pragma mark -
//**********************************************************************************************************
//
//	Global Functions
//
//**********************************************************************************************************

/*!
 *					Commit any pending commands in the NinevehGL Global API.
 *
 *					With the advantage of multithreading, the Global API works now asynchronous. Any
 *					change to the Global properties that affect the current render state may not take
 *					effect immediately. To update the current render you must call this function. In short,
 *					nglGlobalFush is the guarantee that the changes will take effect.
 *
 *					By calling this function the changes will be made into the core of NinevehGL and if
 *					there is a render cycle running it may clip/stop for a while (usually a few cycles),
 *					some changes requires the recompilation of the meshes, in this case flush function
 *					may take more time until resume the render cycle. So, as a best practice, change the
 *					global states you want before start any render and avoid making many changes into the
 *					Global API.
 *
 *					Besides, there are global properties that don't affect the current render state.
 *					Those ones have special behavior, they can take effect immediately or in the future,
 *					depends on the property.
 *
 *					Here is a list of the global functions and their behaviors:
 *
 *						- Queued (must call #nglGlobalFlush#):
 *							- nglGlobalEngine;
 *							- nglGlobalColor;
 *							- nglGlobalColorFormat;
 *							- nglGlobalAntialias;
 *							- nglGlobalFrontAndCullFace;
 *							- nglGlobalLightEffects.
 *
 *						- Take effect immediately:
 *							- nglGlobalFilePath;
 *							- nglGlobalFPS;
 *							- nglGlobalRotationSpace;
 *							- nglGlobalRotationOrder;
 *							- nglGlobalMultithreading.
 *
 *						- Future (take effect on the new instances):
 *							- nglGlobalTextureQuality;
 *							- nglGlobalTextureRepeat;
 *							- nglGlobalTextureOptimize;
 *							- nglGlobalImportSettings.
 */
NGL_API void nglGlobalFlush(void);

/*!
 *					Defines a new global path to NinevehGL Path API.
 *
 *					The NinevehGL Path API helps you to load externals files. Every loading in NinevehGL
 *					is made using this API. This is how it works:
 *
 *						- If you inform a full path to a file, like "/Custom/Bundle/myFile.ext", the
 *							NinevehGL Path API will try to find the file in that path;
 *						- If the file was not found there or you inform only the file name, like
 *							"myFile.ext" the Path API will search for the file in the Global Path;
 *						- If there is no file found, an error will be generated and it will be displayed
 *							on the console panel.
 *
 *					You can set any Global Path you want by calling this function. By default, the Global
 *					Path is your application's main bundle.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application.
 *	
 *	@param			filePath
 *					A NSString containing the new global path.
 */
NGL_API void nglGlobalFilePath(NSString *filePath);

/*!
 *					Defines the global frame rate.
 *
 *					The frame rate is the number of times the render will happens per second.
 *					For example, a frame rate with value 30 means that the render cycle will be called
 *					30 times per second.
 *
 *					The frame rate affects the render cycle refresh, but has no effects over APIs based
 *					on absolute time, like the NinevehGL Tween API.
 *
 *					This property respects the maximum frame rate of the current device. The maxium value
 *					is defined by the definition #NGL_MAX_FPS#. Besides, this value can't be 0 (zero).
 *					The minimum frame rate is 1, so if you set it to 0, it will become 1 automatically.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application.
 *
 *					The default value is equals to #NGL_MAX_FPS# definition.
 *
 *	@param			fps
 *					The Frames Per Second you want to use.
 */
NGL_API void nglGlobalFPS(unsigned short fps);

/*!
 *					Defines the OpenGL version.
 *
 *					NinevehGL is prepared to make all the job related to OpenGL. To start using a new
 *					OpenGL version, just call this function once and NinevehGL will make everything else.
 *
 *					The current NinevehGL version supports the following OpenGL versions:
 *
 *						- OpenGL ES 2.0.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application. This function must be followed by a call to #nglGlobalFlush#.
 *	
 *	@param			engine
 *					The NGLEngineVersion representing the desired OpenGL version.
 *
 *	@see			NGLEngineVersion
 *	@see			nglGlobalFlush
 */
NGL_API void nglGlobalEngine(NGLEngineVersion engine);

/*!
 *					Defines the base color. It affects every new NGLView.
 *
 *					The base color changes the NGLView background color and the fog effect color. This
 *					function doesn't change the current background color for existing NGLViews, if you've
 *					changed the view's background color that color will not change. This change just
 *					affect new views.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application. This function must be followed by a call to #nglGlobalFlush#.
 *	
 *	@param			color
 *					A NGLvec4 representing the desired color.
 *
 *	@see			NGLvec4
 *	@see			NGLFog
 *	@see			nglGlobalFlush
 */
NGL_API void nglGlobalColor(NGLvec4 color);

/*!
 *					Defines the basic color format.
 *
 *					The color format will affect all the loaded images and all the resulting images, even
 *					the render's output. The supported color formats are:
 *
 *						- RGBA;
 *						- RGB.
 *
 *					To increase the performance, avoid using the alpha channel.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application. This function must be followed by a call to #nglGlobalFlush#.
 *	
 *	@param			colorFormat
 *					The NGLColorFormat representing the desired color format.
 *
 *	@see			NGLColorFormat
 *	@see			nglGlobalFlush
 */
NGL_API void nglGlobalColorFormat(NGLColorFormat colorFormat);

/*!
 *					Defines the front and cull face.
 *
 *					OpenGL is prepared to differentiate a front face of a back face depending on the order
 *					the vertices were constructed. Based on the front and back faces the OpenGL can cull
 *					one of them or not. To define a front face you can choose:
 *
 *						- Counter Clock Wise order;
 *						- Clock Wise order.
 *
 *					And to choose the culling, you can choose:
 *
 *						- Culling Back;
 *						- Culling Front;
 *						- Culling none.
 *
 *					By default, the front face order is defined by Counter Clock Wise and the culling is
 *					made on back faces.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application. This function must be followed by a call to #nglGlobalFlush#.
 *	
 *	@param			front
 *					The mode which defines the front face. Use a NGLFrontFace constant.
 *	
 *	@param			cull
 *					The desired culling type. Use a NGLCullFace constant.
 *
 *	@see			NGLFrontFace
 *	@see			NGLCullFace
 *	@see			nglGlobalFlush
 */
NGL_API void nglGlobalFrontAndCullFace(NGLFrontFace front, NGLCullFace cull);

/*!
 *					Defines the global antialias filter.
 *
 *					The supported values are:
 *
 *						- NGLAntialiasNone;
 *						- NGLAntialias4X.
 *
 *					The multisampling is a very expensive technique which is applied at every render cycle.
 *					That means a render image will not receive the filter until it's completed. If the
 *					global antialias is set to NGL_NULL (default), that means the local antialias
 *					property will be used, but if you set a valid quality to this function, then
 *					it will be used to any #NGLView#. This property affects all the engines.
 *
 *					If you are planning to use this filter, consider some techniques to avoid render
 *					performance penalties. These techniques are:
 *
 *						- Reduce the global frame rate (FPS);
 *						- Reduce the contentSacleFactor of your NGLView (preferably less than 1.0).
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application. This function must be followed by a call to #nglGlobalFlush#.
 *	
 *	@param			antialias
 *					The NGLAntialias value.
 *
 *	@see			NGLAntialias
 *	@see			nglGlobalFlush
 */
NGL_API void nglGlobalAntialias(NGLAntialias antialias);

/*!
 *					Defines the global texture quality.
 *
 *					Although every #NGLTexture# has its own quality, you can specify a global quality to
 *					be used in place. If the global quality is set to NGL_NULL, that means the local
 *					quality properties will be used, but if you set a valid quality to this function, then
 *					it will be used to any #NGLTexture#. This property is just valid to the new textures.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application.
 *	
 *	@param			quality
 *					The NGLTextureQuality representing the desired quality or NGL_NULL to negate this
 *					global property.
 *
 *	@see			NGLTextureQuality
 *	@see			NGLTexture
 */
NGL_API void nglGlobalTextureQuality(NGLTextureQuality quality);

/*!
 *					Defines the global texture repeat mode.
 *
 *					Although every #NGLTexture# has its own repeat property, you can specify a global
 *					repeat to be used in place. If the global repeat is set to NGL_NULL, that means the
 *					local repeat properties will be used, but if you set a valid repeat to this function,
 *					then it will be used to any #NGLTexture#. This property is just valid to the
 *					new textures.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application.
 *	
 *	@param			repeat
 *					The NGLTextureRepeat representing the desired repeat or NGL_NULL to negate this
 *					global property.
 *
 *	@see			NGLTextureRepeat
 *	@see			NGLTexture
 */
NGL_API void nglGlobalTextureRepeat(NGLTextureRepeat repeat);

/*!
 *					Defines the global texture optimization mode.
 *
 *					Although every #NGLTexture# has its own optimization property, you can specify a global
 *					optimization to be used in place. If the global repeat is set to NGL_NULL, that means
 *					the local optimization properties will be used, but if you set a valid optimization
 *					to this function, then it will be used to any #NGLTexture#. This property is just valid
 *					to the new textures.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application.
 *	
 *	@param			optimize
 *					The NGLTextureOptimize representing the desired optimization mode or NGL_NULL to
 *					negate this global property.
 *
 *	@see			NGLTextureOptimize
 *	@see			NGLTexture
 */
NGL_API void nglGlobalTextureOptimize(NGLTextureOptimize optimize);

/*!
 *					Defines the global rotation space.
 *
 *					Although every #NGLObject3D# has its own rotation space property, you can specify a
 *					global space to be used in place. If the global space is set to NGL_NULL, that means
 *					the local space properties will be used, but if you set a valid rotation space
 *					to this function, then it will be used to any rotation. This affects all #NGLObject3D#,
 *					those currently in the application or new.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application.
 *	
 *	@param			space
 *					The NGLRotationSpace representing the desired rotation space or NGL_NULL to negate this
 *					global property.
 *
 *	@see			NGLRotationSpace
 *	@see			NGLObject3D
 */
NGL_API void nglGlobalRotationSpace(NGLRotationSpace space);

/*!
 *					Defines the global rotation space.
 *
 *					Although every #NGLObject3D# has its own rotation order property, you can specify a
 *					global order to be used in place. If the global order is set to NGL_NULL, that means
 *					the local order properties will be used, but if you set a valid rotation order
 *					to this function, then it will be used to any rotation. This affects all #NGLObject3D#,
 *					those currently in the application or new.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application.
 *	
 *	@param			order
 *					The NGLRotationOrder representing the desired rotation order or NGL_NULL to negate this
 *					global property.
 *
 *	@see			NGLRotationOrder
 *	@see			NGLObject3D
 */
NGL_API void nglGlobalRotationOrder(NGLRotationOrder order);

/*!
 *					Defines the global import settings.
 *
 *					Although every #NGLMesh# has its own import settings, you can specify a global
 *					property to be used in place. If the global property is set to nil, that means the
 *					local settings will be used, but if you set a valid value to this function, then
 *					it will be used to any importing. This setting just affect new imports.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application.
 *	
 *	@param			settings
 *					The global settings. This is a dictionary, just like an import settings object.
 *
 *	@see			NGLMesh
 */
NGL_API void nglGlobalImportSettings(NSDictionary *settings);

/*!
 *					Defines the global light effect.
 *
 *					Although every #NGLObject3D# has its own light effect property, you can specify a
 *					global effect to be used in place. If the global effect is set to NGL_NULL, that means
 *					the local effect properties will be used, but if you set a valid light effect
 *					to this function, then it will be used to any rotation. This affects all #NGLObject3D#,
 *					those currently in the application or new.
 *
 *					Just as any other property of the NinevehGL Global API, this will affect the whole
 *					application. This function must be followed by a call to #nglGlobalFlush#.
 *	
 *	@param			effect
 *					The NGLLightEffects representing the desired light effect or NGL_NULL to negate this
 *					global property.
 *
 *	@see			NGLLightEffects
 *	@see			NGLLight
 *	@see			nglGlobalFlush
 */
NGL_API void nglGlobalLightEffects(NGLLightEffects effect);

/*!
 *					Defines the global multithreading option.
 *
 *					By changing this property, all the current NinevehGL's threads will exit, finishing
 *					its current tasks. In the next cycle/task, the new option will be used. So changing
 *					this property is an asynchronous task.
 *
 *					By default, the NinevehGL will use full multithreading.
 *	
 *	@param			option
 *					The NGLMultithreading option.
 *
 *	@see			NGLMultithreading
 */
NGL_API void nglGlobalMultithreading(NGLMultithreading option);