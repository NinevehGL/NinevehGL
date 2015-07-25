![NinevehGL](http://nineveh.gl/imgs/ninevehgl_logo_512.png)

[![Version](https://img.shields.io/cocoapods/v/NinevehGL.svg?style=flat)](http://cocoapods.org/pods/NinevehGL)
[![License](https://img.shields.io/cocoapods/l/NinevehGL.svg?style=flat)](http://cocoapods.org/pods/NinevehGL)
[![Platform](https://img.shields.io/cocoapods/p/NinevehGL.svg?style=flat)](http://cocoapods.org/pods/NinevehGL)
[![CI Status](https://img.shields.io/travis/NinevehGL/NinevehGL.svg?style=flat)](https://travis-ci.org/NinevehGL/NinevehGL)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation

Nippur is compatible with iOS 7 or later.
Nippur is available through [CocoaPods](http://cocoapods.org/pods/NinevehGL). To install
it, simply add the following line to your Podfile:

![NinevehGL](http://nineveh.gl/imgs/ninevehgl_icon_152.png)

```ruby
pod "Nippur"
```

Now just add to your Prefix Header (.pch):

```objc
#import "NinevehGL.h"
```

## Roadmap

### 1.0.0 (future)

- Major Release
- NGL Binary Conversor (On-line)

### 0.9.9 (future)

- Physics system
 
### 0.9.8 (future)

- Particle system

### 0.9.7 (future)

- Real time Shadow and Reflections.
- Bone, Rigging and Animations.
- Mesh M 
orph.

### 0.9.6 (future)

- Metal compatibility
- Vulkan compatibility
- OpenGL ES 3 compatibility

### 0.9.5 (future)

- Swift made
- Modular (Packages)
- Nodes es.
jects

### 0.9.4 (future)

- Full Touch API.
- You can add gesture recognizers to 3D objects. The same gestures of UIKit.
- NinevehGL can tell which specific surface of a mesh is being touched.
- There are 3 different kind of touch recognition with different kind of precisions and performance.
- The background color is now the same as UIKit view, in fact they are now the same thing.
- Bug fixed on "compileCoreMesh" flicking.
- Bug fixed on custom shaders Attributes/Uniforms.

### 0.9.3 - Sat, March 10 2012

- Full MultiThreading.
- It's more than just MultiThread safe!
- NinevehGL works on private threads, letting the main-thread free.
- Loading and Parsing 3D files are done on many background threads, don't affecting the render threads.
- Loading/Parsing threads can send notifications about its own progress.
- NinevehGL automatically creates and manages its threads.
- AR Ready. The Qualcomm AR is now natively supported by NinevehGL. Perfect integration.
- New NGLGroup3D. You can set a group with any kind of NGLObject3D.
- The NinevehGL's old limit of ~120.000 triangles per mesh is improved to ~4 billions.
- The NinevehGL accepts non-POT textures and there is no size limits anymore.
- New features on NinevehGL Tween API (NGLTween).
- New Tutorials and Sample projects.
- New installer. NinevehGL has now Xcode 4 templates.
- Lens methods on NGLCamera has changed.
- Many methods on NGLMesh has changed.
- More rotation options to all 3D objects.
- The antialias filter has now a global property.
- Bug fixed on Retina Displays.
- Bug fixed on armv6 architecture.
- Bug fixed on NGLTween pause.
- Bug fixed on Alpha blending (PNG).
- Bug fixed on Mesh scale (appearing in black).
- Bug fixed on Screenshots (off-screen renders).
- Bug fixed on Orthographic projection (NGLCamera).

### 0.9.2 - Wed, Sep 14 2011

- New Interactive API.
- Camera auto adjust to device orientation.
- Draw directly to an image (UIImage), texture (NGLTexture) or data (NSData as image).
- New Tween API.
- Create tweens to move any scalar properties of your objects.
- Use predefined ease functions or create your own ease equation.
- The new copying methods "copy" and "copyInstance".
- NGLTexture also accepts UIImage instances.
- Major improvements on render cycle.
- Major improvements on Shaders.
- Automatically Handles background application.
- Some changes on methods and classes' names.
- The Frame Rate (FPS) becomes a global property.
- Import settings also have global properties.
- Full remake of NinevehGL Docs.
- Bug fixed on textures with spaces in OBJ files.
- Bug fixed on "minimum" values of the NGLMesh's BoundingBox.
- Bug fixed on transparent layer (RGBA).
- Bug fixed on Collada files from XSI.
- Bug fixed on reinitializing the same NGLView.

### 0.9.1 - Tue, Jun 28 2011

- Bug fixed: "Flickering Mesh".
- Small optimization in fragment shaders.

### 0.9.0 - Wed, Jun 22 2011

- NinevehGL goes public - Open Beta.

## Author

NinevehGL, ngl@nineveh.gl

## License

Nippur is available under the MIT license. See the LICENSE file for more info.