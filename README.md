# Video Call Test App

Simple Flutter + Agora app: Male/Female chuno, dono phone ek hi room me join honge.

## Setup
1. Agora console me project banao (App Certificate OFF / testing mode) aur App ID lo.
2. `lib/config.dart` me App ID set hai (ya GitHub Secret `AGORA_APP_ID` use karo).
3. Push karne par Actions tab me "Build APK" chalega (ya Run workflow dabao).
4. Run complete hone par Artifacts se `video-test-apk` download karo, zip kholo, `app-release.apk` dono phone me install karo.
5. Ek phone me Male, doosre me Female dabao. Dono ko ek doosre ki video dikhni chahiye.

## Permissions
App pehli baar Camera aur Mic ki permission maangta hai. Deny karne par error screen par
"Dobara try karo" aur "Settings kholo" buttons aate hain.

## Problem aaye to
- Black screen / "Error 110": Agora project me App Certificate OFF karo.
- Permission error: phone Settings me Camera aur Mic allow karo.
