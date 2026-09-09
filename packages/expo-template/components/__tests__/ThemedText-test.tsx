import { render, screen } from '@testing-library/react-native';

import { ThemedText } from '../ThemedText';

it('renders its children', async () => {
  await render(<ThemedText>Snapshot test!</ThemedText>);

  expect(screen.getByText('Snapshot test!')).toBeOnTheScreen();
});
