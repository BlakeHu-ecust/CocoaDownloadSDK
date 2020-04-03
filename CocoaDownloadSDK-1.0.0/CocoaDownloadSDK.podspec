Pod::Spec.new do |s|
  s.name = "CocoaDownloadSDK"
  s.version = "1.0.0"
  s.summary = "A userful download SDK."
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"Yue Hu"=>"huyue@hsgene.com"}
  s.homepage = "https://github.com/BlakeHu-ecust/CocoaDownloadSDK"
  s.description = "\u4E3A\u5C0F\u7FFC\u7BA1\u5BB6\u63D0\u4F9B\u7684\u4E0B\u8F7DSDK"
  s.frameworks = "UIKit"
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/CocoaDownloadSDK.framework'
end
