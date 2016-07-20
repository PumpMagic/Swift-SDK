Pod::Spec.new do |spec|
  spec.name = "KnurldSwiftSDK"
  spec.version = "1.0.0"
  spec.summary = "The Knurld Swift SDK wraps the Knurld web API."
  spec.homepage = "https://github.com/pumpmagic/SwiftSDK"
  spec.license = { type: 'Intellisis', file: 'LICENSE' }
  spec.authors = { "Ryan Conway" => 'rconway@knurld.com' }
  spec.social_media_url = "http://twitter.com/knurld"

  spec.platform = :ios, "9.1"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/pumpmagic/SwiftSDK.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "SwiftSDK/**/*.{h,swift}"

  spec.dependency "Alamofire", "~> 3.4"
  spec.dependency "SwiftyJSON"
end
