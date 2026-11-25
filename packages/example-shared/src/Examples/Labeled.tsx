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

export default function LabeledTabs({
  showLabels = true,
}: {
  showLabels?: boolean;
}) {
  const [index, setIndex] = useState(0);
  const [routes] = useState([
    {
      key: 'article',
      title: 'Article',
      focusedIcon: require('../../assets/icons/article_dark.png'),
      badge: '!',
    },
    {
      key: 'albums',
      title: 'Albums',
      focusedIcon: require('../../assets/icons/grid_dark.png'),
      badge: '5',
    },
    {
      key: 'contacts',
      focusedIcon: require('../../assets/icons/person_dark.png'),
      title: 'Contacts',
    },
    {
      key: 'chat',
      focusedIcon: require('../../assets/icons/chat_dark.png'),
      title: 'Chat',
    },
  ]);

  return (
    <TabView
      labeled={showLabels}
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
    />
  );
}
