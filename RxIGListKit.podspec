#
# Be sure to run `pod lib lint RxIGListKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxIGListKit'
  s.version          = '2.0.2'
  s.summary          = "A RxSwift wrapper for Instagram IGListKit."

  s.description      = <<-DESC
  A RxSwift wrapper for Instagram IGListKit - A data-driven UICollectionView framework for building fast and flexible lists.
  RxIGListKit bring IGListKit into Reactive world.
                       DESC

  s.homepage         = 'https://github.com/RxSwiftCommunity/RxIGListKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bruce-pac' => 'Bruce_pac312@foxmail.com' }
  s.source           = { :git => 'https://github.com/RxSwiftCommunity/RxIGListKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'

  s.swift_version = '5.1'

  s.source_files = 'RxIGListKit/Classes/**/*'

  s.dependency 'RxCocoa', '~> 6.0'
  s.dependency 'IGListKit', '~> 5.0.0'
end
