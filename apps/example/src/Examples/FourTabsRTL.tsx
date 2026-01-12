import TabView, { SceneMap } from 'react-native-bottom-tabs';
import React from 'react';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';
import { I18nManager, type ColorValue } from 'react-native';
import type { LayoutDirection } from 'react-native-bottom-tabs';

interface Props {
  disablePageAnimations?: boolean;
  scrollEdgeAppearance?: 'default' | 'opaque' | 'transparent';
  backgroundColor?: ColorValue;
  translucent?: boolean;
  hideOneTab?: boolean;
  rippleColor?: ColorValue;
  activeIndicatorColor?: ColorValue;
  layoutDirection?: LayoutDirection;
}

const renderScene = SceneMap({
  article: Article,
  albums: Albums,
  contacts: Contacts,
  chat: Chat,
});

export default function FourTabsRTL({
  disablePageAnimations = false,
  scrollEdgeAppearance = 'default',
  backgroundColor,
  translucent = true,
  hideOneTab = false,
  rippleColor,
  activeIndicatorColor,
  layoutDirection = 'locale',
}: Props) {
  React.useLayoutEffect(() => {
    if (layoutDirection === 'rtl') {
      I18nManager.allowRTL(true);
      I18nManager.forceRTL(true);
    }
    return () => {
      if (layoutDirection === 'rtl') {
        I18nManager.allowRTL(false);
        I18nManager.forceRTL(false);
      }
    };
  }, [layoutDirection]);
  const [index, setIndex] = React.useState(0);
  const [routes] = React.useState([
    {
      key: 'article',
      title: 'المقالات',
      focusedIcon: require('../../assets/icons/article_dark.png'),
      unfocusedIcon: require('../../assets/icons/chat_dark.png'),
      badge: '!',
    },
    {
      key: 'albums',
      title: 'البومات',
      focusedIcon: require('../../assets/icons/grid_dark.png'),
      badge: '5',
      hidden: hideOneTab,
    },
    {
      key: 'contacts',
      focusedIcon: require('../../assets/icons/person_dark.png'),
      title: 'المتراسلين',
      badge: ' ',
    },
    {
      key: 'chat',
      focusedIcon: require('../../assets/icons/chat_dark.png'),
      title: 'المحادثات',
      role: 'search',
    },
  ]);

  return (
    <TabView
      sidebarAdaptable
      disablePageAnimations={disablePageAnimations}
      scrollEdgeAppearance={scrollEdgeAppearance}
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
      tabBarStyle={{ backgroundColor }}
      translucent={translucent}
      rippleColor={rippleColor}
      activeIndicatorColor={activeIndicatorColor}
      layoutDirection={layoutDirection}
    />
  );
}
