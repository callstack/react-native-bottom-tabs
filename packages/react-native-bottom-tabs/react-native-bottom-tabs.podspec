require "json"
require_relative "ios/svg_configuration"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-bottom-tabs"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.ios.deployment_target = "14.0"
  s.visionos.deployment_target = "1.0"
  s.tvos.deployment_target = "15.1"
  s.osx.deployment_target = "11.0"

  s.source       = { :git => "https://github.com/okwasniewski/react-native-bottom-tabs.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,cpp,swift}"
  s.static_framework = true

  s.subspec "common" do |ss|
    ss.source_files         = "common/cpp/**/*.{cpp,h}"
    ss.pod_target_xcconfig  = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/common/cpp\"" }
  end

  s.dependency "SwiftUIIntrospect", '~> 1.0'

  s.exclude_files = RNBottomTabs::SVGConfiguration::SVG_SOURCES unless RNBottomTabs::SVGConfiguration.enabled?

  s.pod_target_xcconfig = RNBottomTabs::SVGConfiguration.xcconfig(
    { 'DEFINES_MODULE' => 'YES' }
  )

  install_modules_dependencies(s)
end
