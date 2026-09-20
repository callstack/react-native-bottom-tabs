import * as React from 'react';

export type TabSceneInsets = Readonly<{
  top: number;
  right: number;
  bottom: number;
  left: number;
}>;

export const TabSceneInsetsContext = React.createContext<
  TabSceneInsets | undefined
>(undefined);

/** Native scene safe-area insets, or undefined before measurement/on unsupported platforms. */
export function useTabSceneInsets() {
  return React.useContext(TabSceneInsetsContext);
}
