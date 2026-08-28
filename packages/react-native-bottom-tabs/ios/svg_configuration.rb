module RNBottomTabs
  module SVGConfiguration
    SVG_SOURCES = "ios/SVG/**/*"
    COMPILATION_CONDITION = "RN_BOTTOM_TABS_ENABLE_SVG"

    def self.enabled?
      defined?($RNBottomTabsEnableSVG) && $RNBottomTabsEnableSVG == true
    end

    def self.xcconfig(base, enabled: enabled?)
      return base unless enabled

      base.merge(
        "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) #{COMPILATION_CONDITION}=1",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS" => "$(inherited) #{COMPILATION_CONDITION}"
      )
    end
  end
end
