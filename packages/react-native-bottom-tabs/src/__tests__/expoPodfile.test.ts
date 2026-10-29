import { setPodfileSVGFlag } from '../expoPodfile';

const podfile = [
  "require 'json'",
  "platform :ios, podfile_properties['ios.deploymentTarget'] || '15.1'",
  '',
  "target 'HelloWorld' do",
  'end',
].join('\n');

describe('setPodfileSVGFlag', () => {
  it('adds the flag after the platform line', () => {
    const result = setPodfileSVGFlag(podfile, true).split('\n');

    expect(result[2]).toMatch(
      /^# @generated begin react-native-bottom-tabs-svg/
    );
    expect(result[3]).toBe('$RNBottomTabsEnableSVG = true');
    expect(result[4]).toBe('# @generated end react-native-bottom-tabs-svg');
  });

  it('writes false to disable SVG', () => {
    expect(setPodfileSVGFlag(podfile, false)).toContain(
      '$RNBottomTabsEnableSVG = false'
    );
  });

  it('replaces an existing flag instead of adding a second one', () => {
    const once = setPodfileSVGFlag(podfile, true);
    const twice = setPodfileSVGFlag(setPodfileSVGFlag(once, true), false);

    expect(twice.match(/\$RNBottomTabsEnableSVG/g)).toHaveLength(1);
    expect(twice).toContain('$RNBottomTabsEnableSVG = false');
  });

  it('removes the flag when the option is unset', () => {
    expect(setPodfileSVGFlag(setPodfileSVGFlag(podfile, true), undefined)).toBe(
      podfile
    );
  });

  it('adds the flag at the top when there is no platform line', () => {
    const result = setPodfileSVGFlag("target 'App' do\nend", true).split('\n');

    expect(result[1]).toBe('$RNBottomTabsEnableSVG = true');
    expect(result[3]).toBe("target 'App' do");
  });
});
