import * as React from 'react';
import { View, Text, StyleSheet } from 'react-native';

type MusicControlProps = {
  bottomOffset: number;
};

export const MusicControl: React.FC<MusicControlProps> = ({ bottomOffset }) => {
  return (
    <View
      style={[
        styles.musicControlContainer,
        {
          bottom: bottomOffset + 10,
        },
      ]}
    >
      <View style={styles.musicControlContent}>
        <View style={styles.songInfo}>
          <Text style={styles.songTitle} numberOfLines={1}>
            Currently Playing Song
          </Text>
        </View>
        <View style={styles.controls}>
          <Text style={styles.controlButton}>⏸</Text>
          <Text style={styles.controlButton}>⏭</Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  musicControlContainer: {
    position: 'absolute',
    left: 15,
    right: 15,
    borderRadius: 18,
    height: 55,
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.25,
    shadowRadius: 5,
    elevation: 8,
  },
  musicControlContent: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  songInfo: {
    flex: 1,
    marginRight: 16,
  },
  songTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#000',
  },
  controls: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  controlButton: {
    fontSize: 24,
    paddingHorizontal: 12,
    color: '#000',
  },
});
