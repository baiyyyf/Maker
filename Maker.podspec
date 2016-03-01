Pod::Spec.new do |s|

  s.name         = "Maker"
  s.version      = "0.1.0"
  s.summary      = "Convert JSON to Object."

  s.description  = <<-DESC
                   Maker: Convert JSON to Object. 
                   DESC

  s.homepage     = "https://github.com/baiyyyf/Maker"
  #s.screenshots  = "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png"

  s.license      = 'MIT'

  s.authors            = { "baiyyyf" => "byunfi@outlook.com" }
  s.social_media_url   = "http://twitter.com/baiyyyf"

  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/baiyyyf/Maker.git", :tag => s.version }

  s.source_files  = ["Source/*.swift", "Source/Maker.h"]
  s.public_header_files = ["Source/Maker.h"]


  s.requires_arc = true
  s.framework = "UIKit"

end
