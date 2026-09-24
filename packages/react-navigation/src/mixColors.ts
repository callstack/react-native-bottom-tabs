import { processColor } from 'react-native';

// eslint-disable-next-line no-bitwise
const channel = (color: number, shift: number) => (color >> shift) & 0xff;

const hex = (value: number) => Math.round(value).toString(16).padStart(2, '0');

export default function mixColors(
  from: string,
  to: string,
  ratio: number
): string | undefined {
  const start = processColor(from);
  const end = processColor(to);

  if (typeof start !== 'number' || typeof end !== 'number') {
    return undefined;
  }

  const mixed = [16, 8, 0].map(
    (shift) => channel(start, shift) * (1 - ratio) + channel(end, shift) * ratio
  );

  return `#${mixed.map(hex).join('')}`;
}
