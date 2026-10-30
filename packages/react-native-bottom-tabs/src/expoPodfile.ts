const BLOCK_START = '# @generated begin react-native-bottom-tabs-svg';
const BLOCK_END = '# @generated end react-native-bottom-tabs-svg';
const PLATFORM_LINE = /^\s*platform\s+:ios\b/;

/**
 * Writes `$RNBottomTabsEnableSVG` into a Podfile, or removes it when
 * `enableSVG` is undefined. The flag goes after the `platform :ios` line,
 * or at the top of the file when the Podfile has no such line.
 */
export function setPodfileSVGFlag(
  contents: string,
  enableSVG: boolean | undefined
): string {
  const lines = contents.split('\n');
  const start = lines.findIndex((line) => line.startsWith(BLOCK_START));
  const end = lines.findIndex(
    (line, index) => index > start && line.startsWith(BLOCK_END)
  );

  // A block without its end marker is removed up to the end of the file.
  if (start !== -1) {
    lines.splice(start, (end === -1 ? lines.length : end + 1) - start);
  }

  if (enableSVG !== undefined) {
    const platformLine = lines.findIndex((line) => PLATFORM_LINE.test(line));

    lines.splice(
      platformLine + 1,
      0,
      `${BLOCK_START} - expo prebuild (DO NOT MODIFY)`,
      `$RNBottomTabsEnableSVG = ${enableSVG}`,
      BLOCK_END
    );
  }

  return lines.join('\n');
}
