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
