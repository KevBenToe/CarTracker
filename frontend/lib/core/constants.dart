const kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000/api/v1',
);

const kDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

const double kTabletBreakpoint = 800;
const double kDesktopBreakpoint = 1100;

