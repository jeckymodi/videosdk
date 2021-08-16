Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "VideoSdkDemo"
s.summary = "Videosdk is used for end to end video calls"
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "jecky633" => "modijecky@live.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/jeckymodi/videosdk"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/jeckymodi/videosdk.git",
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"
s.dependency 'Starscream', '3.0.2'
s.dependency 'SwiftyJSON', '~> 4.0'
s.dependency 'mediasoup_ios_client', "~> 1.5.4"

# 8
s.source_files = "VideoSDKDemo/**/*.{swift}"

# 9
s.resources = "VideoSDKDemo/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

end
