#
# Be sure to run `pod lib lint HTTPService7Sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HTTPService7Sdk'
  s.version          = '0.1.0'
  s.summary          = 'A short description of HTTPService7Sdk.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/gogopaly@163.com/HTTPService7Sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gogopaly@163.com' => '116050908+GigoGogo790@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/gogopaly@163.com/HTTPService7Sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.source_files = 'HTTPService7Sdk/Classes/**/*'
  
  s.subspec 'RxHTTPService' do |rxh|
      rxh.source_files = 'HTTPService7Sdk/Classes/RxHTTPService/**/*'
      rxh.dependency 'RxSwift'
      rxh.dependency 'Moya/RxSwift'
      rxh.dependency 'HandyJSON'
      rxh.dependency 'MBProgressHUD'
      rxh.dependency 'SSZipArchive'
      rxh.dependency 'Common7Sdk'
  end
  
  s.subspec 'HTTPService' do |h|
      h.source_files = 'HTTPService7Sdk/Classes/HTTPService/**/*'
      h.dependency 'RxSwift'
      h.dependency 'RxCocoa'
      h.dependency 'Moya'
      h.dependency 'HandyJSON'
  end
  
  # s.resource_bundles = {
  #   'HTTPService7Sdk' => ['HTTPService7Sdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'Moya/RxSwift'
  
end
