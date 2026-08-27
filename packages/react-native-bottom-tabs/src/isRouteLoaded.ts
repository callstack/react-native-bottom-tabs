import type { BaseRoute } from './types';

export const isRouteLoaded = <Route extends BaseRoute>(
  route: Route,
  focusedKey: string,
  loaded: string[],
  getLazy: (props: { route: Route }) => boolean | undefined
) =>
  getLazy({ route }) === false ||
  route.key === focusedKey ||
  loaded.includes(route.key);
