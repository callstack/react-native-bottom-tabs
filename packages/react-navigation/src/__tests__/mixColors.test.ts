import mixColors from '../mixColors';

it.each([
  ['#000000', '#ffffff', 0.5, '#808080'],
  ['#000000', '#ffffff', 0, '#000000'],
  ['#000000', '#ffffff', 1, '#ffffff'],
  ['#ff0000', '#0000ff', 0.5, '#800080'],
])('mixes %s with %s at %s', (from, to, ratio, expected) => {
  expect(mixColors(from, to, ratio)).toBe(expected);
});

it.each([
  ['rgb(0, 0, 0)', 'rgb(255, 255, 255)'],
  ['#000', '#fff'],
  ['black', 'white'],
  ['rgba(0, 0, 0, 1)', 'rgba(255, 255, 255, 1)'],
])('accepts %s and %s', (from, to) => {
  expect(mixColors(from, to, 0.5)).toBe('#808080');
});

it('ignores alpha and mixes the color channels', () => {
  expect(mixColors('rgba(0, 0, 0, 0.2)', 'rgba(255, 255, 255, 0.9)', 0.5)).toBe(
    '#808080'
  );
});

it('returns undefined when a color cannot be parsed', () => {
  expect(mixColors('not a color', '#ffffff', 0.5)).toBeUndefined();
});
