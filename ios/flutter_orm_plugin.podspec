#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_orm_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A orm database Flutter plugin.'
  s.description      = <<-DESC
A orm database Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'LuakitPod', '>=  1.0.24'

  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

