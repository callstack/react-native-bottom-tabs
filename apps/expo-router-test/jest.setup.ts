const consoleMethods = ['warn', 'error'] as const;

let output: string[] = [];

beforeEach(() => {
  output = [];

  for (const method of consoleMethods) {
    jest.spyOn(console, method).mockImplementation((...args: unknown[]) => {
      output.push(`console.${method}: ${args.join(' ')}`);
    });
  }
});

afterEach(() => {
  const captured = output;

  jest.restoreAllMocks();

  if (captured.length > 0) {
    throw new Error(`Expected no console output, got:\n${captured.join('\n')}`);
  }
});
