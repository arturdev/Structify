#
# Be sure to run `pod lib lint Structify.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Structify'
  s.version          = '0.1.0'
  s.summary          = 'Convert Swift structs to Objc Classes'

  s.description      = <<-DESC
Structify provides simple way to convert Swift structs into classes and vice-a-versa
                       DESC

  s.homepage         = 'https://github.com/arturdev/Structify'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'arturdev' => 'mkrtarturdev@gmail.com' }
  s.source           = { :git => 'https://github.com/arturdev/Structify.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'

  s.source_files = 'Structify/Classes/**/*'
  
  s.dependency 'Reflection', '0.18.1'  
  
end
