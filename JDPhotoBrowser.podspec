#
# Be sure to run `pod lib lint JDPhotoBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JDPhotoBrowser'
  s.version          = '0.1.2'
  s.summary          = '图片浏览器 swift JDPhotoBrowser.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
一款高仿微信图片浏览器swift版本
                       DESC

  s.homepage         = 'https://github.com/1271284056'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1271284056' => '1271284056@qq.com' }
  s.source           = { :git => 'https://github.com/1271284056/JDPhotoBrowser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'JDPhotoBrowser/Classes/**/*'
  
   s.resource_bundles = {
     'JDPhotoBrowser' => ['JDPhotoBrowser/Assets/*.png']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
s.dependency 'SDWebImage', '~> 4.0.0'
end
