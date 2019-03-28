require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'ABI32_0_0EXFontInterface'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platform       = :ios, '10.0'
  s.source         = { git: 'https://github.com/expo/expo.git' }
  s.source_files   = 'ABI32_0_0EXFontInterface/**/*.{h,m}'
  s.preserve_paths = 'ABI32_0_0EXFontInterface/**/*.{h,m}'
  s.requires_arc   = true

  s.dependency 'ABI32_0_0EXCore'

end

  
