# Video Call Test App

Simple Flutter + Agora app. Ek phone me Male, doosre me Female dabao, dono ek hi channel me join hote hain.

## 1. Agora console setup (ek baar)
Agora project me **App Certificate ON** hai, isliye call join karne ke liye **Token** chahiye.
(Bina token ke `ErrorCodeType.errInvalidToken` aata hai.)

1. https://console.agora.io -> apna project **Video call** kholo.
2. **Security** section me **Generate Temp Token** dabao.
3. **Channel name** me `test_room` likho (app ka default channel yahi hai) -> **Generate**.
4. Jo lamba token mile use **copy** karo.

Temp Token **24 ghante** chalta hai. Expire hone par ye steps dobara karke naya token lo.
Token sirf us **channel name** ke liye chalta hai jis ke liye bana hai.

App ID `lib/config.dart` me pehle se set hai (GitHub Secret `AGORA_APP_ID` set karo to wo use hota hai).

## 2. APK download aur install
1. GitHub repo -> **Actions** tab -> sabse upar wala green run kholo.
2. Neeche **Artifacts** me **video-test-apk** download karo (ye zip hai).
   - `video-test-aab` mat lo. AAB sirf Play Store upload ke liye hota hai, phone me install nahi hota.
3. Zip ko **ZArchiver** ya **Files by Google** se **Extract** karo. Andar `app-release.apk` milegi.
4. `app-release.apk` par tap karo -> agar poochhe to **Install unknown apps** allow karo -> **Install**.
5. Ye dono phones par karo.

## 3. Call chalana
1. App kholo. Camera aur Mic ki permission **Allow** karo.
2. Dono phones par **Channel name** same rakho (`test_room`).
3. **Agora Token** box me copied token paste karo (dono phones me same token).
4. Ek phone par **Male**, doosre par **Female** dabao.
5. Dono ko ek doosre ki video dikhni chahiye. Neeche buttons: mic mute, camera off, camera switch, call end.

## Problem aaye to
| Error / dikkat | Kya karo |
|---|---|
| `errInvalidToken` / `errTokenExpired` | Naya Temp Token banao (channel name wahi), home screen par paste karo |
| Token paste kiya phir bhi invalid | Console me channel name aur app ke channel name me spelling same honi chahiye |
| Black screen, permission error | Phone Settings -> Apps -> Video Test -> Permissions me Camera aur Mic allow karo |
| Ek hi phone me video aati hai | Doosre phone me bhi same channel aur same token ho, internet chalu ho |
| APK install nahi ho rahi | Purani Video Test app uninstall karke dobara install karo |

## APK size
Build me x86_64 hata diya gaya hai (`tools/patch_android.py` me `ABIS` list), isliye APK pehle se chhoti hai.
Aur chhoti chahiye ho to `ABIS` me se `armeabi-v7a` hata do (sirf 64-bit phones par chalegi).

## Build
Main branch par push karne se **Actions -> Build APK and AAB** chalta hai (ya **Run workflow** dabao).
