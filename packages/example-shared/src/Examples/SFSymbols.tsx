import TabView, { SceneMap } from 'react-native-bottom-tabs';
import { useState } from 'react';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Platform } from 'react-native';

const renderScene = SceneMap({
  article: Article,
  albums: Albums,
  contacts: Contacts,
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
        : { sfSymbol: 'document.fill' },
      unfocusedIcon: isAndroid
        ? require('../../assets/icons/chat_dark.png')
        : { sfSymbol: 'document' },
      badge: '!',
    },
    {
      key: 'albums',
      title: 'Albums',
      focusedIcon: isAndroid
        ? require('../../assets/icons/grid_dark.png')
        : { sfSymbol: 'square.grid.3x2.fill' },
      badge: '5',
    },
    {
      key: 'contacts',
      focusedIcon: isAndroid
        ? require('../../assets/icons/person_dark.png')
        : { sfSymbol: 'person.fill' },
      title: 'Contacts',
      role: 'search',
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
