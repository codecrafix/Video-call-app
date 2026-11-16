// Agora App ID yahan paste karo (ya GitHub Secret AGORA_APP_ID me daalo).
// Testing mode (App Certificate OFF) ke liye token ki zarurat nahi.
const String agoraAppId = String.fromEnvironment(
  'AGORA_APP_ID',
  defaultValue: '3d394ed68f3f4e989c91f92baef3ea32',
);

// Dono phone isi channel me join honge.
const String channelName = 'test_room';
