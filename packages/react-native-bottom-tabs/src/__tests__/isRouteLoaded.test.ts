import { isRouteLoaded } from '../isRouteLoaded';

type Route = {
  key: string;
  lazy?: boolean;
};

const getLazy = ({ route }: { route: Route }) => route.lazy;

describe('isRouteLoaded', () => {
  it('loads the focused lazy route before it is persisted as loaded', () => {
    expect(isRouteLoaded({ key: 'albums' }, 'albums', [], getLazy)).toBe(true);
  });

  it('keeps an unvisited lazy route unloaded', () => {
    expect(isRouteLoaded({ key: 'albums' }, 'article', [], getLazy)).toBe(
      false
    );
  });

  it('loads eager and previously visited routes', () => {
    expect(
      isRouteLoaded({ key: 'albums', lazy: false }, 'article', [], getLazy)
    ).toBe(true);
    expect(
      isRouteLoaded({ key: 'albums' }, 'article', ['albums'], getLazy)
    ).toBe(true);
  });
});
