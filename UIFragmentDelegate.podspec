#
#  Be sure to run `pod spec lint UIFragmentDelegate.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "UIFragmentDelegate"
  spec.version      = "1.0.1.1"
  spec.summary      = "Simple and fast Fragment library for your application"
  spec.description  = <<-DESC
  Free fragments library for your applicatioins. It will really help you (i can't uploud pod without description, so sorry for this bullshit)
                   DESC
  spec.homepage     = "https://github.com/Jeytery/UIFragmentDelegate.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Jeytery" => "dimaostapchenko@gmail.com" }
  spec.ios.deployment_target = "9.0"
   spec.swift_version = "4.2"
  spec.source       = { 
    :git => "https://github.com/Jeytery/UIFragmentDelegate.git",  
    :tag => "#{spec.version}"
  }

  spec.public_header_files = "UIFragmentDelegate/**/*.h"
  spec.source_files = "UIFragmentDelegate/**/*.{h,m,swift}"
  #spec.exclude_files = "Classes/Exclude"

end
