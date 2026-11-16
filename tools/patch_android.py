import os
import re

path = "android/app/src/main/AndroidManifest.xml"
with open(path, "r", encoding="utf-8") as f:
    xml = f.read()

perms = [
    "android.permission.INTERNET",
    "android.permission.CAMERA",
    "android.permission.RECORD_AUDIO",
    "android.permission.MODIFY_AUDIO_SETTINGS",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.ACCESS_WIFI_STATE",
    "android.permission.BLUETOOTH",
    "android.permission.BLUETOOTH_CONNECT",
]

add = ""
for p in perms:
    if p not in xml:
        add += f'    <uses-permission android:name="{p}" />\n'

if 'android.hardware.camera"' not in xml:
    add += '    <uses-feature android:name="android.hardware.camera" android:required="false" />\n'
    add += '    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />\n'

if add:
    xml = xml.replace("<application", add + "    <application", 1)

xml = re.sub(r'android:label="[^"]*"', 'android:label="Video Test"', xml, count=1)

with open(path, "w", encoding="utf-8") as f:
    f.write(xml)
print("Manifest patched")

# --- compileSdk fix -------------------------------------------------------
# agora_rtc_engine is compiled against android-31, but its AndroidX
# dependencies require compileSdk 33/34+. A Gradle init script raises the
# compileSdk of every plugin/library module (not the app) before the build.
COMPILE_SDK = 37
init_dir = os.path.join(os.path.expanduser("~"), ".gradle", "init.d")
os.makedirs(init_dir, exist_ok=True)
init_script = f"""allprojects {{
    afterEvaluate {{ p ->
        if (p.name != 'app' && p.extensions.findByName('android') != null) {{
            p.extensions.android.compileSdkVersion {COMPILE_SDK}
        }}
    }}
}}
"""
with open(os.path.join(init_dir, "compile-sdk.gradle"), "w", encoding="utf-8") as f:
    f.write(init_script)
print(f"Gradle init script written: plugin modules -> compileSdk {COMPILE_SDK}")
