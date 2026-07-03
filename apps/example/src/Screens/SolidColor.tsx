import { StyleSheet, Text, View } from 'react-native';

export function SolidColor() {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>Solid Color</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'black',
  },
  text: {
    color: 'red',
  },
});
