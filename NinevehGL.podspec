Pod::Spec.new do |s|
  s.name             = "NinevehGL"
  s.version          = "0.9.3"
  s.summary          = "NinevehGL is a 3D Engine made to Apple's platforms."
  s.description      = <<-DESC
                       NinevehGL is a 3D engine, working with OpenGL ES, Metal and Vulkan.
                       DESC
  s.homepage         = "http://nineveh.gl/"
  s.documentation_url = "http://nineveh.gl/docs/index.html"
  s.screenshots      = ["http://nineveh.gl/imgs/ninevehgl_img.png", "http://nineveh.gl/imgs/ngl_lesson_10_1.png"]
  s.license          = 'MIT'
  s.author           = { "NinevehGL" => "ngl@nineveh.gl" }
  s.source           = { :git => "https://github.com/dineybomfim/Nippur.git", :tag => s.version, :submodules => true }
  s.social_media_url = 'https://twitter.com/ninevehgl'

  s.requires_arc = false
  s.ios.deployment_target = '7.0'

  s.subspec 'Core' do |ss|
    ss.public_header_files = 'Source/**/*.h'
    ss.source_files = 'Source/**/*.{h,m}'
    ss.ios.frameworks = 'Foundation', 'CoreGraphics', 'QuartzCore', 'OpenGLES'
  end

  #s.subspec 'Loader' do |ss|
  #  ss.dependency 'NinevehGL/Core'
  #  ss.public_header_files = 'Source/Loader/*.h'
  #  ss.private_header_files = 'Source/Loader/NGLLoader?*.h'
  #  ss.source_files = 'Source/Loader/*.{h,m}'
  #end

end
