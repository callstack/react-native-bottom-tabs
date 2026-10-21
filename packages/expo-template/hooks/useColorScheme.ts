import { useColorScheme as useRNColorScheme } from 'react-native';

/**
 * React Native reports `unspecified` when the system has no preference, so anything other than `dark` is treated as `light`.
 */
export function useColorScheme() {
  return useRNColorScheme() === 'dark' ? 'dark' : 'light';
}
