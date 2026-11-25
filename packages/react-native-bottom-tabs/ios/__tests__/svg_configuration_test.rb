require "minitest/autorun"
require_relative "../svg_configuration"

class SVGConfigurationTest < Minitest::Test
  Config = RNBottomTabs::SVGConfiguration
  BASE = { "DEFINES_MODULE" => "YES" }.freeze

  def test_unset_is_enabled_and_marked_as_defaulted
    assert_nil Config.setting(global: nil, env: nil)
    assert_nil Config.setting(global: nil, env: " ")
    assert Config.enabled?(nil)
    assert_equal(
      "$(inherited) RN_BOTTOM_TABS_ENABLE_SVG=1 RN_BOTTOM_TABS_SVG_DEFAULTED=1",
      Config.xcconfig(BASE, value: nil)["GCC_PREPROCESSOR_DEFINITIONS"]
    )
  end

  def test_true_values_enable_svg
    [true, "true", "1", "YES"].each do |value|
      assert_equal true, Config.setting(global: value, env: nil), value.inspect
    end
    assert_equal true, Config.setting(global: nil, env: "1")
    assert_equal(
      "$(inherited) RN_BOTTOM_TABS_ENABLE_SVG=1",
      Config.xcconfig(BASE, value: true)["GCC_PREPROCESSOR_DEFINITIONS"]
    )
  end

  def test_false_values_disable_svg
    [false, "false", "0", "no"].each do |value|
      assert_equal false, Config.setting(global: value, env: nil), value.inspect
    end
    assert_equal false, Config.setting(global: nil, env: "0")
    refute Config.enabled?(false)
    assert_equal BASE, Config.xcconfig(BASE, value: false)
  end

  def test_podfile_value_wins_over_environment
    assert_equal false, Config.setting(global: false, env: "1")
    assert_equal true, Config.setting(global: true, env: "0")
  end

  def test_unsupported_value_raises
    assert_raises(ArgumentError) { Config.setting(global: "maybe", env: nil) }
  end

  def test_warns_only_when_unset
    Config.instance_variable_set(:@warned, false)
    _, err = capture_io do
      Config.warn_if_unset(nil)
      Config.warn_if_unset(nil)
    end
    assert_equal 1, err.scan(/next major version/).size

    _, err = capture_io do
      Config.warn_if_unset(true)
      Config.warn_if_unset(false)
    end
    assert_empty err
  end
end
