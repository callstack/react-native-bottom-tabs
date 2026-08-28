require "minitest/autorun"
require_relative "../svg_configuration"

class SVGConfigurationTest < Minitest::Test
  def test_svg_support_is_disabled_by_default
    $RNBottomTabsEnableSVG = nil

    refute RNBottomTabs::SVGConfiguration.enabled?
    assert_equal "ios/SVG/**/*", RNBottomTabs::SVGConfiguration::SVG_SOURCES
    assert_equal(
      { "DEFINES_MODULE" => "YES" },
      RNBottomTabs::SVGConfiguration.xcconfig({ "DEFINES_MODULE" => "YES" })
    )
  end

  def test_global_flag_enables_svg_support
    $RNBottomTabsEnableSVG = true

    assert RNBottomTabs::SVGConfiguration.enabled?
  end

  def test_opt_in_sets_compilation_conditions
    xcconfig = RNBottomTabs::SVGConfiguration.xcconfig(
      { "DEFINES_MODULE" => "YES" },
      enabled: true
    )

    assert_equal "YES", xcconfig["DEFINES_MODULE"]
    assert_equal(
      "$(inherited) RN_BOTTOM_TABS_ENABLE_SVG=1",
      xcconfig["GCC_PREPROCESSOR_DEFINITIONS"]
    )
    assert_equal(
      "$(inherited) RN_BOTTOM_TABS_ENABLE_SVG",
      xcconfig["SWIFT_ACTIVE_COMPILATION_CONDITIONS"]
    )
  end
end
