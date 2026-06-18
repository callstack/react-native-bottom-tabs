import TabView, { SceneMap } from 'react-native-bottom-tabs';
import { useState } from 'react';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';

const renderScene = SceneMap({
  tinted: Article,
  avatar: Contacts,
  album: Albums,
  chat: Chat,
});

export default function OriginalIconColors() {
  const [index, setIndex] = useState(0);
  const [routes] = useState([
    {
      key: 'tinted',
      title: 'Tinted',
      focusedIcon: require('../../assets/avatar-4.png'),
    },
    {
      key: 'avatar',
      title: 'Avatar',
      focusedIcon: require('../../assets/avatar-1.png'),
      iconRenderingMode: 'alwaysOriginal',
    },
    {
      key: 'album',
      title: 'Album',
      unfocusedIcon: require('../../assets/avatar-3.png'),
      focusedIcon: require('../../assets/avatar-4.png'),
      iconRenderingMode: 'alwaysOriginal',
    },
    {
      key: 'chat',
      title: 'Chat',
      focusedIcon: require('../../assets/avatar-4.png'),
      iconRenderingMode: 'alwaysOriginal',
    },
  ]);

  return (
    <TabView
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
    />
  );
}
