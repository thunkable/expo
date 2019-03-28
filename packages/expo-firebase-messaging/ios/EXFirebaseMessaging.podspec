require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'EXFirebaseMessaging'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platform       = :ios, '10.0'
  s.source         = { git: 'https://github.com/expo/expo.git' }
  s.source_files   = 'EXFirebaseMessaging/**/*.{h,m}'
  s.preserve_paths = 'EXFirebaseMessaging/**/*.{h,m}'
  s.requires_arc   = true

  s.dependency 'EXCore'
  s.dependency 'EXFirebaseApp'
  s.dependency 'Firebase/Messaging'
end

  
