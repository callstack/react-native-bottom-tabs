import TabView, { SceneMap } from 'react-native-bottom-tabs';
import { useState } from 'react';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';
import { Platform, type ColorValue } from 'react-native';

interface Props {
  disablePageAnimations?: boolean;
  scrollEdgeAppearance?: 'default' | 'opaque' | 'transparent';
  backgroundColor?: ColorValue;
  translucent?: boolean;
  hideOneTab?: boolean;
  rippleColor?: ColorValue;
  activeIndicatorColor?: ColorValue;
}

const renderScene = SceneMap({
  article: Article,
  albums: Albums,
  contacts: Contacts,
  chat: Chat,
});

export default function FourTabs({
  disablePageAnimations = false,
  scrollEdgeAppearance = 'default',
  backgroundColor,
  translucent = true,
  hideOneTab = false,
  rippleColor,
  activeIndicatorColor,
}: Props) {
  const [index, setIndex] = useState(0);
  const [routes] = useState([
    {
      key: 'article',
      title: 'Article',
      focusedIcon: require('../../assets/icons/article_dark.png'),
      unfocusedIcon: require('../../assets/icons/chat_dark.png'),
      badge: '!',
    },
    {
      key: 'albums',
      title: 'Albums',
      focusedIcon: require('../../assets/icons/grid_dark.png'),
      badge: '5',
      hidden: hideOneTab,
    },

    {
      key: 'chat',
      focusedIcon: require('../../assets/icons/chat_dark.png'),
      title: 'Chat',
    },
    {
      key: 'contacts',
      focusedIcon: require('../../assets/icons/person_dark.png'),
      title: 'Contacts',
      badge: ' ',
      role: 'search',
      searchable: true,
      navigationBarToolbarStyle:
        Platform.Version === '26.0' ? 'hidden' : 'visible',
    },
  ]);

  return (
    <TabView
      onSearchFocusChange={(isFocused) => console.log('isFocused', isFocused)}
      sidebarAdaptable
      onSearchTextChange={(text) => console.log(text)}
      disablePageAnimations={disablePageAnimations}
      scrollEdgeAppearance={scrollEdgeAppearance}
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
      tabBarStyle={{ backgroundColor }}
      translucent={translucent}
      rippleColor={rippleColor}
      activeIndicatorColor={activeIndicatorColor}
    />
  );
}
