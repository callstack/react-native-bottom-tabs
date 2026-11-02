import {
  Image,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  type ScrollViewProps,
  StyleSheet,
  Text,
  TextInput,
  View,
  Button,
  Alert,
} from 'react-native';

const MESSAGES = [
  'okay',
  'sudo make me a sandwich',
  'what? make it yourself',
  'make me a sandwich',
];

export function Chat({
  bottom = true,
  ...rest
}: Partial<ScrollViewProps & { bottom: boolean }>) {
  console.log(Platform.OS, ' Rendering Chat');
  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <Button onPress={() => Alert.alert('Hey')} title="Press me" />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={styles.inverted}
        contentContainerStyle={styles.content}
        {...rest}
      >
        {MESSAGES.map((text, i) => {
          const odd = i % 2;

          return (
            <View
              key={i}
              style={[odd ? styles.odd : styles.even, styles.inverted]}
            >
              <Image
                style={styles.avatar}
                source={
                  odd
                    ? require('../../assets/avatar-2.png')
                    : require('../../assets/avatar-1.png')
                }
              />
              <View
                style={[
                  styles.bubble,
                  { backgroundColor: odd ? 'blue' : 'white' },
                ]}
              >
                <Text style={{ color: odd ? 'white' : 'blue' }}>{text}</Text>
              </View>
            </View>
          );
        })}
      </ScrollView>
      <TextInput
        style={[styles.input, { backgroundColor: 'white', color: 'black' }]}
        placeholderTextColor={'#B0B0B0'}
        placeholder="Write a message"
        underlineColorAndroid="transparent"
      />
      {bottom ? (
        <View
          style={[styles.spacer, Platform.OS !== 'android' && { height: 90 }]}
        />
      ) : null}
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F2F2F2',
  },
  inverted: {
    transform: [{ scaleY: -1 }],
  },
  content: {
    padding: 16,
  },
  even: {
    flexDirection: 'row',
  },
  odd: {
    flexDirection: 'row-reverse',
  },
  avatar: {
    marginVertical: 8,
    marginHorizontal: 6,
    height: 40,
    width: 40,
    borderRadius: 20,
    borderColor: 'rgba(0, 0, 0, .16)',
    borderWidth: StyleSheet.hairlineWidth,
  },
  bubble: {
    marginVertical: 8,
    marginHorizontal: 6,
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 20,
  },
  input: {
    height: 48,
    paddingVertical: 12,
    paddingHorizontal: 24,
  },
  spacer: {
    backgroundColor: '#fff',
  },
});
