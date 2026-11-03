import { useScrollToTop } from '@react-navigation/native';
import React from 'react';
import {
  Image,
  Platform,
  ScrollView,
  type ScrollViewInstance,
  type ScrollViewProps,
  StyleSheet,
  useWindowDimensions,
  View,
} from 'react-native';

const COVERS = [
  require('../../assets/album-art-01.jpg'),
  require('../../assets/album-art-02.jpg'),
  require('../../assets/album-art-03.jpg'),
  require('../../assets/album-art-04.jpg'),
  require('../../assets/album-art-05.jpg'),
  require('../../assets/album-art-06.jpg'),
  require('../../assets/album-art-07.jpg'),
  require('../../assets/album-art-08.jpg'),
  require('../../assets/album-art-09.jpg'),
  require('../../assets/album-art-10.jpg'),
  require('../../assets/album-art-11.jpg'),
  require('../../assets/album-art-12.jpg'),
  require('../../assets/album-art-13.jpg'),
  require('../../assets/album-art-14.jpg'),
  require('../../assets/album-art-15.jpg'),
  require('../../assets/album-art-16.jpg'),
  require('../../assets/album-art-17.jpg'),
  require('../../assets/album-art-18.jpg'),
  require('../../assets/album-art-19.jpg'),
  require('../../assets/album-art-20.jpg'),
  require('../../assets/album-art-21.jpg'),
  require('../../assets/album-art-22.jpg'),
  require('../../assets/album-art-23.jpg'),
  require('../../assets/album-art-24.jpg'),
];

export function Albums(props: Partial<ScrollViewProps>) {
  const dimensions = useWindowDimensions();

  console.log(Platform.OS, ' Rendering Albums');
  const itemSize = dimensions.width / Math.floor(dimensions.width / 150);

  const ref = React.useRef<ScrollViewInstance>(null);

  useScrollToTop(ref);

  return (
    <ScrollView
      ref={ref}
      contentContainerStyle={styles.content}
      contentInsetAdjustmentBehavior="automatic"
      {...props}
    >
      {COVERS.map((source, i) => (
        <View
          key={i}
          style={[
            styles.item,
            Platform.OS !== 'web' && {
              height: itemSize,
              width: itemSize,
            },
          ]}
        >
          <Image source={source} resizeMode="cover" style={styles.photo} />
        </View>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  ...Platform.select({
    web: {
      content: {
        // FIXME: React Native's types for `display` don't include `grid`.
        display: 'grid' as any,
        gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))',
      },
      item: {
        width: '100%',
      },
    },
    default: {
      content: {
        flexDirection: 'row',
        flexWrap: 'wrap',
      },
      item: {},
    },
  }),
  photo: {
    flex: 1,
    height: 'auto',
    width: 'auto',
  },
});
