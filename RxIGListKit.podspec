#
# Be sure to run `pod lib lint RxIGListKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxIGListKit'
  s.version          = '1.0.1'
  s.summary          = "A RxSwift wrapper for Instagram IGListKit."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A RxSwift wrapper for Instagram IGListKit - A data-driven UICollectionView framework for building fast and flexible lists.
  RxIGListKit bring IGListKit into Reactive world.
                       DESC

  s.homepage         = 'https://github.com/RxSwiftCommunity/RxIGListKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bruce-pac' => 'Bruce_pac312@foxmail.com' }
  s.source           = { :git => 'https://github.com/RxSwiftCommunity/RxIGListKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.swift_version = '5.0'

  s.source_files = 'RxIGListKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RxIGListKit' => ['RxIGListKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RxCocoa'
  s.dependency 'IGListKit'
end
