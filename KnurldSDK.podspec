Pod::Spec.new do |spec|
  spec.name = 'KnurldSDK'
  spec.version = '1.0.0'
  spec.author = { 'Ryan Conway' => 'rconway@knurld.com' }
  spec.social_media_url = 'http://twitter.com/knurld'
  spec.license = { :type => 'BSD', :file => 'LICENSE' }
  spec.homepage = 'https://github.com/PumpMagic/Swift-SDK'
  spec.source = { :git => 'https://github.com/pumpmagic/SwiftSDK.git', :tag => "v#{spec.version}", :submodules => true }
  spec.summary = "Simplifies integration of Knurld's voice verification services with your iOS applications."
  spec.documentation_url = 'https://pumpmagic.github.io/Swift-SDK/'

  spec.platform = :ios, '8.0'

  spec.dependency 'Freddy', '~> 2.1'
  spec.requires_arc = true

  spec.source_files = 'KnurldSDK/**/*.{h,swift}'
end
