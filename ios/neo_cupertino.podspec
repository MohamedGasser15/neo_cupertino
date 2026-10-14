Pod::Spec.new do |s|
  s.name             = 'neo_cupertino'
  s.version          = '1.0.0'
  s.summary          = 'Next-Generation iOS (iOS 26) UI Kit for Flutter featuring Liquid Glass and Neo-Cupertino controls.'
  s.description      = <<-DESC
Next-Generation iOS (iOS 26) UI Kit providing Cupertino calendar picker, liquid glass shaders, native context menus, and iOS navigation surfaces.
  DESC
  s.homepage         = 'https://github.com/MohamedGasser15/neo_cupertino'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Mohamed Gasser' => 'mohamed@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'neo_cupertino/Sources/neo_cupertino/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
