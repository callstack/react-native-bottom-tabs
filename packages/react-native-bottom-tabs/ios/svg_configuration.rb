module RNBottomTabs
  # Controls the SVG image decoder, which uses private CoreSVG APIs.
  #
  # The app sets `$RNBottomTabsEnableSVG` in its Podfile, or the
  # `RN_BOTTOM_TABS_ENABLE_SVG` environment variable. The Podfile value wins.
  #
  #   unset                  -> enabled, with a deprecation notice
  #   true / "1" / "yes"     -> enabled
  #   false / "0" / "no"     -> disabled, no private CoreSVG code is compiled
  module SVGConfiguration
    COMPILATION_CONDITION = "RN_BOTTOM_TABS_ENABLE_SVG"
    DEFAULTED_CONDITION = "RN_BOTTOM_TABS_SVG_DEFAULTED"
    ENV_NAME = "RN_BOTTOM_TABS_ENABLE_SVG"
    TRUE_VALUES = ["true", "1", "yes"].freeze
    FALSE_VALUES = ["false", "0", "no"].freeze
    DEPRECATION_MESSAGE =
      "[react-native-bottom-tabs] SVG tab icons and SVG images will be disabled by default in the next major version. " \
      "Set `$RNBottomTabsEnableSVG = true` in your Podfile to keep them, " \
      "or `$RNBottomTabsEnableSVG = false` to remove the private CoreSVG code now."

    # Returns true or false when the app chose, or nil when it did not.
    def self.setting(global: defined?($RNBottomTabsEnableSVG) ? $RNBottomTabsEnableSVG : nil, env: ENV[ENV_NAME])
      value = global.nil? ? env : global
      return value if value == true || value == false

      normalized = value.to_s.strip.downcase
      return nil if normalized.empty?
      return true if TRUE_VALUES.include?(normalized)
      return false if FALSE_VALUES.include?(normalized)

      raise ArgumentError,
            "[react-native-bottom-tabs] Unsupported value #{value.inspect} for `$RNBottomTabsEnableSVG` " \
            "or `#{ENV_NAME}`. Use true or false (or 1 or 0)."
    end

    # TODO(next major): disable SVG when the app does not choose (`setting` is nil).
    def self.enabled?(value = setting)
      value != false
    end

    def self.xcconfig(base, value: setting)
      definitions = []
      definitions << "#{COMPILATION_CONDITION}=1" if enabled?(value)
      definitions << "#{DEFAULTED_CONDITION}=1" if value.nil?
      return base if definitions.empty?

      base.merge("GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) #{definitions.join(' ')}")
    end

    # CocoaPods can evaluate the podspec more than once, so warn once per process.
    def self.warn_if_unset(value = setting)
      return if !value.nil? || @warned

      @warned = true

      if defined?(Pod::UI)
        Pod::UI.warn(DEPRECATION_MESSAGE)
      else
        Kernel.warn(DEPRECATION_MESSAGE)
      end
    end
  end
end
