import TabView, { SceneMap } from 'react-native-bottom-tabs';
import { useState } from 'react';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';
import { Platform } from 'react-native';

const renderScene = SceneMap({
  article: Article,
  albums: Albums,
  contacts: Contacts,
  chat: Chat,
});

const isAndroid = Platform.OS === 'android';

export default function SFSymbols() {
  const [index, setIndex] = useState(0);
  const [routes] = useState([
    {
      key: 'article',
      title: 'Article',
      focusedIcon: isAndroid
        ? require('../../assets/icons/article_dark.png')
        : { sfSymbol: 'document.fill' as const, weight: 'bold' as const },
      unfocusedIcon: isAndroid
        ? require('../../assets/icons/chat_dark.png')
        : { sfSymbol: 'document' as const, weight: 'light' as const },
      badge: '!',
    },
    {
      key: 'albums',
      title: 'Albums',
      // A palette symbol keeps its own per-layer colors instead of the tab tint.
      focusedIcon: isAndroid
        ? require('../../assets/icons/grid_dark.png')
        : {
            sfSymbol: 'square.grid.3x2.fill' as const,
            renderingMode: 'palette' as const,
            colors: { primary: '#FF3B30', secondary: '#34C759' },
          },
      badge: '5',
    },
    {
      key: 'contacts',
      focusedIcon: isAndroid
        ? require('../../assets/icons/person_dark.png')
        : {
            sfSymbol: 'person.fill' as const,
            renderingMode: 'hierarchical' as const,
            color: '#AF52DE',
          },
      title: 'Contacts',
      role: 'search' as const,
    },
    {
      key: 'chat',
      title: 'Signal',
      // A variable symbol rendered at 60% of its layers.
      focusedIcon: isAndroid
        ? require('../../assets/icons/chat_dark.png')
        : {
            sfSymbol: 'wifi' as const,
            variableValue: 0.6,
            scale: 'large' as const,
          },
    },
  ]);

  return (
    <TabView
      sidebarAdaptable
      minimizeBehavior="onScrollDown"
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
    />
  );
}
