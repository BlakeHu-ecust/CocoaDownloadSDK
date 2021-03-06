#
# Be sure to run `pod lib lint CocoaDownloadSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CocoaDownloadSDK'
  s.version          = '1.0.8'
  s.summary          = 'A userful download SDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '为小翼管家提供的下载SDK，负责底层下载任务管理，高效简洁'

  s.homepage         = 'https://github.com/BlakeHu-ecust/CocoaDownloadSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yue Hu' => 'huyue@hsgene.com' }
  s.source           = { :git => 'https://github.com/BlakeHu-ecust/CocoaDownloadSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CocoaDownloadSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CocoaDownloadSDK' => ['CocoaDownloadSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'AFNetworking'
end
