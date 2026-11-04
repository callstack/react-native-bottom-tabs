import TabView, { SceneMap } from 'react-native-bottom-tabs';
import { useState } from 'react';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';

const renderScene = SceneMap({
  article: Article,
  albums: Albums,
  contacts: Contacts,
  chat: Chat,
});

export default function IconSizes() {
  const [index, setIndex] = useState(0);
  const [routes] = useState([
    {
      key: 'article',
      title: 'Default',
      focusedIcon: require('../../assets/icons/article_dark.png'),
    },
    {
      key: 'albums',
      title: 'Size 20',
      focusedIcon: require('../../assets/icons/grid_dark.png'),
      iconSize: 20,
    },
    {
      key: 'contacts',
      title: 'Size 32',
      focusedIcon: require('../../assets/icons/person_dark.png'),
      iconSize: 32,
    },
    {
      key: 'chat',
      title: 'Size 40',
      focusedIcon: require('../../assets/icons/chat_dark.png'),
      iconSize: 40,
    },
  ]);

  return (
    <TabView
      sidebarAdaptable
      labeled
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
    />
  );
}
