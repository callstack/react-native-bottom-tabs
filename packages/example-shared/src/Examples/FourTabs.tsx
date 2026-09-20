import TabView, { SceneMap, useTabSceneInsets } from 'react-native-bottom-tabs';
import { useState, type ComponentProps } from 'react';
import { I18nManager } from 'react-native';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';

type TabViewProps = ComponentProps<typeof TabView>;

interface Props {
  disablePageAnimations?: boolean;
  scrollEdgeAppearance?: 'default' | 'opaque' | 'transparent';
  backgroundColor?: NonNullable<TabViewProps['tabBarStyle']>['backgroundColor'];
  translucent?: boolean;
  hideOneTab?: boolean;
  rippleColor?: TabViewProps['rippleColor'];
  activeIndicatorColor?: TabViewProps['activeIndicatorColor'];
}

function InsetArticle(props: ComponentProps<typeof Article>) {
  const insets = useTabSceneInsets();
  return (
    <Article
      {...props}
      contentInsetAdjustmentBehavior={insets ? 'never' : 'automatic'}
      contentContainerStyle={
        insets
          ? {
              paddingTop: 16 + insets.top,
              paddingEnd: I18nManager.isRTL ? insets.left : insets.right,
              paddingBottom: 16 + insets.bottom,
              paddingStart: I18nManager.isRTL ? insets.right : insets.left,
            }
          : { paddingVertical: 16 }
      }
    />
  );
}

const renderScene = SceneMap({
  article: InsetArticle,
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
      key: 'contacts',
      focusedIcon: require('../../assets/icons/person_dark.png'),
      title: 'Contacts',
      badge: ' ',
    },
    {
      key: 'chat',
      focusedIcon: require('../../assets/icons/chat_dark.png'),
      title: 'Chat',
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
    />
  );
}
