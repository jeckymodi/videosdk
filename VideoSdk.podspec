Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '13.0'
s.name = "VideoSdk"
s.summary = "Videosdk is used for end to end video calls"
s.requires_arc = false

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
s.framework = "UIKit", "AVFoundation", "AudioToolbox", "CoreAudio", "CoreMedia", "CoreVideo"
s.dependency 'Starscream', '3.1.0'
s.dependency 'SwiftyJSON'
s.dependency 'mediasoup_ios_client'

# 8
s.source_files = "VideoSDK/*.{swift}"
s.source_files = "VideoSDK/**/**/**/*.{swift}"
s.source_files = "VideoSDK/**/*.{h}"

# 9
#s.resources = "VideoSDKDemo/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

end
