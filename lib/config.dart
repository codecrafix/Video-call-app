// Agora App ID: yahan default diya hua hai (ya GitHub Secret AGORA_APP_ID se override hota hai).
const String agoraAppId = String.fromEnvironment(
  'AGORA_APP_ID',
  defaultValue: '3d394ed68f3f4e989c91f92baef3ea32',
);

// Dono phone isi channel me join honge (app ke home screen par badal bhi sakte ho).
const String defaultChannelName = 'test_room';

// Agar Agora project me App Certificate ON hai to Temp Token chahiye.
// Token ko app ke home screen par paste kar do (rebuild ki zarurat nahi).
// Optional: build time par bhi de sakte ho: --dart-define=AGORA_TOKEN=xxxx
const String defaultAgoraToken = String.fromEnvironment(
  'AGORA_TOKEN',
  defaultValue: '',
);
