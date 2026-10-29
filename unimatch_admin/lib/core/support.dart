const supportEmail = 'unimatch7@gmail.com';

// Enable only after deploying and verifying the privileged account backend.
// The current Spark project cannot deploy Cloud Functions.
const accountManagementBackendEnabled = bool.fromEnvironment(
  'ACCOUNT_MANAGEMENT_ENABLED',
  defaultValue: false,
);
