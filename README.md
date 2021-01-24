# RxIGListKit

A [RxSwift](https://github.com/ReactiveX/RxSwift) wrapper for Instagram's [IGListKit](https://github.com/Instagram/IGListKit) - A data-driven `UICollectionView` framework for building fast and flexible lists.RxIGListKit bring IGListKit into Reactive world.

[![Build Status](https://travis-ci.org/RxSwiftCommunity/RxIGListKit.svg?branch=master)](https://travis-ci.org/RxSwiftCommunity/RxIGListKit)
[![Version](https://img.shields.io/cocoapods/v/RxIGListKit.svg?style=flat)](https://cocoapods.org/pods/RxIGListKit)
![Carthage](https://camo.githubusercontent.com/3dc8a44a2c3f7ccd5418008d1295aae48466c141/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f43617274686167652d636f6d70617469626c652d3442433531442e7376673f7374796c653d666c6174)
[![License](https://img.shields.io/cocoapods/l/RxIGListKit.svg?style=flat)](https://cocoapods.org/pods/RxIGListKit)
[![Platform](https://img.shields.io/cocoapods/p/RxIGListKit.svg?style=flat)](https://cocoapods.org/pods/RxIGListKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
let dataSource = RxListAdapterDataSource<String>(sectionControllerProvider: { _,_ in
            LabelSectionController()
})
let objectsSignal = BehaviorSubject<[String]>(value: [])
objectsSignal.bind(to: adapter.rx.objects(dataSource: dataSource)).disposed(by: bag)
```

## Requirements

Swift 5 & Xcode 10.2 & RxCocoa

## Installation

RxIGListKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxIGListKit'
```

For [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

```
github "RxSwiftCommunity/RxIGListKit" "master"
```

## Author

Bruce-pac, Bruce_pac312@foxmail.com

## License

RxIGListKit is available under the MIT license. See the LICENSE file for more info.
