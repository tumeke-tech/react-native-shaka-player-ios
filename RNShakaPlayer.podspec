require 'json'
require_relative 'scripts/install_shaka_framework'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

RNShakaPlayer::FrameworkInstaller.install(__dir__)

Pod::Spec.new do |s|
  s.name                = "RNShakaPlayer"
  s.version             = package['version']
  s.summary             = package['description']
  s.homepage            = package['homepage']
  s.license             = package['license']
  s.authors             = package['author']
  s.source              = { :git => package['homepage'], :tag => "v#{s.version}" }
  s.requires_arc        = true
  s.platform            = :ios, "13.0"
  s.source_files        = "ios/**/*.{h,m,mm,swift}"
  s.preserve_paths      = "**/*.js"
  s.ios.vendored_frameworks   = 'apple/ShakaPlayerEmbedded.xcframework', 'apple/ShakaPlayerEmbedded.FFmpeg.xcframework'

  s.public_header_files = 'ios/RNShakaPlayer.h', 'ios/RNShakaPlayerView.h', 'ios/RNShakaPlayerViewManager.h'
  
  if defined?(install_modules_dependencies()) != nil
    install_modules_dependencies(s)
  else
    s.dependency "React-Core"
  end
end