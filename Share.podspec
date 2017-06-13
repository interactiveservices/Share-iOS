#
# Be sure to run `pod lib lint Share.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Share'
  s.version          = '0.1.0'
  s.summary          = 'Easy way to share by some services'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
 
  s.homepage         = 'https://github.com/interactiveservices/Share-iOS.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nikolay.shubenkov@gmail.com' => 'n.shubenkov@be-interactive.ru' }
  s.source           = {
    :git => 'https://github.com/interactiveservices/Share-iOS.git', :tag => s.version.to_s,
    :submodules => true
  }
  s.frameworks       = 'UIKit','MessageUI'
  s.platform         = :ios

  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.subspec 'Core' do |s|
    s.source_files = 'Share/Classes/{Core,Base}/*'
  end

  s.default_subspec = 'Core'

  #submodules
  s.subspec 'Vk' do |sp|

    sp.source_files = 'Share/Classes/Vk/*'
    sp.dependency 'Share/Core'
    sp.dependency 'VK-ios-sdk', '~> 1.4'
  end

end
