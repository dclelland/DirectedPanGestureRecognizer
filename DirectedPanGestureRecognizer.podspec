#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name                    = "DirectedPanGestureRecognizer"
  s.version                 = "1.1.2"
  s.summary                 = "DirectedPanGestureRecognizer provides a more comprehensive pan gesture API."
  s.homepage                = "https://github.com/dclelland/DirectedPanGestureRecognizer"
  s.license                 = { :type => 'MIT' }
  s.author                  = { "Daniel Clelland" => "daniel.clelland@gmail.com" }
  s.source                  = { :git => "https://github.com/dclelland/DirectedPanGestureRecognizer.git", :tag => "1.1.2" }
  s.platform                = :ios, '8.0'
  s.ios.deployment_target   = '8.0'
  s.ios.source_files        = 'DirectedPanGestureRecognizer.swift'
  s.requires_arc            = true
end
